// =============================================================================
// GUIVerse - Event Router and Pipeline Controller
// File: src/router/router.sci
// =============================================================================

// --- DSP STUBS FOR PHASE 2/3/4 COMPILATION ---
// These stubs will be overwritten when the respective DSP files are loaded.
// Note: dsp_run_signal is now loaded from src/dsp/signal.sci
// Note: dsp_run_sampling is now loaded from src/dsp/sampling.sci
// Note: dsp_run_quantization is now loaded from src/dsp/quantization.sci
// Note: dsp_run_pcm is now loaded from src/dsp/pcm.sci
function state = dsp_run_linecoding(state);   state = state_set_pipeline_status(state, "linecoding", "OK");   endfunction
function state = dsp_run_modulation(state);   state = state_set_pipeline_status(state, "modulation", "OK");   endfunction
function state = dsp_run_channel(state);      state = state_set_pipeline_status(state, "channel", "OK");      endfunction
function state = dsp_run_receiver(state);     state = state_set_pipeline_status(state, "receiver", "OK");     endfunction
function state = dsp_run_metrics(state);      endfunction

// --- RENDER STUBS FOR MODULES ---
function ui_render_module(module_name, state)
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
        if exists("ui_render_signal_generator") then
            ui_render_signal_generator(state);
        end
    case "sampling"
        if exists("ui_render_sampling") then
            ui_render_sampling(state);
        end
    case "quantization"
        if exists("ui_render_quantization") then
            ui_render_quantization(state);
        end
    case "pcm"
        if exists("ui_render_pcm") then
            ui_render_pcm(state);
        end
    end
endfunction

function ui_render_education(module_name, state); endfunction



function router_switch_module(module_name)
    // Swaps the active workspace panel, updates sidebar state, and redraws plots.
    // Inputs:
    //   module_name: string identifier (e.g. 'sampling')
    
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    old_module = state.active_module;
    
    // Save last experiment tracking if it is an active experiment
    is_exp = %f;
    exp_display = "";
    select module_name
    case "signal_generator"
        is_exp = %t;
        exp_display = "Analog Signal Generator";
    case "sampling_uniform"
        is_exp = %t;
        exp_display = "Uniform Sampling";
    case "sampling_recon"
        is_exp = %t;
        exp_display = "Whittaker Reconstruction";
    case "quant_uniform"
        is_exp = %t;
        exp_display = "Uniform Quantizer";
    case "quant_nonuniform"
        is_exp = %t;
        exp_display = "Non-uniform Quantizer";
    case "pcm_encoder"
        is_exp = %t;
        exp_display = "PCM Encoder";
    case "pcm_serialized"
        is_exp = %t;
        exp_display = "Serialized PCM Link";
    end
    
    if is_exp then
        state.last_experiment = module_name;
        state.last_experiment_display = exp_display;
    end
    
    // Update parameter synchronization depending on target module
    run_dsp_stage = "render";
    if module_name == "quant_uniform" then
        if state.params.quantization.type == "mu_law" then
            state.params.quantization.type = "uniform_midrise";
            run_dsp_stage = "quantization";
        end
    elseif module_name == "quant_nonuniform" then
        if state.params.quantization.type <> "mu_law" then
            state.params.quantization.type = "mu_law";
            run_dsp_stage = "quantization";
        end
    end
    
    // Start module transition
    tic();
    
    is_old_ws = is_workspace_module(old_module);
    is_new_ws = is_workspace_module(module_name);
    
    if is_old_ws & is_new_ws then
        mprintf("[INIT] Switching in-place inside persistent workspace...\n");
        // 1. Hide old axes before reconfiguring
        ui_set_axes_visible(state, old_module, "off");
        
        // 2. Update sidebar buttons styling
        h_btn_old = ui_get_sidebar_button(state, old_module);
        if is_valid_handle(h_btn_old) then
            style_control(h_btn_old, "sidebar_button");
        end
        h_btn_new = ui_get_sidebar_button(state, module_name);
        if is_valid_handle(h_btn_new) then
            style_control(h_btn_new, "sidebar_active_button");
        end
        
        // 3. Update state variables and save
        state.active_module = module_name;
        fig.user_data = state;
        
        // 4. Configure workspace layout and widgets in place
        ui_configure_workspace(module_name, state);
        
        mprintf("[INIT] Rendering plots...\n");
        mprintf("[INIT] Rendering educational panel...\n");
        // 5. Run DSP pipeline to update data for the new module
        pipeline_update(run_dsp_stage);
        
        mprintf("[INIT] Revealing OpenGL plots and flushing screen...\n");
        // 6. Make new axes visible, then flush (panel is already shown)
        ui_set_axes_visible(state, module_name, "on");
        drawnow();
        mprintf("[TIMING] drawnow count: 1\n");
    else
        mprintf("[INIT] Hiding old module: %s\n", old_module);
        // 1. Hide old module panel and axes completely
        ui_set_axes_visible(state, old_module, "off");
        ui_set_panel_visible(state, old_module, "off");
        
        mprintf("[INIT] Attaching callbacks and updating parameters for: %s\n", module_name);
        
        // 2. Update sidebar buttons styling
        h_btn_old = ui_get_sidebar_button(state, old_module);
        if is_valid_handle(h_btn_old) then
            style_control(h_btn_old, "sidebar_button");
        end
        h_btn_new = ui_get_sidebar_button(state, module_name);
        if is_valid_handle(h_btn_new) then
            style_control(h_btn_new, "sidebar_active_button");
        end
        
        // 3. Update state variables and save
        state.active_module = module_name;
        fig.user_data = state;
        
        if is_new_ws then
            ui_configure_workspace(module_name, state);
        end
        
        mprintf("[INIT] Rendering plots...\n");
        mprintf("[INIT] Rendering educational panel...\n");
        // 4. Run DSP pipeline to update data
        pipeline_update(run_dsp_stage);
        
        mprintf("[INIT] Showing Swing panel container: %s\n", module_name);
        // 5. Show the Swing uicontrol panel first — Swing must own the surface before
        //    OpenGL can paint into it. Showing panel before axes avoids blank canvases.
        ui_set_panel_visible(state, module_name, "on");
        
        mprintf("[INIT] Revealing OpenGL plots and flushing screen...\n");
        // 6. Now that the panel surface exists, show axes and flush OpenGL
        ui_set_axes_visible(state, module_name, "on");
        drawnow();
        mprintf("[TIMING] drawnow count: 1\n");
    end
    
    t_switch = toc() * 1000;
    log_timing("Module Switch Transition (drawnow synced)", t_switch);
endfunction

function pipeline_update(start_stage)
    // Downstream event router. Sequentially triggers DSP modules based on where
    // the user updated a parameter, avoiding redundant computations.
    // Inputs:
    //   start_stage: 'signal' | 'sampling' | 'quantization' | 'pcm' | 'linecoding' | 
    //                'modulation' | 'channel' | 'receiver' | 'metrics' | 'render'
    
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    select start_stage
    case "signal"
        state = dsp_run_signal(state);
        state = dsp_run_sampling(state);
        state = dsp_run_quantization(state);
        state = dsp_run_pcm(state);
        state = dsp_run_linecoding(state);
        state = dsp_run_modulation(state);
        state = dsp_run_channel(state);
        state = dsp_run_receiver(state);
        state = dsp_run_metrics(state);
        
    case "sampling"
        state = dsp_run_sampling(state);
        state = dsp_run_quantization(state);
        state = dsp_run_pcm(state);
        state = dsp_run_linecoding(state);
        state = dsp_run_modulation(state);
        state = dsp_run_channel(state);
        state = dsp_run_receiver(state);
        state = dsp_run_metrics(state);
        
    case "quantization"
        state = dsp_run_quantization(state);
        state = dsp_run_pcm(state);
        state = dsp_run_linecoding(state);
        state = dsp_run_modulation(state);
        state = dsp_run_channel(state);
        state = dsp_run_receiver(state);
        state = dsp_run_metrics(state);
        
    case "pcm"
        state = dsp_run_pcm(state);
        state = dsp_run_linecoding(state);
        state = dsp_run_modulation(state);
        state = dsp_run_channel(state);
        state = dsp_run_receiver(state);
        state = dsp_run_metrics(state);
        
    case "linecoding"
        state = dsp_run_linecoding(state);
        state = dsp_run_modulation(state);
        state = dsp_run_channel(state);
        state = dsp_run_receiver(state);
        state = dsp_run_metrics(state);
        
    case "modulation"
        state = dsp_run_modulation(state);
        state = dsp_run_channel(state);
        state = dsp_run_receiver(state);
        state = dsp_run_metrics(state);
        
    case "channel"
        state = dsp_run_channel(state);
        state = dsp_run_receiver(state);
        state = dsp_run_metrics(state);
        
    case "receiver"
        state = dsp_run_receiver(state);
        state = dsp_run_metrics(state);
        
    case "metrics"
        state = dsp_run_metrics(state);
        
    case "render"
        // Simply skip DSP steps and go straight to rendering the GUI
    end
    
    // Save state back to the main figure
    fig.user_data = state;
    
    // 6. Update the interactive block diagram execution state colors on the home page
    if exists("dashboard_update_pipeline_blocks") then
        dashboard_update_pipeline_blocks(state);
    end
    
    // 7. Update status bar metrics
    if exists("widgets_update_status_bar") then
        widgets_update_status_bar(state);
    end
    
    // 8. Render the active workspace panel
    if exists("ui_render_module") then
        ui_render_module(state.active_module, state);
    end
    
    // 9. Render the educational details card
    if exists("ui_render_education") then
        ui_render_education(state.active_module, state);
    end
endfunction

function ui_set_panel_visible(state, module_name, is_visible_str)
    // Toggles visibility of the Java Swing uicontrol parent container.
    resolved_name = module_name;
    if module_name == "sampling_uniform" | module_name == "sampling_recon" then
        resolved_name = "sampling";
    elseif module_name == "quant_uniform" | module_name == "quant_nonuniform" then
        resolved_name = "quantization";
    elseif module_name == "pcm_encoder" | module_name == "pcm_serialized" then
        resolved_name = "pcm";
    end
    
    h_panel = ui_get_module_panel(state, resolved_name);
    if is_valid_handle(h_panel) then
        set(h_panel, "visible", is_visible_str);
    end
endfunction

function ui_set_axes_visible(state, module_name, is_visible_str)
    // Toggles visibility of OpenGL axes graphic entities specifically.
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
        if isfield(state.ui, "signal_axes") then
            ax = state.ui.signal_axes;
            if is_valid_handle(ax) then ax.visible = is_visible_str; end
        end
        
    case "sampling"
        if isfield(state.ui, "sampling_axes_recon") then
            ax1 = state.ui.sampling_axes_recon;
            if is_valid_handle(ax1) then ax1.visible = is_visible_str; end
        end
        if isfield(state.ui, "sampling_axes_stems") then
            ax2 = state.ui.sampling_axes_stems;
            if is_valid_handle(ax2) then ax2.visible = is_visible_str; end
        end
        
    case "quantization"
        if isfield(state.ui, "quant_axes_stair") then
            ax1 = state.ui.quant_axes_stair;
            if is_valid_handle(ax1) then ax1.visible = is_visible_str; end
        end
        if isfield(state.ui, "quant_axes_error") then
            ax2 = state.ui.quant_axes_error;
            if is_valid_handle(ax2) then ax2.visible = is_visible_str; end
        end
        
    case "pcm"
        if isfield(state.ui, "pcm_axes_recon") then
            ax1 = state.ui.pcm_axes_recon;
            if is_valid_handle(ax1) then ax1.visible = is_visible_str; end
        end
        if isfield(state.ui, "pcm_axes_bits") then
            ax2 = state.ui.pcm_axes_bits;
            if is_valid_handle(ax2) then ax2.visible = is_visible_str; end
        end
    end
endfunction

function res = is_workspace_module(module_name)
    // Returns %t if the module belongs to the single persistent workspace panel container.
    res = (module_name == "signal_generator" | ...
           module_name == "sampling" | ...
           module_name == "sampling_uniform" | ...
           module_name == "sampling_recon" | ...
           module_name == "quantization" | ...
           module_name == "quant_uniform" | ...
           module_name == "quant_nonuniform" | ...
           module_name == "pcm" | ...
           module_name == "pcm_encoder" | ...
           module_name == "pcm_serialized");
endfunction
