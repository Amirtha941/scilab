// =============================================================================
// GUIVerse - Signal Generator Workspace Module
// File: src/communication/analog_signal/signal_generator.sci
// =============================================================================

function signal_generator_create_panel(fig, workspace_panel)
    // Instantiates the Signal Generator workspace page.
    // Adds the plotting axes in the upper portion and control parameters in the lower.
    
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
        "string", "1. Analog Message Source Generator", ...
        "HorizontalAlignment", "left");
    style_control(h_lbl_title, "header");
    set(h_lbl_title, "FontSize", colors.fs_header + 2);
    set(h_lbl_title, "BackgroundColor", colors.bg_workspace);
    t_panel = toc() * 1000;
    log_timing("Signal Generator - Panel & Banner Creation", t_panel);
    
    tic();
    // 3. Setup Plotting Axes Frame
    mprintf("[INIT] Creating graphs...\n");
    c_plot = widgets_create_card(h_panel, "Time-Domain Message Waveform", [0.03, 0.38, 0.94, 0.54]);
    
    // Create native axes inside the card frame
    ax = newaxes(c_plot.frame);
    ax.axes_bounds = [0.06, 0.12, 0.90, 0.72];
    style_axes_dark(ax);
    ax.visible = "off"; // Start hidden to prevent overlapping in background
    
    // Initialize an empty plot line (polyline) to reuse
    plot2d(0, 0);
    h_line = ax.children(1).children(1);
    set(h_line, "foreground", color(colors.accent_cyan(1)*255, colors.accent_cyan(2)*255, colors.accent_cyan(3)*255));
    set(h_line, "thickness", 2);
    
    // Cache the axes and line handles in global state
    state.ui.signal_axes = ax;
    state.ui.signal_line = h_line;
    
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
    log_timing("Signal Generator - Plot & Axes Setup", t_plot);
    
    tic();
    // 4. Setup Control Parameters Card (Visual frame only)
    c_ctrl = widgets_create_card(h_panel, "Signal Parameters Configuration", [0.03, 0.03, 0.94, 0.33]);
    
    mprintf("[INIT] Creating sliders...\n");
    mprintf("[INIT] Creating labels...\n");
    mprintf("[INIT] Attaching callbacks...\n");
    
    // Create the parameter sliders & dropdown directly under h_panel (absolute layout)
    // - Amplitude Slider
    amp_slider_group = widgets_create_slider(h_panel, "Amplitude (A_m)", 0.1, 10.0, state.params.signal.amp, ...
        [0.05, 0.20, 0.42, 0.12], "cb_signal_slider()");
    set(amp_slider_group.slider, "user_data", "amp");
    
    // - Frequency Slider
    freq_slider_group = widgets_create_slider(h_panel, "Frequency (f_m)", 0.5, 50.0, state.params.signal.freq, ...
        [0.52, 0.20, 0.42, 0.12], "cb_signal_slider()");
    set(freq_slider_group.slider, "user_data", "freq");
    
    // - Phase Slider
    phase_slider_group = widgets_create_slider(h_panel, "Phase Shift (theta)", 0.0, 360.0, state.params.signal.phase, ...
        [0.05, 0.06, 0.42, 0.12], "cb_signal_slider()");
    set(phase_slider_group.slider, "user_data", "phase");
    
    // - Waveform Type Dropdown
    waveform_types = ["1. Cosine Waveform", "2. Square Pulse Train", "3. Triangle Waveform", "4. Pseudo-Random Binary Sequence (PRBS)"];
    curr_idx = 1;
    select state.params.signal.type
    case "sine"
        curr_idx = 1;
    case "square"
        curr_idx = 2;
    case "triangle"
        curr_idx = 3;
    case "prbs"
        curr_idx = 4;
    end
    
    drop_group = widgets_create_dropdown(h_panel, "Waveform Type Selection", waveform_types, curr_idx, ...
        [0.52, 0.06, 0.42, 0.12], "cb_signal_dropdown()");
    t_widgets = toc() * 1000;
    log_timing("Signal Generator - Widgets & Sliders Setup", t_widgets);
    
    tic();
    // 5. Store UI widget handles for live string value updates
    state.ui.signal_generator_widgets = struct(...
        "amp_value", amp_slider_group.value, ...
        "freq_value", freq_slider_group.value, ...
        "phase_value", phase_slider_group.value, ...
        "amp_slider", amp_slider_group.slider, ...
        "freq_slider", freq_slider_group.slider, ...
        "phase_slider", phase_slider_group.slider, ...
        "type_dropdown", drop_group.popup ...
    );
    
    // Save panel handle using our list map helper
    state = ui_set_module_panel(state, "signal_generator", h_panel);
    fig.user_data = state;
    t_save = toc() * 1000;
    log_timing("Signal Generator - State Cache and Callback Binding", t_save);
endfunction

function ui_render_signal_generator(state)
    // Synchronizes the Signal Generator plots and sliders values with the current state.
    
    // 1. Verify handles exist and are valid
    if ~isfield(state.ui, "signal_generator_widgets") then return; end
    w = state.ui.signal_generator_widgets;
    ax = state.ui.signal_axes;
    h_line = state.ui.signal_line;
    
    if ~is_valid_handle(ax) | ~is_valid_handle(h_line) then return; end
    
    printf("\n[SIGNAL DEBUG]\n");
    printf("  Amplitude = %.2f V\n", state.params.signal.amp);
    printf("  Frequency = %.2f Hz\n", state.params.signal.freq);
    printf("  Phase = %.2f deg\n", state.params.signal.phase);
    printf("  Waveform = %s\n", state.params.signal.type);
    printf("  Time samples = %d\n", size(state.data.time, "*"));
    printf("  Signal samples = %d\n", size(state.data.analog_waveform, "*"));
    if ~isempty(state.data.analog_waveform) then
        printf("  Signal min = %.3f V\n", min(state.data.analog_waveform));
        printf("  Signal max = %.3f V\n", max(state.data.analog_waveform));
    else
        printf("  Signal min = [empty]\n");
        printf("  Signal max = [empty]\n");
    end
    printf("  Plot handle valid = %s\n", string(is_valid_handle(h_line)));
    if is_valid_handle(h_line) then
        printf("  Plot visible = %s\n", h_line.visible);
        if is_valid_handle(h_line.parent) then
            printf("  Parent Compound visible = %s\n", h_line.parent.visible);
        end
    else
        printf("  Plot visible = [invalid]\n");
    end
    printf("  Axes handle valid = %s\n", string(is_valid_handle(ax)));
    if is_valid_handle(ax) then
        printf("  Axes visible = %s\n", ax.visible);
    end
    printf("\n");
    
    // 2. Synchronize Slider Value Displays
    set(w.amp_value, "string", sprintf("%.2f V", state.params.signal.amp));
    set(w.freq_value, "string", sprintf("%.2f Hz", state.params.signal.freq));
    set(w.phase_value, "string", sprintf("%.1f deg", state.params.signal.phase));
    
    // Ensure the physical sliders reflect the internal state values
    set(w.amp_slider, "Value", state.params.signal.amp);
    set(w.freq_slider, "Value", state.params.signal.freq);
    set(w.phase_slider, "Value", state.params.signal.phase);
    
    // Set dropdown index depending on the wave type
    curr_idx = 1;
    select state.params.signal.type
    case "sine"
        curr_idx = 1;
    case "square"
        curr_idx = 2;
    case "triangle"
        curr_idx = 3;
    case "prbs"
        curr_idx = 4;
    end
    set(w.type_dropdown, "Value", curr_idx);
    
    // 3. Update Waveform Plot Line
    t = state.data.time;
    wave = state.data.analog_waveform;
    
    if isempty(t) | isempty(wave) then return; end
    
    // Decimate for plotting performance (plot 501 points instead of 5001)
    dec_idx = 1:10:size(t, "*");
    h_line.data = [t(dec_idx)', wave(dec_idx)'];
    
    // Dynamically adjust y boundaries to include 20% margin
    y_limit = max(0.5, state.params.signal.amp * 1.2);
    ax.data_bounds = [0, -y_limit; 1.0, y_limit];
    
    ax.title.text = "Time-Domain Analog Message Waveform m(t)";
    ax.x_label.text = "Time (seconds)";
    ax.y_label.text = "Amplitude (Volts)";
endfunction
