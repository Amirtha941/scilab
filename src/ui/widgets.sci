// =============================================================================
// GUIVerse - Reusable UI Widgets & Status Bar
// File: src/ui/widgets.sci
// =============================================================================

function ui_create_status_bar(fig, status_panel)
    // Instantiates bottom status bar metrics and active configurations.
    // Inputs:
    //   fig: handle of the main window
    //   status_panel: handle of the status bar frame
    
    colors = get_theme_colors();
    set(status_panel, "BackgroundColor", colors.bg_main);
    
    // Status flag (Pipeline status) - List index 1
    h_lbl_status = uicontrol(status_panel, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [0.01, 0.18, 0.18, 0.64], ...
        "string", "Pipeline Status: OK", ...
        "HorizontalAlignment", "center");
    style_control(h_lbl_status, "action_button");
    set(h_lbl_status, "BackgroundColor", colors.accent_green);
    
    // Metrics 1: SNR - List index 2
    h_lbl_snr = uicontrol(status_panel, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [0.22, 0.18, 0.15, 0.64], ...
        "string", "SNR: 15.0 dB", ...
        "HorizontalAlignment", "left");
    style_control(h_lbl_snr, "label_muted");
    set(h_lbl_snr, "BackgroundColor", colors.bg_main);
    
    // Metrics 2: BER - List index 3
    h_lbl_ber = uicontrol(status_panel, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [0.38, 0.18, 0.15, 0.64], ...
        "string", "BER: 0.00e+00", ...
        "HorizontalAlignment", "left");
    style_control(h_lbl_ber, "label_muted");
    set(h_lbl_ber, "BackgroundColor", colors.bg_main);
    
    // Metrics 3: SQNR - List index 4
    h_lbl_sqnr = uicontrol(status_panel, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [0.54, 0.18, 0.15, 0.64], ...
        "string", "SQNR: 0.0 dB", ...
        "HorizontalAlignment", "left");
    style_control(h_lbl_sqnr, "label_muted");
    set(h_lbl_sqnr, "BackgroundColor", colors.bg_main);
    
    // Metrics 4: Bit Rate - List index 5
    h_lbl_br = uicontrol(status_panel, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [0.70, 0.18, 0.15, 0.64], ...
        "string", "Bit Rate: 10.0 bps", ...
        "HorizontalAlignment", "left");
    style_control(h_lbl_br, "label_muted");
    set(h_lbl_br, "BackgroundColor", colors.bg_main);
    
    // Branding
    h_lbl_brand = uicontrol(status_panel, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [0.86, 0.18, 0.13, 0.64], ...
        "string", "GUIVerse v1.0", ...
        "HorizontalAlignment", "right");
    style_control(h_lbl_brand, "label_muted");
    set(h_lbl_brand, "BackgroundColor", colors.bg_main);
    set(h_lbl_brand, "FontWeight", "bold");
    
    // Save handles into state list (preserves index order)
    state = fig.user_data;
    state.ui.status_bar(1) = h_lbl_status;
    state.ui.status_bar(2) = h_lbl_snr;
    state.ui.status_bar(3) = h_lbl_ber;
    state.ui.status_bar(4) = h_lbl_sqnr;
    state.ui.status_bar(5) = h_lbl_br;
    fig.user_data = state;
endfunction

function widgets_update_status_bar(state)
    // Updates strings and indicators in the status bar from current state data.
    // Inputs:
    //   state: global state structure
    
    if size(state.ui.status_bar) < 5 then return; end
    
    h_status  = state.ui.status_bar(1);
    h_snr     = state.ui.status_bar(2);
    h_ber     = state.ui.status_bar(3);
    h_sqnr    = state.ui.status_bar(4);
    h_br      = state.ui.status_bar(5);
    
    if ~is_valid_handle(h_status) then return; end
    
    colors = get_theme_colors();
    
    // Check if any stage has failed using vector checking
    pipeline_ok = %t;
    for i = 1:size(state.pipeline_status, "*")
        if state.pipeline_status(i) == "ERROR" then
            pipeline_ok = %f;
            break;
        end
    end
    
    if pipeline_ok then
        set(h_status, "string", "Pipeline Status: OK");
        set(h_status, "BackgroundColor", colors.accent_green);
    else
        set(h_status, "string", "Pipeline Error!");
        set(h_status, "BackgroundColor", colors.accent_red);
    end
    
    // Update SNR
    if is_valid_handle(h_snr) then
        snr_str = sprintf("SNR: %.1f dB", state.params.channel.snr);
        set(h_snr, "string", snr_str);
    end
    
    // Update BER
    if is_valid_handle(h_ber) then
        ber_str = sprintf("BER: %.2e", state.data.ber);
        set(h_ber, "string", ber_str);
    end
    
    // Update SQNR
    if is_valid_handle(h_sqnr) then
        sqnr_str = sprintf("SQNR: %.1f dB", state.data.sqnr);
        set(h_sqnr, "string", sqnr_str);
    end
    
    // Update Bit Rate
    if is_valid_handle(h_br) then
        br_str = sprintf("Bit Rate: %.1f bps", state.data.bit_rate_actual);
        set(h_br, "string", br_str);
    end
endfunction

function card = widgets_create_card(parent, title_text, pos)
    // Helper to generate a styled frame (card) with a title label at the top.
    // Inputs:
    //   parent: handle of parent container
    //   title_text: string for card header
    //   pos: position vector [x, y, w, h] normalized
    
    colors = get_theme_colors();
    
    // Main card frame (flat border)
    h_frame = uicontrol(parent, ...
        "style", "frame", ...
        "units", "normalized", ...
        "position", pos);
    style_control(h_frame, "card_frame");
    
    // Header text (created on the same parent to avoid Scilab uicontrol nesting limitations)
    h_hdr = uicontrol(parent, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [pos(1)+pos(3)*0.02, pos(2)+pos(4)*0.90, pos(3)*0.96, pos(4)*0.08], ...
        "string", title_text, ...
        "HorizontalAlignment", "left");
    style_control(h_hdr, "panel_header");
    set(h_hdr, "BackgroundColor", colors.bg_panel);
    
    // Return widget structure
    card = struct(...
        "frame", h_frame, ...
        "header", h_hdr ...
    );
endfunction

function slider_group = widgets_create_slider(parent, label_text, r_min, r_max, curr_val, pos, callback_func)
    // Helper to generate a slider with label and live numeric display.
    // Inputs:
    //   parent: handle of parent frame
    //   label_text: slider description
    //   r_min, r_max: slider boundaries
    //   curr_val: initial value
    //   pos: position vector [x, y, w, h] normalized
    //   callback_func: string representing Scilab callback function
    
    colors = get_theme_colors();
    
    // Title label
    h_lbl = uicontrol(parent, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [pos(1)+pos(3)*0.05, pos(2)+pos(4)*0.65, pos(3)*0.60, pos(4)*0.30], ...
        "string", label_text, ...
        "HorizontalAlignment", "left");
    style_control(h_lbl, "label");
    set(h_lbl, "BackgroundColor", colors.bg_panel);
    
    // Numeric value display
    val_str = sprintf("%.2f", curr_val);
    h_val = uicontrol(parent, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [pos(1)+pos(3)*0.65, pos(2)+pos(4)*0.65, pos(3)*0.30, pos(4)*0.30], ...
        "string", val_str, ...
        "HorizontalAlignment", "right");
    style_control(h_val, "label");
    set(h_val, "BackgroundColor", colors.bg_panel);
    set(h_val, "ForegroundColor", colors.accent_cyan);
    set(h_val, "FontWeight", "bold");
    
    // Slider widget
    h_slider = uicontrol(parent, ...
        "style", "slider", ...
        "units", "normalized", ...
        "position", [pos(1)+pos(3)*0.05, pos(2)+pos(4)*0.15, pos(3)*0.90, pos(4)*0.38], ...
        "Min", r_min, ...
        "Max", r_max, ...
        "Value", curr_val, ...
        "callback", callback_func, ...
        "callback_type", 2);
    style_control(h_slider, "input");
    
    slider_group = struct(...
        "container", [], ...
        "label", h_lbl, ...
        "value", h_val, ...
        "slider", h_slider ...
    );
endfunction

function dropdown_group = widgets_create_dropdown(parent, label_text, options, curr_idx, pos, callback_func)
    // Helper to generate a dropdown combo box and associated label.
    // Inputs:
    //   parent: handle of parent frame
    //   label_text: dropdown description
    //   options: string list or cell matrix of strings
    //   curr_idx: integer of default option
    //   pos: position vector [x, y, w, h] normalized
    //   callback_func: string representing Scilab callback function
    
    colors = get_theme_colors();
    
    // Label (parent set to container's parent)
    h_lbl = uicontrol(parent, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [pos(1)+pos(3)*0.05, pos(2)+pos(4)*0.68, pos(3)*0.90, pos(4)*0.28], ...
        "string", label_text, ...
        "HorizontalAlignment", "left");
    style_control(h_lbl, "label");
    set(h_lbl, "BackgroundColor", colors.bg_panel);
    
    // Dropdown combo box
    opt_str = "";
    for i = 1:size(options, "*")
        if i == 1 then
            opt_str = options(i);
        else
            opt_str = opt_str + "|" + options(i);
        end
    end
    
    h_popup = uicontrol(parent, ...
        "style", "popupmenu", ...
        "units", "normalized", ...
        "position", [pos(1)+pos(3)*0.05, pos(2)+pos(4)*0.15, pos(3)*0.90, pos(4)*0.45], ...
        "string", opt_str, ...
        "Value", curr_idx, ...
        "callback", callback_func, ...
        "callback_type", 2);
    style_control(h_popup, "input");
    
    dropdown_group = struct(...
        "container", [], ...
        "label", h_lbl, ...
        "popup", h_popup ...
    );
endfunction
