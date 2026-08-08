// =============================================================================
// GUIVerse - Quantization Workspace Module
// File: src/communication/quantization/quantization.sci
// =============================================================================

function quantization_create_panel(fig, workspace_panel)
    // Instantiates the Quantization workspace page.
    
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
        "string", "3. Signal Quantization (Uniform vs. Non-uniform companding)", ...
        "HorizontalAlignment", "left");
    style_control(h_lbl_title, "header");
    set(h_lbl_title, "FontSize", colors.fs_header + 2);
    set(h_lbl_title, "BackgroundColor", colors.bg_workspace);
    t_panel = toc() * 1000;
    log_timing("Quantization - Panel & Banner Creation", t_panel);
    
    tic();
    mprintf("[INIT] Creating graphs...\n");
    // 3. Setup Plotting Axes Frame (Visual card frame only)
    c_plot = widgets_create_card(h_panel, "Quantized Staircase & Estimation Noise Residuals", [0.03, 0.38, 0.94, 0.54]);
    
    // Left Axes: Quantized Staircase
    ax_stair = newaxes(c_plot.frame);
    ax_stair.axes_bounds = [0.05, 0.12, 0.41, 0.72];
    style_axes_dark(ax_stair);
    ax_stair.visible = "off"; // Start hidden to prevent overlapping in background
    
    // Initialize original signal line (cyan solid)
    plot2d(0, 0);
    h_line_orig = ax_stair.children(1).children(1);
    set(h_line_orig, "foreground", color(colors.accent_cyan(1)*255, colors.accent_cyan(2)*255, colors.accent_cyan(3)*255));
    set(h_line_orig, "thickness", 2);
    
    // Initialize quantized staircase line (yellow solid)
    plot2d(0, 0);
    h_line_stair = ax_stair.children(1).children(1);
    set(h_line_stair, "foreground", color(colors.accent_yellow(1)*255, colors.accent_yellow(2)*255, colors.accent_yellow(3)*255));
    set(h_line_stair, "thickness", 1.5);
    
    // Right Axes: Quantization Error
    ax_error = newaxes(c_plot.frame);
    ax_error.axes_bounds = [0.54, 0.12, 0.41, 0.72];
    style_axes_dark(ax_error);
    ax_error.visible = "off"; // Start hidden to prevent overlapping in background
    
    // Initialize error waveform line (red solid)
    plot2d(0, 0);
    h_line_error = ax_error.children(1).children(1);
    set(h_line_error, "foreground", color(colors.accent_red(1)*255, colors.accent_red(2)*255, colors.accent_red(3)*255));
    set(h_line_error, "thickness", 1.5);
    
    // Cache axes and line handles in global state
    state.ui.quant_axes_stair = ax_stair;
    state.ui.quant_line_orig = h_line_orig;
    state.ui.quant_line_stair = h_line_stair;
    state.ui.quant_axes_error = ax_error;
    state.ui.quant_line_error = h_line_error;
    
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
    log_timing("Quantization - Plot & Axes Setup", t_plot);
    
    tic();
    // 4. Setup Control Card (Lower portion - visual frame only)
    c_ctrl = widgets_create_card(h_panel, "Quantization Parameters & SQNR Performance Analysis", [0.03, 0.03, 0.94, 0.33]);
    
    mprintf("[INIT] Creating sliders...\n");
    mprintf("[INIT] Creating labels...\n");
    mprintf("[INIT] Attaching callbacks...\n");
    
    // Create the parameter sliders & status edits directly under h_panel (absolute layout)
    // Map levels to discrete slider index [1..6] representing [2, 4, 8, 16, 32, 64]
    valid_levels = [2, 4, 8, 16, 32, 64];
    L = state.params.quantization.levels;
    [val, idx] = min(abs(valid_levels - L));
    
    // - Quantization Levels Slider
    levels_slider_group = widgets_create_slider(h_panel, "Quantization Levels (L)", 1.0, 6.0, idx, ...
        [0.05, 0.20, 0.42, 0.12], "cb_quant_slider()");
    
    // - Quantizer Type Dropdown Selection
    quant_options = ["1. Uniform Mid-Rise", "2. Uniform Mid-Tread (Coming Soon)", "3. Non-Uniform mu-Law Companding (mu=255)"];
    drop_idx = 1;
    select state.params.quantization.type
    case "uniform_midrise"
        drop_idx = 1;
    case "uniform_midtread"
        drop_idx = 2;
    case "mu_law"
        drop_idx = 3;
    end
    
    drop_group = widgets_create_dropdown(h_panel, "Quantization Law Selection", quant_options, drop_idx, ...
        [0.05, 0.06, 0.42, 0.12], "cb_quant_dropdown()");
    
    // - Dynamic Performance Status Label
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
    t_widgets = toc() * 1000;
    log_timing("Quantization - Widgets & Sliders Setup", t_widgets);
    
    tic();
    // 5. Store UI widget handles for live updates
    state.ui.quant_widgets = struct(...
        "levels_value", levels_slider_group.value, ...
        "levels_slider", levels_slider_group.slider, ...
        "type_dropdown", drop_group.popup, ...
        "status_label", h_status_lbl ...
    );
    
    // Save panel handle using list map helper
    state = ui_set_module_panel(state, "quantization", h_panel);
    fig.user_data = state;
    t_save = toc() * 1000;
    log_timing("Quantization - State Cache and Callback Binding", t_save);
endfunction

function ui_render_quantization(state)
    // Synchronizes the Quantization plots, sliders, and SQNR details with the current state.
    
    // 1. Verify handles exist and are valid
    if ~isfield(state.ui, "quant_widgets") then return; end
    w = state.ui.quant_widgets;
    ax_stair = state.ui.quant_axes_stair;
    h_orig = state.ui.quant_line_orig;
    h_stair = state.ui.quant_line_stair;
    ax_error = state.ui.quant_axes_error;
    h_error = state.ui.quant_line_error;
    
    if ~is_valid_handle(ax_stair) | ~is_valid_handle(h_orig) | ~is_valid_handle(h_stair) | ...
       ~is_valid_handle(ax_error) | ~is_valid_handle(h_error) then
        return;
    end
    
    colors = get_theme_colors();
    
    // 2. Synchronize Slider & Dropdown Display
    valid_levels = [2, 4, 8, 16, 32, 64];
    L = state.params.quantization.levels;
    [val, idx] = min(abs(valid_levels - L));
    
    set(w.levels_value, "string", sprintf("%d Levels", L));
    set(w.levels_slider, "Value", idx);
    
    drop_idx = 1;
    select state.params.quantization.type
    case "uniform_midrise"
        drop_idx = 1;
    case "uniform_midtread"
        drop_idx = 2;
    case "mu_law"
        drop_idx = 3;
    end
    set(w.type_dropdown, "Value", drop_idx);
    
    // 3. Update Text-Based SQNR & Statistics Monitor
    amp = state.params.signal.amp;
    delta = 2.0 * amp / L;
    bits_per_sample = round(log2(L));
    sqnr_measured = state.data.sqnr;
    
    // Theoretical SQNR for uniform sinusoidal quantization: 1.76 + 6.02 * N
    sqnr_theoretical = 1.76 + 6.02 * bits_per_sample;
    
    status_str = [...
        "QUANTIZATION PERFORMANCE LOGS";
        "";
        sprintf("Quantizer Type: %s", state.params.quantization.type);
        sprintf("Quantization Levels (L): %d  =>  Bit Depth (N): %d bits/sample", L, bits_per_sample);
        sprintf("Step Resolution (Delta): %.3f Volts", delta);
        "";
        sprintf("Measured System SQNR: %.2f dB", sqnr_measured);
        sprintf("Theoretical Sinusoidal SQNR: %.2f dB", sqnr_theoretical);
        "";
        sprintf("Peak Noise Residual (e_max): %.3f Volts", max(abs(state.data.quantization_error)));...
    ];
    
    // Update color based on SQNR threshold (e.g. green if > 15 dB)
    if sqnr_measured >= 15.0 then
        set(w.status_label, "ForegroundColor", colors.accent_cyan);
    else
        set(w.status_label, "ForegroundColor", colors.accent_yellow);
    end
    set(w.status_label, "string", status_str);
    
    // 4. Update Plot Line Data
    t = state.data.time;
    analog_wave = state.data.analog_waveform;
    quant_wave = state.data.quantized_waveform;
    error_wave = state.data.quantization_error;
    
    if isempty(t) | isempty(analog_wave) | isempty(quant_wave) | isempty(error_wave) then return; end
    
    // Decimate by 10 for performance
    dec_idx = 1:10:size(t, "*");
    h_orig.data = [t(dec_idx)', analog_wave(dec_idx)'];
    h_stair.data = [t(dec_idx)', quant_wave(dec_idx)'];
    h_error.data = [t(dec_idx)', error_wave(dec_idx)'];
    
    // Adjust data bounds
    y_limit = max(0.5, amp * 1.2);
    ax_stair.data_bounds = [0, -y_limit; 1.0, y_limit];
    ax_error.data_bounds = [0, -y_limit/2.0; 1.0, y_limit/2.0];
    
    // Update Axes labels & titles
    ax_stair.title.text = "Quantized Staircase";
    ax_stair.x_label.text = "Time (seconds)";
    ax_stair.y_label.text = "Amplitude (Volts)";
    
    ax_error.title.text = "Quantization Error";
    ax_error.x_label.text = "Time (seconds)";
    ax_error.y_label.text = "Error (Volts)";
endfunction
