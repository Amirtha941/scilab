// =============================================================================
// GUIVerse - Laboratories Registry & Launcher Callbacks
// File: src/core/registry.sci
// =============================================================================

global g_labs_registry;
g_labs_registry = list();

function registerLab(name, status, icon, callback_func)
    // Registers a laboratory module into the global registry.
    global g_labs_registry;
    lab = struct("name", name, "status", status, "icon", icon, "callback", callback_func);
    g_labs_registry($+1) = lab;
endfunction

function cb_launch_comm_lab()
    // Normal launch: opens the Communication Laboratory at its Home (block diagram).
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    // Hide Launcher Panels
    if isfield(state.ui, "frame_dashboard") & is_valid_handle(state.ui.frame_dashboard) then
        set(state.ui.frame_dashboard, "visible", "off");
    end
    if isfield(state.ui, "frame_coming_soon") & is_valid_handle(state.ui.frame_coming_soon) then
        set(state.ui.frame_coming_soon, "visible", "off");
    end
    
    // Show Communication Lab Frame Panels
    if isfield(state.ui, "frame_toolbar") & is_valid_handle(state.ui.frame_toolbar) then
        set(state.ui.frame_toolbar, "visible", "on");
    end
    if isfield(state.ui, "frame_sidebar") & is_valid_handle(state.ui.frame_sidebar) then
        set(state.ui.frame_sidebar, "visible", "on");
    end
    if isfield(state.ui, "frame_workspace") & is_valid_handle(state.ui.frame_workspace) then
        set(state.ui.frame_workspace, "visible", "on");
    end
    if isfield(state.ui, "frame_education") & is_valid_handle(state.ui.frame_education) then
        set(state.ui.frame_education, "visible", "on");
    end
    if isfield(state.ui, "frame_status") & is_valid_handle(state.ui.frame_status) then
        set(state.ui.frame_status, "visible", "on");
    end
    
    // Switch to Home module
    router_switch_module("home");
endfunction

function cb_launch_comm_lab_resume()
    // Resume launch: opens the Communication Laboratory directly to the last active experiment.
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    // Hide Launcher Panels
    if isfield(state.ui, "frame_dashboard") & is_valid_handle(state.ui.frame_dashboard) then
        set(state.ui.frame_dashboard, "visible", "off");
    end
    if isfield(state.ui, "frame_coming_soon") & is_valid_handle(state.ui.frame_coming_soon) then
        set(state.ui.frame_coming_soon, "visible", "off");
    end
    
    // Show Communication Lab Frame Panels
    if isfield(state.ui, "frame_toolbar") & is_valid_handle(state.ui.frame_toolbar) then
        set(state.ui.frame_toolbar, "visible", "on");
    end
    if isfield(state.ui, "frame_sidebar") & is_valid_handle(state.ui.frame_sidebar) then
        set(state.ui.frame_sidebar, "visible", "on");
    end
    if isfield(state.ui, "frame_workspace") & is_valid_handle(state.ui.frame_workspace) then
        set(state.ui.frame_workspace, "visible", "on");
    end
    if isfield(state.ui, "frame_education") & is_valid_handle(state.ui.frame_education) then
        set(state.ui.frame_education, "visible", "on");
    end
    if isfield(state.ui, "frame_status") & is_valid_handle(state.ui.frame_status) then
        set(state.ui.frame_status, "visible", "on");
    end
    
    // Resume exact experiment
    resume_target = state.last_experiment;
    if resume_target == "home" | resume_target == "" then
        resume_target = "signal_generator"; // safe fallback
    end
    
    router_switch_module(resume_target);
endfunction

function cb_launch_coming_soon(lab_name)
    // Displays the Coming Soon view for a given laboratory.
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    // Set dynamic text on the Coming Soon label
    if isfield(state.ui, "coming_soon_title") & is_valid_handle(state.ui.coming_soon_title) then
        set(state.ui.coming_soon_title, "string", lab_name);
    end
    
    // Hide Launcher Main Panel
    if isfield(state.ui, "frame_dashboard") & is_valid_handle(state.ui.frame_dashboard) then
        set(state.ui.frame_dashboard, "visible", "off");
    end
    
    // Show Coming Soon Panel
    if isfield(state.ui, "frame_coming_soon") & is_valid_handle(state.ui.frame_coming_soon) then
        set(state.ui.frame_coming_soon, "visible", "on");
    end
endfunction

function cb_exit_to_launcher()
    // Hides the laboratory frames and returns the user to the GUIVerse Main Dashboard.
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    // Hide Communication Lab Frame Panels
    if isfield(state.ui, "frame_toolbar") & is_valid_handle(state.ui.frame_toolbar) then
        set(state.ui.frame_toolbar, "visible", "off");
    end
    if isfield(state.ui, "frame_sidebar") & is_valid_handle(state.ui.frame_sidebar) then
        set(state.ui.frame_sidebar, "visible", "off");
    end
    if isfield(state.ui, "frame_workspace") & is_valid_handle(state.ui.frame_workspace) then
        set(state.ui.frame_workspace, "visible", "off");
    end
    if isfield(state.ui, "frame_education") & is_valid_handle(state.ui.frame_education) then
        set(state.ui.frame_education, "visible", "off");
    end
    if isfield(state.ui, "frame_status") & is_valid_handle(state.ui.frame_status) then
        set(state.ui.frame_status, "visible", "off");
    end
    if isfield(state.ui, "frame_coming_soon") & is_valid_handle(state.ui.frame_coming_soon) then
        set(state.ui.frame_coming_soon, "visible", "off");
    end
    
    // Show Launcher Dashboard
    if isfield(state.ui, "frame_dashboard") & is_valid_handle(state.ui.frame_dashboard) then
        set(state.ui.frame_dashboard, "visible", "on");
    end
    
    // Update dashboard elements (like the Continue Learning card metadata)
    if exists("ui_update_main_dashboard") then
        ui_update_main_dashboard(state);
    end
endfunction

function cb_coming_soon_back()
    // Returns to the launcher from the Coming Soon view.
    fig = find_main_figure();
    if isempty(fig) then return; end
    state = fig.user_data;
    
    if isfield(state.ui, "frame_coming_soon") & is_valid_handle(state.ui.frame_coming_soon) then
        set(state.ui.frame_coming_soon, "visible", "off");
    end
    if isfield(state.ui, "frame_dashboard") & is_valid_handle(state.ui.frame_dashboard) then
        set(state.ui.frame_dashboard, "visible", "on");
    end
endfunction
