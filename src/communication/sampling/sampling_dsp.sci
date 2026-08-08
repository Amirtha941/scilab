// =============================================================================
// CommVerse - Sampling & Reconstruction DSP Algorithms
// File: src/dsp/sampling.sci
// =============================================================================

function y = dsp_safe_sinc(x)
    // Vectorized normalized sinc function: sinc(x) = sin(pi * x) / (pi * x)
    // Safely handles x = 0 to avoid division by zero.
    y = ones(x);
    non_zero = find(x <> 0);
    if ~isempty(non_zero) then
        y(non_zero) = sin(%pi * x(non_zero)) ./ (%pi * x(non_zero));
    end
endfunction

function state = dsp_run_sampling(state)
    // Simulates the discretization of the message signal and interpolates to reconstruct it.
    // Inputs:
    //   state: global state structure
    // Outputs:
    //   state: updated global state with sampled and reconstructed waveforms
    
    // 1. Parameter Clamping & Safety Validation
    fs = max(2.0, min(100.0, state.params.sampling.fs)); // limit fs from 2Hz to 100Hz
    state.params.sampling.fs = fs;
    
    t_dense = state.data.time;
    analog_wave = state.data.analog_waveform;
    
    if isempty(t_dense) | isempty(analog_wave) then
        // If the signal generator has not run yet, run it first
        state = dsp_run_signal(state);
        t_dense = state.data.time;
        analog_wave = state.data.analog_waveform;
    end
    
    // 2. Generate sample time points
    // Ensure the last sample is exactly at 1.0s or within bounds
    t_s = 0:(1.0 / fs):1.0;
    state.data.sampled_time = t_s;
    
    // 3. Extract sample values via interpolation
    state.data.sampled_waveform = interp1(t_dense, analog_wave, t_s);
    
    // 4. Whittaker-Shannon Sinc Interpolation (Vectorized Matrix Multiplication)
    M = size(t_dense, "*"); // Number of dense points (e.g. 5001)
    N = size(t_s, "*");     // Number of samples (e.g. fs + 1)
    
    // Create difference matrix: diff_matrix(i, j) = t_dense(i) - t_s(j)
    // t_dense is a row vector or column, let's force it to column
    t_dense_col = t_dense(:);
    t_s_row = t_s(:)';
    
    diff_matrix = (t_dense_col * ones(1, N)) - (ones(M, 1) * t_s_row);
    
    // Calculate the sinc kernel matrix
    sinc_matrix = dsp_safe_sinc(fs * diff_matrix);
    
    // Multiply by the sample values vector to get reconstructed waveform
    // sampled_waveform is forced to a column vector for matrix multiplication
    sampled_col = state.data.sampled_waveform(:);
    state.data.recovered_waveform = (sinc_matrix * sampled_col)';
    
    // 5. Detect Aliasing and violations of the Nyquist Criterion
    // Nyquist rate is 2 * max_frequency. In our generator, max_frequency is state.params.signal.freq.
    f_max = state.params.signal.freq;
    state.data.aliasing_present = (fs < 2.0 * f_max);
    
    // Calculate Reconstruction Root-Mean-Square Error (RMSE)
    state.data.reconstruction_error = sqrt(mean((analog_wave - state.data.recovered_waveform).^2));
    
    // Mark stage status as operational
    state = state_set_pipeline_status(state, "sampling", "OK");
endfunction
