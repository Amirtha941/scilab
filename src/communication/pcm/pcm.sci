// =============================================================================
// GUIVerse - PCM Encoder and Serializer Module
// File: src/communication/pcm/pcm.sci
// =============================================================================

function pcm_create_panel(fig, workspace_panel)
    // Instantiates the PCM workspace page.
    
    colors = get_theme_colors();
    state = fig.user_data;
    
    tic();
    // 1. Module Container Panel
    h_panel = uicontrol(workspace_panel, ...
        "style", "frame", ...
        "units", "normalized", ...
        "position", [0, 0, 1, 1], ...
        "visible", "off");
    style_control(h_panel, "card_frame");
    set(h_panel, "BackgroundColor", colors.bg_workspace);
    
    // 2. Title Banner
    h_lbl_title = uicontrol(h_panel, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [0.03, 0.94, 0.94, 0.04], ...
        "string", "4. Pulse Code Modulation (PCM) Encoder & Link Budget", ...
        "HorizontalAlignment", "left");
    style_control(h_lbl_title, "header");
    set(h_lbl_title, "FontSize", colors.fs_header + 2);
    set(h_lbl_title, "BackgroundColor", colors.bg_workspace);
    t_panel = toc() * 1000;
    log_timing("PCM - Panel & Banner Creation", t_panel);
    
    tic();
    mprintf("[INIT] Creating graphs...\n");
    // 3. Setup Plotting Axes Frame (Visual card frame only)
    c_plot = widgets_create_card(h_panel, "PCM Reconstructed Waveform & Serialized Logic Bitstream", [0.03, 0.38, 0.94, 0.54]);
    
    // Left Axes: Continuous Recovery Comparison
    ax_recon = newaxes(c_plot.frame);
    ax_recon.axes_bounds = [0.05, 0.12, 0.41, 0.72];
    style_axes_dark(ax_recon);
    ax_recon.visible = "off"; // Start hidden to prevent overlapping in background
    
    // Initialize original signal line (cyan solid)
    plot2d(0, 0);
    h_line_orig = ax_recon.children(1).children(1);
    set(h_line_orig, "foreground", color(colors.accent_cyan(1)*255, colors.accent_cyan(2)*255, colors.accent_cyan(3)*255));
    set(h_line_orig, "thickness", 2);
    
    // Initialize recovered signal line (magenta dashed)
    plot2d(0, 0);
    h_line_recon = ax_recon.children(1).children(1);
    set(h_line_recon, "foreground", color(colors.accent_red(1)*255, colors.accent_red(2)*255, colors.accent_red(3)*255));
    set(h_line_recon, "thickness", 1.5);
    set(h_line_recon, "line_style", 2);
    
    // Right Axes: Serial Bitstream Pulses
    ax_bits = newaxes(c_plot.frame);
    ax_bits.axes_bounds = [0.54, 0.12, 0.41, 0.72];
    style_axes_dark(ax_bits);
    ax_bits.visible = "off"; // Start hidden to prevent overlapping in background
    
    // Initialize serial bits waveform (green solid)
    plot2d(0, 0);
    h_line_bits = ax_bits.children(1).children(1);
    set(h_line_bits, "foreground", color(colors.accent_green(1)*255, colors.accent_green(2)*255, colors.accent_green(3)*255));
    set(h_line_bits, "thickness", 2);
    
    // Cache axes and line handles in global state
    state.ui.pcm_axes_recon = ax_recon;
    state.ui.pcm_line_orig = h_line_orig;
    state.ui.pcm_line_recon = h_line_recon;
    state.ui.pcm_axes_bits = ax_bits;
    state.ui.pcm_line_bits = h_line_bits;
    
    // Expand plot preview button (unobtrusive magnifying glass icon)
    h_expand_btn = uicontrol(h_panel, ...
        "style", "pushbutton", ...
        "units", "normalized", ...
        "position", [0.91, 0.87, 0.04, 0.035], ...
        "string", "🔍", ...
        "callback", "cb_expand_plot()", ...
        "callback_type", 2);
    style_control(h_expand_btn, "action_button");
    set(h_expand_btn, "BackgroundColor", colors.accent_cyan);
    set(h_expand_btn, "FontSize", colors.fs_small);
    t_plot = toc() * 1000;
    log_timing("PCM - Plot & Axes Setup", t_plot);
    
    tic();
    // 4. Setup Control Card (Lower portion - visual frame only)
    c_ctrl = widgets_create_card(h_panel, "PCM Binary Word Mapping & Link Budget Statistics", [0.03, 0.03, 0.94, 0.33]);
    
    mprintf("[INIT] Creating sliders...\n");
    mprintf("[INIT] Creating labels...\n");
    mprintf("[INIT] Attaching callbacks...\n");
    
    // Create the parameter tables & labels directly under h_panel (absolute layout)
    // - Left Panel: Read-only Scrollable Binary Mapping Table
    h_table_box = uicontrol(h_panel, ...
        "style", "edit", ...
        "units", "normalized", ...
        "position", [0.05, 0.05, 0.42, 0.29], ...
        "max", 2, ...
        "min", 0, ...
        "enable", "off", ...
        "string", "");
    style_control(h_table_box, "label");
    set(h_table_box, "BackgroundColor", colors.bg_panel);
    set(h_table_box, "ForegroundColor", colors.text_primary);
    set(h_table_box, "FontName", "monospaced");
    set(h_table_box, "FontSize", 8);
    
    // - Right Panel: Link Budget Statistics
    h_status_lbl = uicontrol(h_panel, ...
        "style", "edit", ...
        "units", "normalized", ...
        "position", [0.50, 0.05, 0.45, 0.29], ...
        "max", 2, ...
        "min", 0, ...
        "enable", "off", ...
        "string", "");
    style_control(h_status_lbl, "label");
    set(h_status_lbl, "BackgroundColor", colors.bg_panel);
    set(h_status_lbl, "ForegroundColor", colors.text_primary);
    set(h_status_lbl, "FontName", "monospaced");
    set(h_status_lbl, "FontSize", 8);
    t_widgets = toc() * 1000;
    log_timing("PCM - Widgets & Sliders Setup", t_widgets);
    
    tic();
    // 5. Store UI widget handles for live updates
    state.ui.pcm_widgets = struct(...
        "table_box", h_table_box, ...
        "status_label", h_status_lbl ...
    );
    
    // Save panel handle using list map helper
    state = ui_set_module_panel(state, "pcm", h_panel);
    fig.user_data = state;
    t_save = toc() * 1000;
    log_timing("PCM - State Cache and Callback Binding", t_save);
endfunction

function ui_render_pcm(state)
    // Synchronizes the PCM plots, tables, and link metrics with the current state.
    
    // 1. Verify handles exist and are valid
    if ~isfield(state.ui, "pcm_widgets") then return; end
    w = state.ui.pcm_widgets;
    ax_recon = state.ui.pcm_axes_recon;
    h_orig = state.ui.pcm_line_orig;
    h_recon = state.ui.pcm_line_recon;
    ax_bits = state.ui.pcm_axes_bits;
    h_bits = state.ui.pcm_line_bits;
    
    if ~is_valid_handle(ax_recon) | ~is_valid_handle(h_orig) | ~is_valid_handle(h_recon) | ...
       ~is_valid_handle(ax_bits) | ~is_valid_handle(h_bits) then
        return;
    end
    
    colors = get_theme_colors();
    
    // 2. Build the Live Sample Index Mapping Table
    t_s = state.data.sampled_time;
    sampled_wave = state.data.sampled_waveform;
    quant_samples = state.data.quantized_samples;
    indices = state.data.pcm_indices;
    bin_words = state.data.pcm_binary_words;
    
    N_samples = size(sampled_wave, "*");
    
    table_lines = [...
        "Sample # | Time (s) | Sample (V) | Quant (V)  | Code Index | Binary Word";
        "-------------------------------------------------------------------------";...
    ];
    
    // Show up to the first 25 samples in the table to avoid scroll clutter
    show_samples = min(25, N_samples);
    for n = 1:show_samples
        line_str = sprintf("  %02d     |  %.3f   |   %+.3f    |   %+.3f    |    %02d      |   %s", ...
            n, t_s(n), sampled_wave(n), quant_samples(n), indices(n), bin_words(n));
        table_lines = [table_lines; line_str];
    end
    
    if N_samples > 25 then
        table_lines = [table_lines; "... (table truncated, showing first 25 samples)"];
    end
    set(w.table_box, "string", table_lines);
    
    // 3. Update Text-Based Link Budget Statistics
    L = state.params.quantization.levels;
    fs = state.params.sampling.fs;
    N_bits = round(log2(L));
    bit_rate = state.data.pcm_bit_rate;
    bitstream = state.data.pcm_bitstream;
    
    // Format bitstream array as a string
    bits_to_format = min(40, size(bitstream, "*"));
    bitstream_str = "";
    for k = 1:bits_to_format
        bitstream_str = bitstream_str + string(bitstream(k));
    end
    if size(bitstream, "*") > 40 then
        bitstream_str = bitstream_str + "...";
    end
    
    status_str = [...
        "PCM LINK BUDGET STATISTICS";
        "";
        sprintf("Sampling Frequency (f_s): %.1f samples/second", fs);
        sprintf("PCM Word Length (N): %d bits/sample", N_bits);
        sprintf("Total Samples Transmitted: %d", N_samples);
        sprintf("Total Serialized Bits: %d bits", size(bitstream, "*"));
        "";
        sprintf("Calculated Serial Bit Rate (R_b): %.1f bits/second", bit_rate);
        sprintf("Minimum Transmission Bandwidth (B_min): %.1f Hz", bit_rate / 2.0);
        "";
        "Serialized Bitstream Preview:";
        "  " + bitstream_str;...
    ];
    set(w.status_label, "ForegroundColor", colors.accent_cyan);
    set(w.status_label, "string", status_str);
    
    // 4. Update Reconstructed Waveform Plots
    t = state.data.time;
    analog_wave = state.data.analog_waveform;
    recovered_wave = state.data.pcm_recovered_waveform;
    
    if isempty(t) | isempty(analog_wave) | isempty(recovered_wave) then return; end
    
    // Decimate for performance
    dec_idx = 1:10:size(t, "*");
    h_orig.data = [t(dec_idx)', analog_wave(dec_idx)'];
    h_recon.data = [t(dec_idx)', recovered_wave(dec_idx)'];
    
    // 5. Update Digital Bitstream Plot (Rectangular steps for the first 30 bits)
    bits_to_show = min(30, size(bitstream, "*"));
    sub_stream = bitstream(1:bits_to_show);
    
    // Build rectangular pulse train coordinates
    // We map a bit interval to 1 unit on the horizontal axis
    t_bits_plot = [];
    y_bits_plot = [];
    for k = 1:bits_to_show
        t_bits_plot = [t_bits_plot, k-1, k];
        y_bits_plot = [y_bits_plot, sub_stream(k), sub_stream(k)];
    end
    
    h_bits.data = [t_bits_plot', y_bits_plot'];
    
    // Adjust boundaries
    y_limit = max(0.5, state.params.signal.amp * 1.2);
    ax_recon.data_bounds = [0, -y_limit; 1.0, y_limit];
    ax_bits.data_bounds = [0, -0.2; bits_to_show, 1.2];
    
    // Update Axes labels & titles
    ax_recon.title.text = "Recovered Waveform";
    ax_recon.x_label.text = "Time (seconds)";
    ax_recon.y_label.text = "Amplitude (Volts)";
    
    ax_bits.title.text = "Serialized Bitstream";
    ax_bits.x_label.text = "Bit Index";
    ax_bits.y_label.text = "Logic Level";
endfunction
