// =============================================================================
// GUIVerse - Discrete Sampling and Sinc Reconstruction Module
// File: src/communication/sampling/sampling.sci
// =============================================================================

function sampling_create_panel(fig, workspace_panel)
    // Instantiates the Uniform Sampling workspace page.
    
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
        "string", "2. Uniform Sampling & Whittaker Sinc Reconstruction", ...
        "HorizontalAlignment", "left");
    style_control(h_lbl_title, "header");
    set(h_lbl_title, "FontSize", colors.fs_header + 2);
    set(h_lbl_title, "BackgroundColor", colors.bg_workspace);
    t_panel = toc() * 1000;
    log_timing("Sampling - Panel & Banner Creation", t_panel);
    
    tic();
    mprintf("[INIT] Creating graphs...\n");
    // 3. Setup Plotting Axes Frame (Visual frame only)
    c_plot = widgets_create_card(h_panel, "Reconstruction Fidelity vs. Discrete Sample Stems", [0.03, 0.38, 0.94, 0.54]);
    
    // Left Axes: Reconstruction Overlay
    ax_recon = newaxes(c_plot.frame);
    ax_recon.axes_bounds = [0.05, 0.12, 0.41, 0.72];
    style_axes_dark(ax_recon);
    ax_recon.visible = "off"; // Start hidden to prevent overlapping in background
    
    // Initialize original signal line (cyan solid)
    plot2d(0, 0);
    h_line_orig = ax_recon.children(1).children(1);
    set(h_line_orig, "foreground", color(colors.accent_cyan(1)*255, colors.accent_cyan(2)*255, colors.accent_cyan(3)*255));
    set(h_line_orig, "thickness", 2);
    
    // Initialize reconstructed signal line (magenta dashed)
    plot2d(0, 0);
    h_line_recon = ax_recon.children(1).children(1);
    set(h_line_recon, "foreground", color(colors.accent_red(1)*255, colors.accent_red(2)*255, colors.accent_red(3)*255));
    set(h_line_recon, "thickness", 1.5);
    set(h_line_recon, "line_style", 2);
    
    // Right Axes: Sample Stems
    ax_stems = newaxes(c_plot.frame);
    ax_stems.axes_bounds = [0.54, 0.12, 0.41, 0.72];
    style_axes_dark(ax_stems);
    ax_stems.visible = "off"; // Start hidden to prevent overlapping in background
    
    // Initialize vertical stems (plot2d3 type)
    plot2d(0, 0, style=0, rect=[0,-1,1,1]);
    h_line_stems = ax_stems.children(1).children(1);
    set(h_line_stems, "polyline_style", 3);
    set(h_line_stems, "foreground", color(colors.accent_blue(1)*255, colors.accent_blue(2)*255, colors.accent_blue(3)*255));
    set(h_line_stems, "thickness", 1.5);
    
    // Initialize sample circular markers
    plot2d(0, 0, style=-9);
    h_line_dots = ax_stems.children(1).children(1);
    set(h_line_dots, "foreground", color(colors.accent_green(1)*255, colors.accent_green(2)*255, colors.accent_green(3)*255));
    set(h_line_dots, "thickness", 1.5);
    
    // Cache axes and line handles in global state
    state.ui.sampling_axes_recon = ax_recon;
    state.ui.sampling_line_orig = h_line_orig;
    state.ui.sampling_line_recon = h_line_recon;
    state.ui.sampling_axes_stems = ax_stems;
    state.ui.sampling_line_stems = h_line_stems;
    state.ui.sampling_line_dots = h_line_dots;
    
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
    log_timing("Sampling - Plot & Axes Setup", t_plot);
    
    tic();
    // 4. Setup Control Card (Lower portion - visual card frame only)
    c_ctrl = widgets_create_card(h_panel, "Sampling Configuration & Live Nyquist Monitor", [0.03, 0.03, 0.94, 0.33]);
    
    mprintf("[INIT] Creating sliders...\n");
    mprintf("[INIT] Creating labels...\n");
    mprintf("[INIT] Attaching callbacks...\n");
    
    // Create the parameter sliders & status edits directly under h_panel (absolute layout)
    // - Sampling Rate Slider
    fs_slider_group = widgets_create_slider(h_panel, "Sampling Frequency (f_s)", 2.0, 100.0, state.params.sampling.fs, ...
        [0.05, 0.11, 0.42, 0.16], "cb_sampling_slider()");
    
    // - Dynamic Status Box (Read-only Edit container)
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
    log_timing("Sampling - Widgets & Sliders Setup", t_widgets);
    
    tic();
    // 5. Store UI widget handles for live updates
    state.ui.sampling_widgets = struct(...
        "fs_value", fs_slider_group.value, ...
        "fs_slider", fs_slider_group.slider, ...
        "status_label", h_status_lbl ...
    );
    
    // Save panel handle using list map helper
    state = ui_set_module_panel(state, "sampling", h_panel);
    fig.user_data = state;
    t_save = toc() * 1000;
    log_timing("Sampling - State Cache and Callback Binding", t_save);
endfunction

function ui_render_sampling(state)
    // Synchronizes the Sampling plots, sliders, and aliasing status with the current state.
    
    // 1. Verify handles exist and are valid
    if ~isfield(state.ui, "sampling_widgets") then return; end
    w = state.ui.sampling_widgets;
    ax_recon = state.ui.sampling_axes_recon;
    h_orig = state.ui.sampling_line_orig;
    h_recon = state.ui.sampling_line_recon;
    ax_stems = state.ui.sampling_axes_stems;
    h_stems = state.ui.sampling_line_stems;
    h_dots = state.ui.sampling_line_dots;
    
    if ~is_valid_handle(ax_recon) | ~is_valid_handle(h_orig) | ~is_valid_handle(h_recon) | ...
       ~is_valid_handle(ax_stems) | ~is_valid_handle(h_stems) | ~is_valid_handle(h_dots) then
        return;
    end
    
    colors = get_theme_colors();
    
    // 2. Synchronize Slider & Value text
    set(w.fs_value, "string", sprintf("%.2f Hz", state.params.sampling.fs));
    set(w.fs_slider, "Value", state.params.sampling.fs);
    
    // 3. Update Text-Based Nyquist & Aliasing Monitor
    f_max = state.params.signal.freq;
    f_nyq = 2.0 * f_max;
    fs = state.params.sampling.fs;
    rmse = state.data.reconstruction_error;
    
    status_str = [];
    if state.data.aliasing_present then
        status_str = [...
            "NYQUIST CRITERION: VIOLATED (f_s < 2 * f_m)";
            "";
            sprintf("Signal Frequency (f_m): %.1f Hz  =>  Nyquist Rate (2*f_m): %.1f Hz", f_max, f_nyq);
            sprintf("Current Sampling Rate (f_s): %.1f Hz", fs);
            sprintf("Reconstruction RMSE: %.3f V (High distortion)", rmse);
            "";
            "WARNING: Aliasing is occurring! The signal spectrum overlaps.";
            "Increase sampling frequency above the Nyquist rate to eliminate distortion."...
        ];
        set(w.status_label, "ForegroundColor", colors.accent_red);
    else
        status_str = [...
            "NYQUIST CRITERION: SATISFIED (f_s >= 2 * f_m)";
            "";
            sprintf("Signal Frequency (f_m): %.1f Hz  =>  Nyquist Rate (2*f_m): %.1f Hz", f_max, f_nyq);
            sprintf("Current Sampling Rate (f_s): %.1f Hz (Safe guard band)", fs);
            sprintf("Reconstruction RMSE: %.2e V (Near-perfect recovery)", rmse);
            "";
            "INFO: Whittaker-Shannon interpolation perfectly recovers the";
            "analog message waveform from the discrete samples."...
        ];
        set(w.status_label, "ForegroundColor", colors.accent_green);
    end
    set(w.status_label, "string", status_str);
    
    // 4. Update Plot Line Data
    t = state.data.time;
    analog_wave = state.data.analog_waveform;
    recon_wave = state.data.recovered_waveform;
    t_s = state.data.sampled_time;
    sampled_wave = state.data.sampled_waveform;
    
    if isempty(t) | isempty(analog_wave) | isempty(recon_wave) then return; end
    
    // Decimate continuous signals by 10 for performance
    dec_idx = 1:10:size(t, "*");
    h_orig.data = [t(dec_idx)', analog_wave(dec_idx)'];
    h_recon.data = [t(dec_idx)', recon_wave(dec_idx)'];
    
    // Update Sample stems on the right plot
    h_stems.data = [t_s', sampled_wave'];
    h_dots.data = [t_s', sampled_wave'];
    
    // Adjust data bounds
    y_limit = max(0.5, state.params.signal.amp * 1.2);
    ax_recon.data_bounds = [0, -y_limit; 1.0, y_limit];
    ax_stems.data_bounds = [0, -y_limit; 1.0, y_limit];
    
    // Update Axes labels & titles
    ax_recon.title.text = "Whittaker Reconstruction";
    ax_recon.x_label.text = "Time (seconds)";
    ax_recon.y_label.text = "Amplitude (Volts)";
    
    ax_stems.title.text = "Discrete Sample Stems";
    ax_stems.x_label.text = "Time (seconds)";
    ax_stems.y_label.text = "Sample Amplitudes (Volts)";
endfunction
