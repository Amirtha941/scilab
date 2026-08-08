// =============================================================================
// CommVerse - Quantization DSP Algorithms
// File: src/dsp/quantization.sci
// =============================================================================

function v_q = dsp_quantize_vector(v, L, q_type, amp, mu)
    // Core helper to quantize a normalized signal vector v in range [-1, 1]
    
    // Normalize input to [-1, 1] safely
    if amp == 0 then
        v_norm = zeros(v);
    else
        v_norm = max(-1.0, min(1.0, v / amp));
    end
    
    select q_type
    case "uniform_midrise"
        // Step size
        delta = 2.0 / L;
        // Midrise formula
        q = delta * (floor(v_norm / delta) + 0.5);
        v_q = q * amp;
        
    case "uniform_midtread"
        delta = 2.0 / L;
        // Midtread formula using rounding and clamping to L levels
        indices = round(v_norm / delta);
        clamped_indices = max(-L/2, min(L/2 - 1, indices));
        v_q = clamped_indices * delta * amp;
        
    case "mu_law"
        // 1. Compression
        // y = sgn(x) * ln(1 + mu*|x|) / ln(1 + mu)
        y = sign(v_norm) .* log(1.0 + mu * abs(v_norm)) / log(1.0 + mu);
        
        // 2. Uniform Quantization on compressed signal (using Midrise)
        delta = 2.0 / L;
        y_q = delta * (floor(y / delta) + 0.5);
        y_q = max(-1.0 + delta/2, min(1.0 - delta/2, y_q)); // clamp inside boundaries
        
        // 3. Expansion (Inverse Companding)
        // x_q = sgn(y_q) * ((1 + mu)^|y_q| - 1) / mu
        v_q_norm = sign(y_q) .* ((1.0 + mu).^abs(y_q) - 1.0) / mu;
        v_q = v_q_norm * amp;
    end
endfunction

function state = dsp_run_quantization(state)
    // Quantizes both the continuous analog waveform and the sampled waveform.
    // Inputs:
    //   state: global state structure
    // Outputs:
    //   state: updated global state with quantized waveforms and SQNR calculations
    
    // 1. Parameter Clamping & Safety Validation
    levels = state.params.quantization.levels;
    // Force levels to be one of [2, 4, 8, 16, 32, 64]
    valid_levels = [2, 4, 8, 16, 32, 64];
    [val, idx] = min(abs(valid_levels - levels));
    L = valid_levels(idx);
    state.params.quantization.levels = L;
    
    q_type = state.params.quantization.type; // "uniform_midrise" | "uniform_midtread" | "mu_law"
    mu = max(1.0, min(500.0, state.params.quantization.mu));
    amp = state.params.signal.amp;
    
    // 2. Verify dependencies
    t_dense = state.data.time;
    analog_wave = state.data.analog_waveform;
    t_s = state.data.sampled_time;
    sampled_wave = state.data.sampled_waveform;
    
    if isempty(t_s) | isempty(sampled_wave) then
        // Run sampling stage first if missing
        state = dsp_run_sampling(state);
        t_dense = state.data.time;
        analog_wave = state.data.analog_waveform;
        t_s = state.data.sampled_time;
        sampled_wave = state.data.sampled_waveform;
    end
    
    // 3. Quantize the discrete samples (for PCM transmission)
    state.data.quantized_samples = dsp_quantize_vector(sampled_wave, L, q_type, amp, mu);
    
    // 4. Quantize the continuous analog wave (for staircase plotting)
    state.data.quantized_waveform = dsp_quantize_vector(analog_wave, L, q_type, amp, mu);
    
    // 5. Calculate Quantization Error Waveform
    state.data.quantization_error = state.data.quantized_waveform - analog_wave;
    
    // 6. Calculate Signal-to-Quantization Noise Ratio (SQNR)
    // SQNR = 10 * log10( Signal Power / Noise Power )
    signal_power = mean(analog_wave.^2);
    noise_power = mean(state.data.quantization_error.^2);
    
    if noise_power == 0 then
        state.data.sqnr = 99.9; // Avoid infinity, clamp to high SQNR
    else
        state.data.sqnr = 10.0 * log10(signal_power / noise_power);
    end
    
    // Mark stage status as operational
    state = state_set_pipeline_status(state, "quantization", "OK");
endfunction
