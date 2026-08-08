// =============================================================================
// GUIVerse - GUI Event Callback Handlers
// File: src/core/callbacks.sci
// =============================================================================

function cb_sidebar_click()
    // Triggered when any menu button on the left sidebar is clicked.
    btn = gcbo();
    if isempty(btn) then return; end
    
    // Retrieve target module from user_data tag
    module_name = btn.user_data;
    router_switch_module(module_name);
endfunction

function cb_block_diagram_click()
    // Triggered when any block in the Home dashboard pipeline is clicked.
    block = gcbo();
    if isempty(block) then return; end
    
    module_name = block.user_data;
    resolved_name = module_name;
    if module_name == "sampling" then
        resolved_name = "sampling_uniform";
    elseif module_name == "quantization" then
        resolved_name = "quant_uniform";
    elseif module_name == "pcm" then
        resolved_name = "pcm_encoder";
    end
    router_switch_module(resolved_name);
endfunction

function cb_toolbar_action()
    // Handles top toolbar events (Reset, Export, Theme toggles).
    btn = gcbo();
    if isempty(btn) then return; end
    
    action_type = btn.user_data;
    
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    select action_type
    case "reset"
        // Reinits state and returns to Home
        default_state = init_global_state();
        default_state.ui = state.ui; // Maintain UI handles references!
        fig.user_data = default_state;
        
        // Re-run the update pipeline from the very beginning (signal stage)
        pipeline_update("signal");
        router_switch_module("home");
        
    case "export"
        if exists("recorder_export_report") then
            recorder_export_report(state);
        else
            messagebox("Lab Report Generator is not loaded yet (Phase 5).", "CommVerse Info", "info");
        end
        
    case "theme"
        // Stretch Goal: Toggle theme
        if state.theme == "dark" then
            state.theme = "light";
            messagebox("Light Theme active. (In a full release, this updates RGB colormaps)", "Theme Toggled", "info");
        else
            state.theme = "dark";
            messagebox("Dark Theme active.", "Theme Toggled", "info");
        end
        fig.user_data = state;
        pipeline_update("render");
    end
endfunction

function cb_signal_slider()
    // Triggered when any slider in the Signal Generator module is moved
    slider = gcbo();
    if isempty(slider) then return; end
    
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    param_name = slider.user_data; // e.g. "amp", "freq", "phase", "bit_rate"
    val = slider.value;
    
    // Update the state parameters using standard static structure assignment
    select param_name
    case "amp"
        state.params.signal.amp = val;
    case "freq"
        state.params.signal.freq = val;
    case "phase"
        state.params.signal.phase = val;
    case "bit_rate"
        state.params.signal.bit_rate = val;
    end
    
    fig.user_data = state;
    
    // Execute the downstream pipeline starting from signal generation
    pipeline_update("signal");
endfunction

function cb_signal_dropdown()
    // Triggered when the waveform type dropdown is changed
    popup = gcbo();
    if isempty(popup) then return; end
    
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    // Options: 1: sine, 2: square, 3: triangle, 4: prbs
    val_idx = popup.value;
    options = ["sine", "square", "triangle", "prbs"];
    state.params.signal.type = options(val_idx);
    
    fig.user_data = state;
    
    // Execute the downstream pipeline starting from signal generation
    pipeline_update("signal");
endfunction

function cb_sampling_slider()
    // Triggered when the sampling frequency slider is moved
    slider = gcbo();
    if isempty(slider) then return; end
    
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    state.params.sampling.fs = slider.value;
    fig.user_data = state;
    
    // Execute downstream pipeline starting from sampling stage
    pipeline_update("sampling");
endfunction

function cb_quantization_slider()
    // Triggered when the quantization levels discrete slider is moved
    slider = gcbo();
    if isempty(slider) then return; end
    
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    // Map slider values [1..6] to discrete levels [2, 4, 8, 16, 32, 64]
    idx = round(slider.value);
    valid_levels = [2, 4, 8, 16, 32, 64];
    state.params.quantization.levels = valid_levels(idx);
    
    fig.user_data = state;
    
    // Execute downstream pipeline starting from quantization
    pipeline_update("quantization");
endfunction

function cb_quantization_dropdown()
    // Triggered when the quantizer type dropdown is selected
    popup = gcbo();
    if isempty(popup) then return; end
    
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    val_idx = popup.value;
    options = ["uniform_midrise", "uniform_midtread", "mu_law"];
    state.params.quantization.type = options(val_idx);
    
    fig.user_data = state;
    
    // Execute downstream pipeline starting from quantization
    pipeline_update("quantization");
endfunction

function cb_expand_plot()
    // Open a separate pop-out window and reuse existing renderers by swapping handles
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    colors = get_theme_colors();
    
    // Create popup figure (dark-themed analysis window)
    h_pop = figure("BackgroundColor", colors.bg_workspace, ...
                   "infobar", "off", ...
                   "menubar", "none", ...
                   "toolbar", "none", ...
                   "figure_name", "GUIVerse - Plot Analysis View");
                   
    resolved_module = state.active_module;
    if resolved_module == "sampling_uniform" | resolved_module == "sampling_recon" then
        resolved_module = "sampling";
    elseif resolved_module == "quant_uniform" | resolved_module == "quant_nonuniform" then
        resolved_module = "quantization";
    elseif resolved_module == "pcm_encoder" | resolved_module == "pcm_serialized" then
        resolved_module = "pcm";
    end
    
    select resolved_module
    case "signal_generator"
        // 1. Backup embedded handles
        backup_ax = state.ui.signal_axes;
        backup_line = state.ui.signal_line;
        
        // 2. Instantiate axes & line in the popup figure
        ax = newaxes(h_pop);
        style_axes_dark(ax);
        plot2d(0, 0);
        h_line = ax.children(1).children(1);
        set(h_line, "foreground", color(colors.accent_cyan(1)*255, colors.accent_cyan(2)*255, colors.accent_cyan(3)*255));
        set(h_line, "thickness", 2.5);
        
        // 3. Swap handles and render!
        state.ui.signal_axes = ax;
        state.ui.signal_line = h_line;
        ui_render_signal_generator(state);
        
        // 4. Restore handles
        state.ui.signal_axes = backup_ax;
        state.ui.signal_line = backup_line;
        
    case "sampling"
        // 1. Backup embedded handles
        backup_ax_recon = state.ui.sampling_axes_recon;
        backup_line_orig = state.ui.sampling_line_orig;
        backup_line_recon = state.ui.sampling_line_recon;
        backup_ax_stems = state.ui.sampling_axes_stems;
        backup_line_stems = state.ui.sampling_line_stems;
        backup_line_dots = state.ui.sampling_line_dots;
        
        // 2. Instantiate double axes & lines in popup
        ax_recon = newaxes(h_pop);
        ax_recon.axes_bounds = [0.04, 0.12, 0.44, 0.72];
        style_axes_dark(ax_recon);
        plot2d(0, 0); h_orig = ax_recon.children(1).children(1);
        set(h_orig, "foreground", color(colors.accent_cyan(1)*255, colors.accent_cyan(2)*255, colors.accent_cyan(3)*255));
        set(h_orig, "thickness", 2.5);
        plot2d(0, 0); h_recon = ax_recon.children(1).children(1);
        set(h_recon, "foreground", color(colors.accent_red(1)*255, colors.accent_red(2)*255, colors.accent_red(3)*255));
        set(h_recon, "thickness", 2.0);
        set(h_recon, "line_style", 2);
        
        ax_stems = newaxes(h_pop);
        ax_stems.axes_bounds = [0.52, 0.12, 0.44, 0.72];
        style_axes_dark(ax_stems);
        plot2d(0, 0, style=0, rect=[0,-1,1,1]); h_stems = ax_stems.children(1).children(1);
        set(h_stems, "foreground", color(colors.accent_blue(1)*255, colors.accent_blue(2)*255, colors.accent_blue(3)*255));
        set(h_stems, "thickness", 2.0);
        plot2d(0, 0, style=-9); h_dots = ax_stems.children(1).children(1);
        set(h_dots, "foreground", color(colors.accent_green(1)*255, colors.accent_green(2)*255, colors.accent_green(3)*255));
        set(h_dots, "thickness", 1.5);
        
        // 3. Swap handles and render!
        state.ui.sampling_axes_recon = ax_recon;
        state.ui.sampling_line_orig = h_orig;
        state.ui.sampling_line_recon = h_recon;
        state.ui.sampling_axes_stems = ax_stems;
        state.ui.sampling_line_stems = h_stems;
        state.ui.sampling_line_dots = h_dots;
        ui_render_sampling(state);
        
        // 4. Restore handles
        state.ui.sampling_axes_recon = backup_ax_recon;
        state.ui.sampling_line_orig = backup_line_orig;
        state.ui.sampling_line_recon = backup_line_recon;
        state.ui.sampling_axes_stems = backup_ax_stems;
        state.ui.sampling_line_stems = backup_line_stems;
        state.ui.sampling_line_dots = backup_line_dots;
        
    case "quantization"
        // 1. Backup embedded handles
        backup_ax_stair = state.ui.quant_axes_stair;
        backup_line_orig = state.ui.quant_line_orig;
        backup_line_stair = state.ui.quant_line_stair;
        backup_ax_error = state.ui.quant_axes_error;
        backup_line_error = state.ui.quant_line_error;
        
        // 2. Instantiate axes & lines in popup
        ax_stair = newaxes(h_pop);
        ax_stair.axes_bounds = [0.04, 0.12, 0.44, 0.72];
        style_axes_dark(ax_stair);
        plot2d(0, 0); h_orig = ax_stair.children(1).children(1);
        set(h_orig, "foreground", color(colors.accent_cyan(1)*255, colors.accent_cyan(2)*255, colors.accent_cyan(3)*255));
        set(h_orig, "thickness", 2.5);
        plot2d(0, 0); h_stair = ax_stair.children(1).children(1);
        set(h_stair, "foreground", color(colors.accent_yellow(1)*255, colors.accent_yellow(2)*255, colors.accent_yellow(3)*255));
        set(h_stair, "thickness", 2.0);
        
        ax_error = newaxes(h_pop);
        ax_error.axes_bounds = [0.52, 0.12, 0.44, 0.72];
        style_axes_dark(ax_error);
        plot2d(0, 0); h_error = ax_error.children(1).children(1);
        set(h_error, "foreground", color(colors.accent_red(1)*255, colors.accent_red(2)*255, colors.accent_red(3)*255));
        set(h_error, "thickness", 1.5);
        
        // 3. Swap handles and render!
        state.ui.quant_axes_stair = ax_stair;
        state.ui.quant_line_orig = h_orig;
        state.ui.quant_line_stair = h_stair;
        state.ui.quant_axes_error = ax_error;
        state.ui.quant_line_error = h_error;
        ui_render_quantization(state);
        
        // 4. Restore handles
        state.ui.quant_axes_stair = backup_ax_stair;
        state.ui.quant_line_orig = backup_line_orig;
        state.ui.quant_line_stair = backup_line_stair;
        state.ui.quant_axes_error = backup_ax_error;
        state.ui.quant_line_error = backup_line_error;
        
    case "pcm"
        // 1. Backup embedded handles
        backup_ax_recon = state.ui.pcm_axes_recon;
        backup_line_orig = state.ui.pcm_line_orig;
        backup_line_recon = state.ui.pcm_line_recon;
        backup_ax_bits = state.ui.pcm_axes_bits;
        backup_line_bits = state.ui.pcm_line_bits;
        
        // 2. Instantiate axes & lines in popup
        ax_recon = newaxes(h_pop);
        ax_recon.axes_bounds = [0.04, 0.12, 0.44, 0.72];
        style_axes_dark(ax_recon);
        plot2d(0, 0); h_orig = ax_recon.children(1).children(1);
        set(h_orig, "foreground", color(colors.accent_cyan(1)*255, colors.accent_cyan(2)*255, colors.accent_cyan(3)*255));
        set(h_orig, "thickness", 2.5);
        plot2d(0, 0); h_recon = ax_recon.children(1).children(1);
        set(h_recon, "foreground", color(colors.accent_red(1)*255, colors.accent_red(2)*255, colors.accent_red(3)*255));
        set(h_recon, "thickness", 1.5);
        set(h_recon, "line_style", 2);
        
        ax_bits = newaxes(h_pop);
        ax_bits.axes_bounds = [0.52, 0.12, 0.44, 0.72];
        style_axes_dark(ax_bits);
        plot2d(0, 0); h_bits = ax_bits.children(1).children(1);
        set(h_bits, "foreground", color(colors.accent_green(1)*255, colors.accent_green(2)*255, colors.accent_green(3)*255));
        set(h_bits, "thickness", 2.0);
        
        // 3. Swap handles and render!
        state.ui.pcm_axes_recon = ax_recon;
        state.ui.pcm_line_orig = h_orig;
        state.ui.pcm_line_recon = h_recon;
        state.ui.pcm_axes_bits = ax_bits;
        state.ui.pcm_line_bits = h_bits;
        ui_render_pcm(state);
        
        // 4. Restore handles
        state.ui.pcm_axes_recon = backup_ax_recon;
        state.ui.pcm_line_orig = backup_line_orig;
        state.ui.pcm_line_recon = backup_line_recon;
        state.ui.pcm_axes_bits = backup_ax_bits;
        state.ui.pcm_line_bits = backup_line_bits;
    end
endfunction
