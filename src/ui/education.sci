// =============================================================================
// GUIVerse - Right Educational Panel Builder & Router
// File: src/ui/education.sci
// =============================================================================

function ui_create_education(fig, education_panel)
    // Instantiates the educational card area.
    // Inputs:
    //   fig: graphic handle of the main window
    //   education_panel: graphic handle of the right container frame
    
    colors = get_theme_colors();
    set(education_panel, "BackgroundColor", colors.bg_main);
    
    // Panel title
    h_lbl = uicontrol(education_panel, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [0.05, 0.94, 0.90, 0.04], ...
        "string", "Educational Panel", ...
        "HorizontalAlignment", "center");
    style_control(h_lbl, "header");
    
    // Educational content area (multiline read-only scrollable edit box)
    h_content = uicontrol(education_panel, ...
        "style", "edit", ...
        "units", "normalized", ...
        "position", [0.05, 0.02, 0.90, 0.90], ...
        "Max", 2, ...                 // Max > 1 enables multiline scrollbar
        "enable", "off", ...          // Make it read-only
        "HorizontalAlignment", "left", ...
        "FontName", colors.font_name, ...
        "FontSize", colors.fs_normal, ...
        "string", "Select a module to view theory, formulas, and GATE insights.");
        
    set(h_content, "BackgroundColor", colors.bg_panel);
    set(h_content, "ForegroundColor", colors.text_primary);
    
    // Save handle to state
    state = fig.user_data;
    state.ui.education_panel = h_content;
    fig.user_data = state;
endfunction

function ui_render_education(module_name, state)
    // Dynamically updates the text within the read-only edit box based on the active module.
    // Inputs:
    //   module_name: string of active panel
    //   state: global state structure
    
    h_content = state.ui.education_panel;
    if isempty(h_content) | ~is_valid_handle(h_content) then return; end
    
    resolved_name = module_name;
    if module_name == "sampling_uniform" | module_name == "sampling_recon" then
        resolved_name = "sampling";
    elseif module_name == "quant_uniform" | module_name == "quant_nonuniform" then
        resolved_name = "quantization";
    elseif module_name == "pcm_encoder" | module_name == "pcm_serialized" then
        resolved_name = "pcm";
    end
    
    lines = ["=========================================";
             "  GUIVERSE DIGITAL COMMUNICATION ENGINE  ";
             "=========================================";
             ""];
             
    select resolved_name
    case "home"
        lines = [lines;
                 "WELCOME TO GUIVERSE";
                 "";
                 "This software simulates a complete interactive digital";
                 "communication system. Every step is linked in one";
                 "continuous pipeline.";
                 "";
                 "GETTING STARTED:";
                 "1. Click any stage in the dashboard chain below or";
                 "   select a module from the left sidebar.";
                 "2. Adjust parameters live in the bottom workspace cards.";
                 "3. Observe physical waveforms, frequency spectrums,";
                 "   constellation shifts, and eye openings.";
                 "4. Note down observations and export a Lab Report.";
                 "";
                 "COMMUNICATION FLOW:";
                 "Signal Generator -> Sampling -> Quantization -> PCM ->";
                 "Line Coding -> Modulation -> Noise -> Receiver -> Output";
                 "";
                 "GATE INSIGHT:";
                 "- The pipeline represents the physical layer (Layer 1) of";
                 "  the OSI model. Focus on relationships between";
                 "  bandwidth, sampling rate, SNR, and BER.";
                 "";
                 "DESIGN NOTES:";
                 "- This GUI is single-window to avoid window scatter.";
                 "- Resizing the figure updates components smoothly."];
                 
    case "signal_generator"
        lines = [lines;
                 "1. SIGNAL GENERATOR";
                 "";
                 "--- CONCEPT ---";
                 "Analog communication signals are continuous-time waves.";
                 "In digital processing, continuous signals are emulated";
                 "using a very high sampling rate (internal fs_analog).";
                 "";
                 "--- THEORY ---";
                 "Periodic signals are represented by sinusoids or pulses.";
                 "The time period T dictates the signal repetition interval,";
                 "while amplitude determines signal strength.";
                 "";
                 "--- FORMULA ---";
                 "  Sine wave: x(t) = A * sin(2 * pi * f * t + phi)";
                 "  Square wave: x(t) = A * sgn(sin(2 * pi * f * t))";
                 "";
                 "--- ENGINEERING NOTE ---";
                 "Periodic signals have discrete line spectrums.";
                 "Random signals have continuous spectrums.";
                 "";
                 "--- COMMON MISTAKES ---";
                 "- Forgetting that duty cycle affects average power.";
                 "- Neglecting spectral leakage in FFT visualizations."];
                 
    case "sampling"
        lines = [lines;
                 "2. SAMPLING & RECONSTRUCTION";
                 "";
                 "--- CONCEPT ---";
                 "Sampling converts a continuous-time signal into a";
                 "discrete-time sequence by reading amplitudes at";
                 "regular intervals Ts (Sampling Interval).";
                 "";
                 "--- THEORY ---";
                 "Nyquist-Shannon Sampling Theorem states that a signal";
                 "must be sampled at a rate greater than twice its";
                 "maximum frequency to avoid aliasing: fs > 2 * fmax.";
                 "Whittaker-Shannon reconstruction uses sinc interpolation";
                 "to recover the continuous wave from discrete stems.";
                 "";
                 "--- FORMULA ---";
                 "  Nyquist Rate: f_nyq = 2 * fmax";
                 "  Reconstructed Signal x_r(t):";
                 "  x_r(t) = sum[ x(n*Ts) * sinc((t - n*Ts)/Ts) ]";
                 "";
                 "--- ENGINEERING NOTE ---";
                 "To reconstruct perfectly, the analog reconstruction filter";
                 "must be an ideal low-pass filter with cut-off frequency";
                 "f_c satisfying fmax < f_c < fs - fmax.";
                 "";
                 "--- COMMON MISTAKES ---";
                 "- Sampling below the Nyquist rate, which causes";
                 "  irreversible spectral overlap (aliasing).";
                 "- Confusing Nyquist rate with actual sampling frequency."];
                 
    case "quantization"
        lines = [lines;
                 "3. QUANTIZATION";
                 "";
                 "--- CONCEPT ---";
                 "Quantization converts continuous-amplitude samples";
                 "into discrete amplitudes mapping to L representation levels.";
                 "";
                 "--- THEORY ---";
                 "- Uniform: Step size delta is constant.";
                 "  - Midtread: Origin lies in the middle of a step.";
                 "  - Midrise: Origin lies at a step transition.";
                 "- Non-uniform: Smaller steps for weaker signals.";
                 "  - mu-law companding reduces dynamic range.";
                 "";
                 "--- FORMULA ---";
                 "  Uniform Step Size: Delta = 2 * A_max / L";
                 "  Theoretical Sinusoidal SQNR (Uniform):";
                 "  SQNR = 1.76 + 6.02 * N  (dB), where N = log2(L)";
                 "";
                 "--- ENGINEERING NOTE ---";
                 "Companding improves SQNR for low-amplitude signals";
                 "by amplifying them before quantization, providing";
                 "robustness against noise in speech transmission.";
                 "";
                 "--- COMMON MISTAKES ---";
                 "- Clipping input waveforms, which creates severe";
                 "  non-linear distortion (harmonic spikes).";
                 "- Assuming SQNR remains constant for all signal types."];
                 
    case "pcm"
        lines = [lines;
                 "4. PCM ENCODING";
                 "";
                 "--- CONCEPT ---";
                 "Pulse Code Modulation (PCM) represents analog samples";
                 "as serialized binary words, providing robust noise";
                 "immunity in digital links.";
                 "";
                 "--- THEORY ---";
                 "PCM involves sampling, quantization, and binary encoding.";
                 "A parallel encoder maps each quantized level to an";
                 "N-bit word, which is then serialized into pulses.";
                 "";
                 "--- FORMULA ---";
                 "  Bit Depth: N = log2(L) bits/sample";
                 "  PCM Link Bit Rate (Rb):";
                 "  Rb = N * fs  (bits/second)";
                 "";
                 "--- ENGINEERING NOTE ---";
                 "Digital transmission bandwidth is proportional to Rb.";
                 "The absolute minimum Nyquist channel bandwidth";
                 "required is B_min = Rb / 2.";
                 "";
                 "--- COMMON MISTAKES ---";
                 "- Confusing sampling frequency (samples/s) with";
                 "  bit rate (bits/s).";
                 "- Forgetting that increasing bits per sample improves";
                 "  fidelity but requires higher transmission bandwidth."];
 
    case "linecoding"
        lines = [lines;
                 "5. LINE CODING";
                 "";
                 "--- CONCEPT ---";
                 "Converts binary data into electrical pulses suitable";
                 "for baseband transmission over a channel.";
                 "";
                 "--- THEORY ---";
                 "- NRZ: Level remains constant during bit interval.";
                 "- RZ: Pulses return to zero level midway.";
                 "- Manchester: Transition at middle of each bit period.";
                 "- Bipolar AMI: Alternate mark inversion, zero DC.";
                 "";
                 "--- FORMULA ---";
                 "  Nyquist Bandwidth B = Rb / 2  (for NRZ)";
                 "  Nyquist Bandwidth B = Rb      (for Manchester / RZ)";
                 "";
                 "--- ENGINEERING NOTE ---";
                 "Manchester coding has twice the bandwidth of NRZ-L";
                 "but guarantees timing transition for clock recovery.";
                 "";
                 "--- COMMON MISTAKES ---";
                 "- Forgetting to alternate polarity in AMI Mark states.";
                 "- Neglecting DC components in unipolar transmissions."];
 
    case "modulation"
        lines = [lines;
                 "6. DIGITAL MODULATION";
                 "";
                 "--- CONCEPT ---";
                 "Shifts a baseband signal spectrum to a bandpass";
                 "carrier frequency for wireless transmission.";
                 "";
                 "--- THEORY ---";
                 "- ASK: Modulates amplitude of carrier.";
                 "- FSK: Shifts carrier frequency between two values.";
                 "- PSK: Shifts carrier phase (BPSK, QPSK).";
                 "- QAM: Combines amplitude and phase shift.";
                 "";
                 "--- FORMULA ---";
                 "  BPSK: s(t) = A * cos(2 * pi * fc * t + theta)";
                 "  where theta is 0 (bit 1) or pi (bit 0).";
                 "";
                 "--- ENGINEERING NOTE ---";
                 "Higher M-ary modulation improves spectral efficiency";
                 "but increases system sensitivity to noise.";
                 "";
                 "--- COMMON MISTAKES ---";
                 "- Misaligning local carrier phase at coherent receivers.";
                 "- Overmodulating carrier, causing spectral splatter."];
 
    case "noise"
        lines = [lines;
                 "7. AWGN CHANNEL & NOISE";
                 "";
                 "--- CONCEPT ---";
                 "AWGN adds thermal noise flat across system bandwidth";
                 "simulating physical media channel limits.";
                 "";
                 "--- THEORY ---";
                 "Noise samples are statistically independent, following";
                 "a Gaussian distribution with zero mean and variance";
                 "defined by SNR level.";
                 "";
                 "--- FORMULA ---";
                 "  Noise Variance: sigma^2 = P_signal / (10^(SNR/10))";
                 "";
                 "--- ENGINEERING NOTE ---";
                 "AWGN limits channel capacity according to Shannons Theorem.";
                 "";
                 "--- COMMON MISTAKES ---";
                 "- Assuming noise affects carrier frequency directly.";
                 "- Neglecting attenuation effects in path budgets."];
 
    case "receiver"
        lines = [lines;
                 "8. RECEIVER & DEMODULATOR";
                 "";
                 "--- CONCEPT ---";
                 "Recovers baseband bits from corrupted passband waves.";
                 "";
                 "--- THEORY ---";
                 "Correlators or matched filters maximize peak output SNR";
                 "at decision instants, comparing results to thresholds.";
                 "";
                 "--- FORMULA ---";
                 "  Correlation: Y = integral[ r(t) * template(t) ] dt";
                 "";
                 "--- ENGINEERING NOTE ---";
                 "Coherent detection requires exact carrier sync.";
                 "";
                 "--- COMMON MISTAKES ---";
                 "- Sampling outside the peak symbol synchronization point.";
                 "- Setting incorrect threshold limits under offsets."];
 
    case "ber"
        lines = [lines;
                 "9. BER PERFORMANCE";
                 "";
                 "--- CONCEPT ---";
                 "Bit Error Rate (BER) measures end-to-end digital link";
                 "fidelity by counting errors in transmission.";
                 "";
                 "--- THEORY ---";
                 "Compares experimental error rate to theoretical curves.";
                 "";
                 "--- FORMULA ---";
                 "  BPSK BER_theoretical = Q( sqrt( 2 * Eb / N0 ) )";
                 "";
                 "--- ENGINEERING NOTE ---";
                 "Always transmit sufficient bits (>> 10/BER) for accuracy.";
                 "";
                 "--- COMMON MISTAKES ---";
                 "- Measuring BER with too few bits, causing high variance.";
                 "- Confusing Eb/N0 with spectral channel SNR."];
 
    case "eye"
        lines = [lines;
                 "10. EYE DIAGRAM & ISI";
                 "";
                 "--- CONCEPT ---";
                 "Overlaps received symbol segments to visualize";
                 "signal quality, noise margins, and jitter.";
                 "";
                 "--- THEORY ---";
                 "Open eye signifies high noise immunity; closed eye";
                 "represents severe Inter-Symbol Interference (ISI).";
                 "";
                 "--- ENGINEERING NOTE ---";
                 "Pulse shaping (e.g. raised cosine) controls ISI.";
                 "";
                 "--- COMMON MISTAKES ---";
                 "- Plotting eye diagrams without proper clock synchronization."];
 
    case "constellation"
        lines = [lines;
                 "11. CONSTELLATION EXPLORER";
                 "";
                 "--- CONCEPT ---";
                 "Displays modulated symbols as points in the complex";
                 "I/Q vector plane.";
                 "";
                 "--- THEORY ---";
                 "Points cluster into clouds under noise; separation";
                 "distance dictates link budget error probability.";
                 "";
                 "--- ENGINEERING NOTE ---";
                 "Phase offsets rotate the entire constellation.";
                 "";
                 "--- COMMON MISTAKES ---";
                 "- Ignoring carrier synchronization phase offset loops."];
 
    case "comparison"
        lines = [lines;
                 "12. COMPARISON MODE";
                 "";
                 "--- CONCEPT ---";
                 "Compares spectral vs power efficiency trade-offs.";
                 "";
                 "--- THEORY ---";
                 "Spectral: 64QAM > BPSK; Power: BPSK > 64QAM.";
                 "";
                 "--- FORMULA ---";
                 "  Shannon limit: C = B * log2(1 + SNR) (bits/s)";
                 "";
                 "--- ENGINEERING NOTE ---";
                 "Coherent systems offer ~3dB gain over non-coherent.";
                 "";
                 "--- COMMON MISTAKES ---";
                 "- Selecting higher order M-ary schemes on noisy channels."];
                 
    else
        lines = [lines;
                 "No content available for this module."];
     end
     
     // Set edit box text (lines vector is displayed line by line)
     set(h_content, "string", lines);
endfunction
