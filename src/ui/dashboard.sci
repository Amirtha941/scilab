// =============================================================================
// CommVerse - Home Dashboard Builder and Pipeline Status Renderer
// File: src/ui/dashboard.sci
// =============================================================================

function ui_create_dashboard(fig, home_panel)
    // Renders the main dashboard cards and interactive pipeline diagram.
    // Inputs:
    //   fig: graphic handle of the main window
    //   home_panel: graphic handle of the home module frame
    
    colors = get_theme_colors();
    set(home_panel, "BackgroundColor", colors.bg_workspace);
    
    // 1. Dashboard title banner
    h_lbl_title = uicontrol(home_panel, ...
        "style", "text", ...
        "units", "normalized", ...
        "position", [0.03, 0.90, 0.94, 0.06], ...
        "string", "Interactive Engineering Dashboard", ...
        "HorizontalAlignment", "left");
    style_control(h_lbl_title, "header");
    set(h_lbl_title, "FontSize", 14);
    set(h_lbl_title, "BackgroundColor", colors.bg_workspace);
    
    // 2. Overview Card
    c_overview = widgets_create_card(home_panel, "Welcome to CommVerse", [0.03, 0.52, 0.45, 0.35]);
    h_overview_text = uicontrol(c_overview.frame, ...
        "style", "edit", ...
        "units", "normalized", ...
        "position", [0.05, 0.05, 0.90, 0.80], ...
        "max", 2, ...
        "min", 0, ...
        "enable", "off", ...
        "string", ["CommVerse is a state-of-the-art virtual laboratory designed to build intuition in digital communication chains.";
                   "";
                   "Adjust parameters in the workspace, watch the signal flow in real-time, and analyze key metrics like BER, SQNR, and spectral efficiency.";
                   "";
                   "Click any stage in the interactive block diagram below to jump to its detailed parameters."], ...
        "HorizontalAlignment", "left");
    style_control(h_overview_text, "label");
    set(h_overview_text, "BackgroundColor", colors.bg_panel);
    set(h_overview_text, "ForegroundColor", colors.text_primary);
    
    // 3. Quick Metrics Card
    c_metrics = widgets_create_card(home_panel, "Current Experiment Overview", [0.52, 0.52, 0.45, 0.35]);
    
    h_met_label = uicontrol(c_metrics.frame, ...
        "style", "edit", ...
        "units", "normalized", ...
        "position", [0.05, 0.05, 0.90, 0.80], ...
        "max", 2, ...
        "min", 0, ...
        "enable", "off", ...
        "string", ["Active Experiment: Default Communication Chain";
                   "";
                   "Link Status: Active";
                   "Carrier Frequency: 100.0 Hz";
                   "Sampling Rate: 40.0 Hz";
                   "SNR Channel: 15.0 dB";
                   "Estimated Bit Error Rate: 0.00e+00"], ...
        "HorizontalAlignment", "left");
    style_control(h_met_label, "label");
    set(h_met_label, "BackgroundColor", colors.bg_panel);
    set(h_met_label, "ForegroundColor", colors.text_primary);
    
    // Save metric display label to state to allow dynamic updates
    state = fig.user_data;
    state.ui.dashboard_metrics = h_met_label;
    
    // 4. Interactive Block Diagram Card
    c_pipeline = widgets_create_card(home_panel, "Interactive Communication Pipeline Chain", [0.03, 0.05, 0.94, 0.42]);
    
    // Position parameters for horizontal blocks
    block_names = ["signal", "sampling", "quantization", "pcm", "linecoding", "modulation", "channel", "receiver", "recovered"];
    block_modules = ["signal_generator", "sampling", "quantization", "pcm", "linecoding", "modulation", "noise", "receiver", "ber"];
    block_labels = ["Signal Gen", "Sampling", "Quantize", "PCM Enc", "Line Code", "Modulator", "AWGN Channel", "Receiver", "BER Output"];
    
    n_blocks = size(block_names, "*");
    b_width = 0.088;
    a_width = 0.016;
    x_start = 0.02;
    b_height = 0.45;
    y_pos = 0.20;
    
    for i = 1:n_blocks
        b_name = block_names(i);
        b_mod = block_modules(i);
        b_lbl = block_labels(i);
        
        x_pos = x_start + (i - 1) * (b_width + a_width);
        
        // Block button
        h_btn = uicontrol(c_pipeline.frame, ...
            "style", "pushbutton", ...
            "units", "normalized", ...
            "position", [x_pos, y_pos, b_width, b_height], ...
            "string", b_lbl, ...
            "HorizontalAlignment", "center", ...
            "user_data", b_mod, ...
            "callback", "cb_block_diagram_click()", ...
            "callback_type", 2);
            
        // Initial color styling based on status
        style_control(h_btn, "action_button");
        set(h_btn, "BackgroundColor", colors.accent_green); // default OK
        
        // Save using our safe helper
        state = ui_set_pipeline_block(state, b_name, h_btn);
        
        // Draw an arrow between blocks (except for the last block)
        if i < n_blocks then
            x_arr = x_pos + b_width;
            h_arr = uicontrol(c_pipeline.frame, ...
                "style", "text", ...
                "units", "normalized", ...
                "position", [x_arr, y_pos + 0.1, a_width, b_height - 0.2], ...
                "string", ">", ...
                "HorizontalAlignment", "center");
            style_control(h_arr, "label_muted");
            set(h_arr, "BackgroundColor", colors.bg_panel);
            set(h_arr, "FontSize", 10);
            set(h_arr, "FontWeight", "bold");
        end
    end
    
    fig.user_data = state;
endfunction

function dashboard_update_pipeline_blocks(state)
    // Synchronizes the background colors of the dashboard block diagram with pipeline state.
    // Inputs:
    //   state: global state structure
    
    colors = get_theme_colors();
    
    block_names = ["signal", "sampling", "quantization", "pcm", "linecoding", "modulation", "channel", "receiver"];
    status_names = ["signal", "sampling", "quantization", "pcm", "linecoding", "modulation", "channel", "receiver"];
    
    for i = 1:size(block_names, "*")
        b_name = block_names(i);
        st_name = status_names(i);
        
        h_btn = ui_get_pipeline_block(state, b_name);
        if ~is_valid_handle(h_btn) then continue; end
        
        status_val = state_get_pipeline_status(state, st_name);
        
        select status_val
        case "OK"
            set(h_btn, "BackgroundColor", colors.accent_green);
            set(h_btn, "ForegroundColor", [1, 1, 1]);
        case "PENDING"
            set(h_btn, "BackgroundColor", colors.bg_input);
            set(h_btn, "ForegroundColor", colors.text_muted);
        case "ERROR"
            set(h_btn, "BackgroundColor", colors.accent_red);
            set(h_btn, "ForegroundColor", [1, 1, 1]);
        end
    end
    
    // Also update overview metrics text card
    h_met = state.ui.dashboard_metrics;
    if ~isempty(h_met) & is_valid_handle(h_met) then
        set(h_met, "string", [...
            "Active Experiment: Default Communication Chain";
            "";
            sprintf("Link Status: %s", "Active");
            sprintf("Carrier Frequency: %.1f Hz", state.params.modulation.fc);
            sprintf("Sampling Rate: %.1f Hz", state.params.sampling.fs);
            sprintf("SNR Channel: %.1f dB", state.params.channel.snr);
            sprintf("Estimated Bit Error Rate: %.2e", state.data.ber)...
        ]);
    end
endfunction
