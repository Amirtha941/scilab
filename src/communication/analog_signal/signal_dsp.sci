// =============================================================================
// CommVerse - Signal Generator DSP Algorithms
// File: src/dsp/signal.sci
// =============================================================================

function state = dsp_run_signal(state)
    // Generates the baseband analog message waveform m(t)
    // Inputs:
    //   state: global state structure
    // Outputs:
    //   state: updated global state with populated analog signal data
    
    // 1. Parameter Clamping & Safety Validation
    amp = max(0.1, min(10.0, state.params.signal.amp));
    freq = max(0.5, min(50.0, state.params.signal.freq));
    phase_deg = state.params.signal.phase;
    phase_rad = phase_deg * %pi / 180.0;
    
    // 2. Define the continuous-time analog grid
    // 5001 samples over 1.0 second represents a high-resolution analog baseline.
    t = 0:0.0002:1.0;
    state.data.time = t;
    
    // 3. Waveform Generation
    select state.params.signal.type
    case "sine"
        state.data.analog_waveform = amp * sin(2.0 * %pi * freq * t + phase_rad);
        
    case "square"
        // Vectorized square wave using signum
        // We add a tiny epsilon to prevent 0 values from returning 0 instead of 1/-1
        raw_sin = sin(2.0 * %pi * freq * t + phase_rad);
        zero_indices = find(raw_sin == 0);
        if ~isempty(zero_indices) then
            raw_sin(zero_indices) = 1e-12;
        end
        state.data.analog_waveform = amp * sign(raw_sin);
        
    case "triangle"
        // Vectorized triangle wave using arcsin(sin(x)) formula
        state.data.analog_waveform = (2.0 * amp / %pi) * asin(sin(2.0 * %pi * freq * t + phase_rad));
        
    case "prbs"
        // Seeded repeatable PRBS bitstream mapping
        // Calculate the number of bits required based on the bit rate
        bit_rate = max(1.0, min(50.0, state.params.signal.bit_rate));
        n_bits = ceil(bit_rate);
        
        // Save current random state, set seed, generate, and restore
        old_seed = grand("getsd");
        grand("setsd", 42); // Lock seed for reproducible simulations
        bits = grand(1, n_bits, "uin", 0, 1);
        grand("setsd", old_seed); // Restore system seed
        
        // Convert [0,1] bits to bipolar [-amp, amp] levels
        levels = (bits * 2.0 - 1.0) * amp;
        
        // Map the levels to the dense continuous time grid
        // index = floor(t * bit_rate) + 1
        t_indices = floor(t * bit_rate) + 1;
        // Clamp indices to stay within array bounds
        t_indices = max(1, min(n_bits, t_indices));
        
        state.data.analog_waveform = levels(t_indices);
        state.data.tx_bits = bits; // Save bits to state for PCM comparison
    end
    
    // Mark stage status as operational
    state = state_set_pipeline_status(state, "signal", "OK");
endfunction
