// =============================================================================
// CommVerse - PCM Encoder / Decoder DSP Algorithms
// File: src/dsp/pcm.sci
// =============================================================================

function bits = dsp_dec2bin_row(val, N)
    // Helper to convert a single integer val (0 to 2^N-1) to N binary bits
    bits = zeros(1, N);
    temp = val;
    for b = N:-1:1
        bits(b) = pmodulo(temp, 2);
        temp = floor(temp / 2);
    end
endfunction

function val = dsp_bin2dec_row(bits, N)
    // Helper to convert N binary bits back to a decimal integer
    powers = 2.^(N-1:-1:0);
    val = sum(bits .* powers);
endfunction

function state = dsp_run_pcm(state)
    // Performs binary PCM encoding on quantized samples, serializes to a bitstream,
    // and decodes them back to verify receiver output.
    // Inputs:
    //   state: global state structure
    // Outputs:
    //   state: updated global state with binary words, bitstream, and recovered levels
    
    // 1. Verify dependencies
    if ~isfield(state.data, "quantized_samples") then
        state = dsp_run_quantization(state);
    end
    
    L = state.params.quantization.levels;
    q_type = state.params.quantization.type;
    mu = state.params.quantization.mu;
    amp = state.params.signal.amp;
    fs = state.params.sampling.fs;
    
    t_s = state.data.sampled_time;
    q_samples = state.data.quantized_samples;
    t_dense = state.data.time;
    
    N_bits = round(log2(L)); // Bits per sample
    delta = 2.0 / L;
    
    N_samples = size(q_samples, "*");
    
    // 2. Map quantized sample values back to level indices I in [0, L-1]
    indices = zeros(1, N_samples);
    for n = 1:N_samples
        v = q_samples(n);
        if amp == 0 then
            v_norm = 0;
        else
            v_norm = max(-1.0, min(1.0, v / amp));
        end
        
        select q_type
        case "uniform_midrise"
            idx = round((v_norm / delta) + L/2 - 0.5);
            
        case "uniform_midtread"
            idx = round(v_norm / delta) + L/2;
            
        case "mu_law"
            // For mu-law, quantization was done uniformly in compressed domain
            y = sign(v_norm) * log(1.0 + mu * abs(v_norm)) / log(1.0 + mu);
            idx = round((y / delta) + L/2 - 0.5);
        end
        
        // Safety clamp index
        indices(n) = max(0, min(L - 1, idx));
    end
    state.data.pcm_indices = indices;
    
    // 3. Binary Encoding (Map indices to N-bit binary words)
    binary_matrix = zeros(N_samples, N_bits);
    for n = 1:N_samples
        binary_matrix(n, :) = dsp_dec2bin_row(indices(n), N_bits);
    end
    state.data.pcm_binary_matrix = binary_matrix;
    
    // Convert matrix to cell-like string representation for display table
    bin_words_str = [];
    for n = 1:N_samples
        word_str = "";
        for b = 1:N_bits
            word_str = word_str + string(binary_matrix(n, b));
        end
        bin_words_str = [bin_words_str; word_str];
    end
    state.data.pcm_binary_words = bin_words_str;
    
    // 4. Serialization (Flatten to continuous bitstream)
    bitstream = matrix(binary_matrix', 1, -1);
    state.data.pcm_bitstream = bitstream;
    
    // 5. Calculate Bit Rate
    // Bit Rate = fs * N_bits
    state.data.pcm_bit_rate = fs * N_bits;
    state.data.bit_rate_actual = state.data.pcm_bit_rate;
    
    // 6. PCM Decoding (Receiver Demodulation simulation)
    // Group bitstream back to N-bit words and decode back to voltages
    recovered_samples = zeros(1, N_samples);
    decoded_indices = zeros(1, N_samples);
    
    for n = 1:N_samples
        // Extract N-bit word from bitstream
        start_idx = (n - 1) * N_bits + 1;
        word_bits = bitstream(start_idx : start_idx + N_bits - 1);
        
        // Convert to decimal index
        dec_idx = dsp_bin2dec_row(word_bits, N_bits);
        decoded_indices(n) = dec_idx;
        
        // Map decimal index back to representation voltage level
        select q_type
        case "uniform_midrise"
            v_rec_norm = delta * (dec_idx - L/2 + 0.5);
            recovered_samples(n) = v_rec_norm * amp;
            
        case "uniform_midtread"
            v_rec_norm = delta * (dec_idx - L/2);
            recovered_samples(n) = v_rec_norm * amp;
            
        case "mu_law"
            y_q = delta * (dec_idx - L/2 + 0.5);
            y_q = max(-1.0 + delta/2, min(1.0 - delta/2, y_q)); // clamp
            // Inverse companding
            v_rec_norm = sign(y_q) * ((1.0 + mu)^abs(y_q) - 1.0) / mu;
            recovered_samples(n) = v_rec_norm * amp;
        end
    end
    state.data.pcm_recovered_samples = recovered_samples;
    
    // 7. Receiver Whittaker-Shannon Sinc Reconstruction
    M = size(t_dense, "*");
    N = size(t_s, "*");
    t_dense_col = t_dense(:);
    t_s_row = t_s(:)';
    diff_matrix = (t_dense_col * ones(1, N)) - (ones(M, 1) * t_s_row);
    
    // Import sinc helper if loaded or redefine locally to ensure independence
    // (dsp_safe_sinc is defined in sampling.sci)
    if exists("dsp_safe_sinc") then
        sinc_matrix = dsp_safe_sinc(fs * diff_matrix);
    else
        // fallback local definition
        y_sinc = ones(diff_matrix);
        nz = find(diff_matrix <> 0);
        if ~isempty(nz) then
            y_sinc(nz) = sin(%pi * fs * diff_matrix(nz)) ./ (%pi * fs * diff_matrix(nz));
        end
        sinc_matrix = y_sinc;
    end
    
    rec_col = recovered_samples(:);
    state.data.pcm_recovered_waveform = (sinc_matrix * rec_col)';
    
    // Mark stage status as operational
    state = state_set_pipeline_status(state, "pcm", "OK");
endfunction
