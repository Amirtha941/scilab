// =============================================================================
// GUIVerse - Persistent Workspace Layout Manager
// File: src/ui/workspace_manager.sci
// =============================================================================

function ui_create_persistent_workspace(fig, parent_workspace_panel)
    // Instantiates the single persistent workspace panel container and
    // pre-allocates all reusable controls (sliders, dropdowns, table boxes, axes, and line curves).
    
    colors = get_theme_colors();
    state = fig.user_data;
    
    mprintf("[INIT] Creating persistent workspace container...\n");
    // 1. Persistent Workspace Container Panel
    h_workspace = uicontrol(parent_workspace_panel, ...
        "style", "frame", ...
        "units", "normalized", ...
        "position", [0, 0, 1, 1], ...
        "visible", "off"); // Set visible to "off" on startup, shown on launch
    style_control(h_workspace, "card_frame");
    set(h_workspace, "BackgroundColor", colors.bg_workspace);
    
    // 2. Banner Title
    h_lbl_title = uicontrol(h_workspace, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [0.03, 0.94, 0.94, 0.04], ...
        "string", "Modular Virtual Engineering Laboratory Workspace", ...
        "HorizontalAlignment", "left");
    style_control(h_lbl_title, "header");
    set(h_lbl_title, "FontSize", colors.fs_header + 2);
    set(h_lbl_title, "BackgroundColor", colors.bg_workspace);
    
    // 3. Persistent Plot Card (visual card container)
    c_plot = widgets_create_card(h_workspace, "Time-Domain & Spectral Signal Visualization", [0.03, 0.38, 0.94, 0.54]);
    
    mprintf("[INIT] Creating graphs...\n");
    // 4. Pre-allocate Left Axes and curves
    ax_left = newaxes(c_plot.frame);
    ax_left.axes_bounds = [0.05, 0.12, 0.41, 0.72];
    style_axes_dark(ax_left);
    ax_left.visible = "on"; // Explicitly on during creation
    
    // - Create Curve Line 1 (left axes)
    plot2d(0, 0);
    h_line_left1 = ax_left.children(1).children(1);
    set(h_line_left1, "foreground", color(colors.accent_cyan(1)*255, colors.accent_cyan(2)*255, colors.accent_cyan(3)*255));
    set(h_line_left1, "thickness", 2);
    set(h_line_left1, "visible", "on"); // Explicitly visible
    
    // - Create Curve Line 2 (left axes)
    plot2d(0, 0);
    h_line_left2 = ax_left.children(1).children(1);
    set(h_line_left2, "foreground", color(colors.accent_red(1)*255, colors.accent_red(2)*255, colors.accent_red(3)*255));
    set(h_line_left2, "thickness", 1.5);
    set(h_line_left2, "line_style", 2);
    set(h_line_left2, "visible", "on"); // Explicitly visible
    
    // Set left axes visible to off AFTER child creation
    ax_left.visible = "off";
    
    // 5. Pre-allocate Right Axes and curves
    ax_right = newaxes(c_plot.frame);
    ax_right.axes_bounds = [0.54, 0.12, 0.41, 0.72];
    style_axes_dark(ax_right);
    ax_right.visible = "on"; // Explicitly on during creation
    
    // - Create Curve Line 1 (right axes)
    plot2d(0, 0);
    h_line_right1 = ax_right.children(1).children(1);
    set(h_line_right1, "foreground", color(colors.accent_blue(1)*255, colors.accent_blue(2)*255, colors.accent_blue(3)*255));
    set(h_line_right1, "thickness", 1.5);
    set(h_line_right1, "visible", "on"); // Explicitly visible
    
    // - Create Curve Line 2 (right axes)
    plot2d(0, 0);
    h_line_right2 = ax_right.children(1).children(1);
    set(h_line_right2, "foreground", color(colors.accent_green(1)*255, colors.accent_green(2)*255, colors.accent_green(3)*255));
    set(h_line_right2, "thickness", 1.5);
    set(h_line_right2, "visible", "on"); // Explicitly visible
    
    // Set right axes visible to off AFTER child creation
    ax_right.visible = "off";
    
    // - Expand Plot magnifying glass button next to card title
    h_expand_btn = uicontrol(h_workspace, ...
        "style", "pushbutton", ...
        "units", "normalized", ...
        "position", [0.91, 0.87, 0.04, 0.035], ...
        "string", "🔍", ...
        "callback", "cb_expand_plot()", ...
        "callback_type", 2);
    style_control(h_expand_btn, "action_button");
    set(h_expand_btn, "BackgroundColor", colors.accent_cyan);
    set(h_expand_btn, "FontSize", colors.fs_small);
    
    // 6. Persistent Parameters Card (visual container only)
    c_ctrl = widgets_create_card(h_workspace, "System Parameters Configuration", [0.03, 0.03, 0.94, 0.33]);
    
    mprintf("[INIT] Creating sliders...\n");
    mprintf("[INIT] Creating labels...\n");
    mprintf("[INIT] Attaching callbacks...\n");
    // 7. Pre-allocate Reusable Parameter Controls
    // - Reusable Slider 1 Group (e.g. Amplitude, fs, Levels)
    slider1_group = widgets_create_slider(h_workspace, "Parameter 1", 0.1, 10.0, 1.0, ...
        [0.05, 0.20, 0.42, 0.12], "cb_signal_slider()");
        
    // - Reusable Slider 2 Group (e.g. Frequency)
    slider2_group = widgets_create_slider(h_workspace, "Parameter 2", 0.5, 50.0, 5.0, ...
        [0.52, 0.20, 0.42, 0.12], "cb_signal_slider()");
        
    // - Reusable Slider 3 Group (e.g. Phase)
    slider3_group = widgets_create_slider(h_workspace, "Parameter 3", 0.0, 360.0, 0.0, ...
        [0.05, 0.06, 0.42, 0.12], "cb_signal_slider()");
        
    // - Reusable Dropdown Group (e.g. Waveform type, Companding Law)
    dropdown_group = widgets_create_dropdown(h_workspace, "Selection List", ["Option A"], 1, ...
        [0.52, 0.06, 0.42, 0.12], "cb_signal_dropdown()");
        
    // - Reusable Edit Box 1 (e.g. PCM scrollable word table)
    h_edit1 = uicontrol(h_workspace, ...
        "style", "edit", ...
        "units", "normalized", ...
        "position", [0.05, 0.05, 0.42, 0.29], ...
        "max", 2, "min", 0, "enable", "off", "string", "");
    style_control(h_edit1, "label");
    set(h_edit1, "BackgroundColor", colors.bg_panel);
    set(h_edit1, "ForegroundColor", colors.text_primary);
    set(h_edit1, "FontName", "monospaced");
    set(h_edit1, "FontSize", 8);
    set(h_edit1, "visible", "off");
    
    // - Reusable Edit Box 2 (e.g. Nyquist logs, SQNR logs, Link budget stats)
    h_edit2 = uicontrol(h_workspace, ...
        "style", "edit", ...
        "units", "normalized", ...
        "position", [0.50, 0.05, 0.45, 0.29], ...
        "max", 2, "min", 0, "enable", "off", "string", "");
    style_control(h_edit2, "label");
    set(h_edit2, "BackgroundColor", colors.bg_panel);
    set(h_edit2, "ForegroundColor", colors.text_primary);
    set(h_edit2, "FontName", "monospaced");
    set(h_edit2, "FontSize", 8);
    set(h_edit2, "visible", "off");
    
    // 8. Cache persistent handles in state.ui.workspace
    state.ui.workspace = struct(...
        "panel", h_workspace, ...
        "title", h_lbl_title, ...
        "plot_card", c_plot.frame, ...
        "ctrl_card", c_ctrl.frame, ...
        "plot_card_hdr", c_plot.header, ...
        "ctrl_card_hdr", c_ctrl.header, ...
        "ax_left", ax_left, ...
        "ax_right", ax_right, ...
        "line_left1", h_line_left1, ...
        "line_left2", h_line_left2, ...
        "line_right1", h_line_right1, ...
        "line_right2", h_line_right2, ...
        "slider1", slider1_group, ...
        "slider2", slider2_group, ...
        "slider3", slider3_group, ...
        "dropdown", dropdown_group, ...
        "edit1", h_edit1, ...
        "edit2", h_edit2, ...
        "expand_btn", h_expand_btn ...
    );
    
    // 9. MAP LEGACY WIDGET HANDLES directly to persistent handles for renderer reuse!
    state.ui.signal_axes = ax_left;
    state.ui.signal_line = h_line_left1;
    state.ui.signal_generator_widgets = struct(...
        "amp_value", slider1_group.value, ...
        "freq_value", slider2_group.value, ...
        "phase_value", slider3_group.value, ...
        "amp_slider", slider1_group.slider, ...
        "freq_slider", slider2_group.slider, ...
        "phase_slider", slider3_group.slider, ...
        "type_dropdown", dropdown_group.popup ...
    );
    
    state.ui.sampling_axes_recon = ax_left;
    state.ui.sampling_line_orig = h_line_left1;
    state.ui.sampling_line_recon = h_line_left2;
    state.ui.sampling_axes_stems = ax_right;
    state.ui.sampling_line_stems = h_line_right1;
    state.ui.sampling_line_dots = h_line_right2;
    state.ui.sampling_widgets = struct(...
        "fs_value", slider1_group.value, ...
        "fs_slider", slider1_group.slider, ...
        "status_label", h_edit2 ...
    );
    
    state.ui.quant_axes_stair = ax_left;
    state.ui.quant_line_orig = h_line_left1;
    state.ui.quant_line_stair = h_line_left2;
    state.ui.quant_axes_error = ax_right;
    state.ui.quant_line_error = h_line_right1;
    state.ui.quant_widgets = struct(...
        "levels_value", slider1_group.value, ...
        "levels_slider", slider1_group.slider, ...
        "type_dropdown", dropdown_group.popup, ...
        "status_label", h_edit2 ...
    );
    
    state.ui.pcm_axes_recon = ax_left;
    state.ui.pcm_line_orig = h_line_left1;
    state.ui.pcm_line_recon = h_line_left2;
    state.ui.pcm_axes_bits = ax_right;
    state.ui.pcm_line_bits = h_line_right1;
    state.ui.pcm_widgets = struct(...
        "table_box", h_edit1, ...
        "status_label", h_edit2 ...
    );
    
    // Save panel mapping to system registry
    state = ui_set_module_panel(state, "signal_generator", h_workspace);
    state = ui_set_module_panel(state, "sampling", h_workspace);
    state = ui_set_module_panel(state, "quantization", h_workspace);
    state = ui_set_module_panel(state, "pcm", h_workspace);
    
    fig.user_data = state;
endfunction

function ui_configure_workspace(module_name, state)
    // Dynamic layout router. Shows, positions, and configures labels, callbacks, and dropdowns
    // on the persistent workspace in place without rebuilding Swing components.
    
    w = state.ui.workspace;
    colors = get_theme_colors();
    
    resolved_name = module_name;
    if module_name == "sampling_uniform" | module_name == "sampling_recon" then
        resolved_name = "sampling";
    elseif module_name == "quant_uniform" | module_name == "quant_nonuniform" then
        resolved_name = "quantization";
    elseif module_name == "pcm_encoder" | module_name == "pcm_serialized" then
        resolved_name = "pcm";
    end
    
    select resolved_name
    case "signal_generator"
        // 1. Banner Title
        set(w.title, "string", "1. Analog Message Source Generator");
        
        // 2. Axes Configuration: Left Axes occupies full card width
        if isfield(w, "plot_card_hdr") then set(w.plot_card_hdr, "string", "Time-Domain Message Waveform"); end
        set(w.plot_card, "string", "Time-Domain Message Waveform");
        w.ax_left.axes_bounds = [0.06, 0.12, 0.90, 0.72];
        
        // Restore left axes lines to standard styles
        set(w.line_left1, "line_style", 1);
        set(w.line_left1, "visible", "on"); // Explicitly set primary line visible
        set(w.line_left2, "visible", "off");
        
        // 3. Reusable Controls Visibility & Configuration
        if isfield(w, "ctrl_card_hdr") then set(w.ctrl_card_hdr, "string", "Signal Parameters Configuration"); end
        set(w.ctrl_card, "string", "Signal Parameters Configuration");
        
        // - Slider 1 (Amplitude)
        set(w.slider1.label, "visible", "on");
        set(w.slider1.label, "string", "Amplitude (A_m)");
        set(w.slider1.value, "visible", "on");
        set(w.slider1.slider, "visible", "on");
        set(w.slider1.slider, "Min", 0.1);
        set(w.slider1.slider, "Max", 10.0);
        set(w.slider1.slider, "Value", state.params.signal.amp);
        set(w.slider1.slider, "user_data", "amp");
        set(w.slider1.slider, "callback", "cb_signal_slider()");
        
        // - Slider 2 (Frequency)
        set(w.slider2.label, "visible", "on");
        set(w.slider2.label, "string", "Frequency (f_m)");
        set(w.slider2.value, "visible", "on");
        set(w.slider2.slider, "visible", "on");
        set(w.slider2.slider, "Min", 0.5);
        set(w.slider2.slider, "Max", 50.0);
        set(w.slider2.slider, "Value", state.params.signal.freq);
        set(w.slider2.slider, "user_data", "freq");
        set(w.slider2.slider, "callback", "cb_signal_slider()");
        
        // - Slider 3 (Phase)
        set(w.slider3.label, "visible", "on");
        set(w.slider3.label, "string", "Phase Shift (theta)");
        set(w.slider3.value, "visible", "on");
        set(w.slider3.slider, "visible", "on");
        set(w.slider3.slider, "Min", 0.0);
        set(w.slider3.slider, "Max", 360.0);
        set(w.slider3.slider, "Value", state.params.signal.phase);
        set(w.slider3.slider, "user_data", "phase");
        set(w.slider3.slider, "callback", "cb_signal_slider()");
        
        // - Dropdown 1 (Waveform Selection)
        set(w.dropdown.label, "visible", "on");
        set(w.dropdown.label, "string", "Waveform Type Selection");
        set(w.dropdown.popup, "visible", "on");
        set(w.dropdown.popup, "string", "1. Cosine Waveform|2. Square Pulse Train|3. Triangle Waveform|4. Pseudo-Random Binary Sequence (PRBS)");
        set(w.dropdown.popup, "callback", "cb_signal_dropdown()");
        
        dropdown_idx = 1;
        select state.params.signal.type
        case "sine"
            dropdown_idx = 1;
        case "square"
            dropdown_idx = 2;
        case "triangle"
            dropdown_idx = 3;
        case "prbs"
            dropdown_idx = 4;
        end
        set(w.dropdown.popup, "Value", dropdown_idx);
        
        // - Hide PCM logs and Nyquist logs
        set(w.edit1, "visible", "off");
        set(w.edit2, "visible", "off");
        
    case "sampling"
        // 1. Banner Title
        set(w.title, "string", "2. Uniform Sampling & Whittaker Sinc Reconstruction");
        
        // 2. Axes Configuration: Dual plot mode
        if isfield(w, "plot_card_hdr") then set(w.plot_card_hdr, "string", "Reconstruction Fidelity vs. Discrete Sample Stems"); end
        set(w.plot_card, "string", "Reconstruction Fidelity vs. Discrete Sample Stems");
        w.ax_left.axes_bounds = [0.05, 0.12, 0.41, 0.72];
        w.ax_right.axes_bounds = [0.54, 0.12, 0.41, 0.72];
        
        // Restore standard styles for Sampling curves
        set(w.line_left1, "foreground", color(colors.accent_cyan(1)*255, colors.accent_cyan(2)*255, colors.accent_cyan(3)*255));
        set(w.line_left1, "line_style", 1);
        set(w.line_left1, "visible", "on"); // Explicitly set primary line visible
        set(w.line_left2, "visible", "on");
        set(w.line_left2, "line_style", 2);
        
        // Configure stems style for right axes Line 1
        set(w.line_right1, "polyline_style", 3);
        set(w.line_right1, "foreground", color(colors.accent_blue(1)*255, colors.accent_blue(2)*255, colors.accent_blue(3)*255));
        set(w.line_right1, "visible", "on"); // Explicitly set primary line visible
        
        // Configure circular dots (markers-only) style for right axes Line 2.
        // polyline_style=0 is invalid in Scilab 2025 (range is 1-7).
        // The correct way for marks-only display is: line_mode off, mark_mode on.
        set(w.line_right2, "line_mode", "off");
        set(w.line_right2, "mark_mode", "on");
        set(w.line_right2, "mark_style", 9);   // 9 = open circle marker
        set(w.line_right2, "mark_size", 4);
        set(w.line_right2, "foreground", color(colors.accent_green(1)*255, colors.accent_green(2)*255, colors.accent_green(3)*255));
        set(w.line_right2, "visible", "on");
        
        // 3. Reusable Controls Visibility & Configuration
        if isfield(w, "ctrl_card_hdr") then set(w.ctrl_card_hdr, "string", "Sampling Configuration & Live Nyquist Monitor"); end
        set(w.ctrl_card, "string", "Sampling Configuration & Live Nyquist Monitor");
        
        // - Slider 1 (Sampling fs) - Occupies left half vertically centered
        set(w.slider1.label, "visible", "on");
        set(w.slider1.label, "string", "Sampling Frequency (f_s)");
        set(w.slider1.value, "visible", "on");
        set(w.slider1.slider, "visible", "on");
        set(w.slider1.slider, "Min", 2.0);
        set(w.slider1.slider, "Max", 100.0);
        set(w.slider1.slider, "Value", state.params.sampling.fs);
        set(w.slider1.slider, "callback", "cb_sampling_slider()");
        
        // - Hide Sliders 2 & 3 and Dropdown 1
        set(w.slider2.label, "visible", "off");
        set(w.slider2.value, "visible", "off");
        set(w.slider2.slider, "visible", "off");
        set(w.slider3.label, "visible", "off");
        set(w.slider3.value, "visible", "off");
        set(w.slider3.slider, "visible", "off");
        set(w.dropdown.label, "visible", "off");
        set(w.dropdown.popup, "visible", "off");
        
        // - Hide Edit Box 1, Show Edit Box 2 (Nyquist Log) on right half
        set(w.edit1, "visible", "off");
        set(w.edit2, "visible", "on");
        
    case "quantization"
        // 1. Banner Title
        set(w.title, "string", "3. Signal Quantization (Uniform vs. Non-uniform companding)");
        
        // 2. Axes Configuration: Dual plot mode
        if isfield(w, "plot_card_hdr") then set(w.plot_card_hdr, "string", "Quantized Staircase & Estimation Noise Residuals"); end
        set(w.plot_card, "string", "Quantized Staircase & Estimation Noise Residuals");
        w.ax_left.axes_bounds = [0.05, 0.12, 0.41, 0.72];
        w.ax_right.axes_bounds = [0.54, 0.12, 0.41, 0.72];
        
        // Restore standard styles for Quantization curves
        set(w.line_left1, "foreground", color(colors.accent_cyan(1)*255, colors.accent_cyan(2)*255, colors.accent_cyan(3)*255));
        set(w.line_left1, "line_style", 1);
        set(w.line_left1, "visible", "on"); // Explicitly set primary line visible
        set(w.line_left2, "visible", "on");
        set(w.line_left2, "line_style", 1); // staircase is solid line
        set(w.line_left2, "foreground", color(colors.accent_yellow(1)*255, colors.accent_yellow(2)*255, colors.accent_yellow(3)*255));
        
        // Configure error curve style for right axes Line 1
        set(w.line_right1, "polyline_style", 1); // solid error curve
        set(w.line_right1, "foreground", color(colors.accent_red(1)*255, colors.accent_red(2)*255, colors.accent_red(3)*255));
        set(w.line_right1, "visible", "on"); // Explicitly set primary line visible
        
        // Hide right axes Line 2 (not used). Reset mark/line mode so it can be
        // reused as a standard line when the workspace switches to another module.
        set(w.line_right2, "mark_mode", "off");
        set(w.line_right2, "line_mode", "on");
        set(w.line_right2, "visible", "off");
        
        // 3. Reusable Controls Visibility & Configuration
        if isfield(w, "ctrl_card_hdr") then set(w.ctrl_card_hdr, "string", "Quantization Parameters & SQNR Performance Analysis"); end
        set(w.ctrl_card, "string", "Quantization Parameters & SQNR Performance Analysis");
        
        // Map L levels to discrete index [1..6] representing [2, 4, 8, 16, 32, 64]
        valid_levels = [2, 4, 8, 16, 32, 64];
        L = state.params.quantization.levels;
        [val, idx] = min(abs(valid_levels - L));
        
        // - Slider 1 (Quantization Levels)
        set(w.slider1.label, "visible", "on");
        set(w.slider1.label, "string", "Quantization Levels (L)");
        set(w.slider1.value, "visible", "on");
        set(w.slider1.slider, "visible", "on");
        set(w.slider1.slider, "Min", 1.0);
        set(w.slider1.slider, "Max", 6.0);
        set(w.slider1.slider, "Value", idx);
        set(w.slider1.slider, "callback", "cb_quantization_slider()");
        
        // - Hide Slider 2 & 3
        set(w.slider2.label, "visible", "off");
        set(w.slider2.value, "visible", "off");
        set(w.slider2.slider, "visible", "off");
        set(w.slider3.label, "visible", "off");
        set(w.slider3.value, "visible", "off");
        set(w.slider3.slider, "visible", "off");
        
        // - Show Dropdown 1 (Quantizer Selection) on the bottom left
        set(w.dropdown.label, "visible", "on");
        set(w.dropdown.label, "string", "Quantization Law Selection");
        set(w.dropdown.popup, "visible", "on");
        set(w.dropdown.popup, "string", "1. Uniform Mid-Rise|2. Uniform Mid-Tread (Coming Soon)|3. Non-Uniform mu-Law Companding (mu=255)");
        set(w.dropdown.popup, "callback", "cb_quantization_dropdown()");
        
        dropdown_idx = 1;
        select state.params.quantization.type
        case "uniform_midrise"
            dropdown_idx = 1;
        case "uniform_midtread"
            dropdown_idx = 2;
        case "mu_law"
            dropdown_idx = 3;
        end
        set(w.dropdown.popup, "Value", dropdown_idx);
        
        // - Hide Edit Box 1, Show Edit Box 2 (SQNR logs) on the right half
        set(w.edit1, "visible", "off");
        set(w.edit2, "visible", "on");
        
    case "pcm"
        // 1. Banner Title
        set(w.title, "string", "4. Pulse Code Modulation (PCM) Encoder & Link Budget");
        
        // 2. Axes Configuration: Dual plot mode
        if isfield(w, "plot_card_hdr") then set(w.plot_card_hdr, "string", "PCM Reconstructed Waveform & Serialized Logic Bitstream"); end
        set(w.plot_card, "string", "PCM Reconstructed Waveform & Serialized Logic Bitstream");
        w.ax_left.axes_bounds = [0.05, 0.12, 0.41, 0.72];
        w.ax_right.axes_bounds = [0.54, 0.12, 0.41, 0.72];
        
        // Restore standard styles for PCM curves
        set(w.line_left1, "foreground", color(colors.accent_cyan(1)*255, colors.accent_cyan(2)*255, colors.accent_cyan(3)*255));
        set(w.line_left1, "line_style", 1);
        set(w.line_left1, "visible", "on"); // Explicitly set primary line visible
        set(w.line_left2, "visible", "on");
        set(w.line_left2, "line_style", 2);
        set(w.line_left2, "foreground", color(colors.accent_red(1)*255, colors.accent_red(2)*255, colors.accent_red(3)*255));
        
        // Configure bits curve style for right axes Line 1
        set(w.line_right1, "polyline_style", 1); // solid digital bits line
        set(w.line_right1, "foreground", color(colors.accent_green(1)*255, colors.accent_green(2)*255, colors.accent_green(3)*255));
        set(w.line_right1, "visible", "on"); // Explicitly set primary line visible
        
        // Hide right axes Line 2 (not used). Reset mark/line mode so it can be
        // reused as a standard line when the workspace switches to another module.
        set(w.line_right2, "mark_mode", "off");
        set(w.line_right2, "line_mode", "on");
        set(w.line_right2, "visible", "off");
        
        // 3. Reusable Controls Visibility & Configuration
        if isfield(w, "ctrl_card_hdr") then set(w.ctrl_card_hdr, "string", "PCM Binary Word Mapping & Link Budget Statistics"); end
        set(w.ctrl_card, "string", "PCM Binary Word Mapping & Link Budget Statistics");
        
        // - Hide all Sliders & Dropdowns (PCM only uses lists & metrics text)
        set(w.slider1.label, "visible", "off");
        set(w.slider1.value, "visible", "off");
        set(w.slider1.slider, "visible", "off");
        set(w.slider2.label, "visible", "off");
        set(w.slider2.value, "visible", "off");
        set(w.slider2.slider, "visible", "off");
        set(w.slider3.label, "visible", "off");
        set(w.slider3.value, "visible", "off");
        set(w.slider3.slider, "visible", "off");
        set(w.dropdown.label, "visible", "off");
        set(w.dropdown.popup, "visible", "off");
        
        // - Show Edit Box 1 (PCM Table) and Edit Box 2 (Link Budget logs)
        set(w.edit1, "visible", "on");
        set(w.edit2, "visible", "on");
    end
endfunction
