// =============================================================================
// GUIVerse - Modular Virtual Engineering Laboratory Platform
// Main Entry Script
// File: guiverse.sce
// =============================================================================

clc;  // Clear Scilab console
mode(0); // Set standard command execution mode
funcprot(0); // Suppress function redefinition warnings

// 1. Determine script directory dynamically to avoid hardcoded paths
try
    project_dir = get_absolute_file_path("guiverse.sce");
catch
    // Fallback if executed directly from console without saving (unlikely)
    project_dir = "./";
end

// 2. Load Core Platform Components in sequential dependency order
exec(project_dir + "src/core/constants.sci", -1);
exec(project_dir + "src/core/theme.sci", -1);
exec(project_dir + "src/state/state.sci", -1);
exec(project_dir + "src/router/router.sci", -1);
exec(project_dir + "src/core/callbacks.sci", -1);
exec(project_dir + "src/core/registry.sci", -1);

// 3. Load DSP Library Files (under communication/ analog_signal, sampling, quantization, pcm)
exec(project_dir + "src/communication/analog_signal/signal_dsp.sci", -1);
exec(project_dir + "src/communication/sampling/sampling_dsp.sci", -1);
exec(project_dir + "src/communication/quantization/quantization_dsp.sci", -1);
exec(project_dir + "src/communication/pcm/pcm_dsp.sci", -1);

// 4. Load UI Shell, Widgets, and Dashboards
exec(project_dir + "src/ui/widgets.sci", -1);
exec(project_dir + "src/ui/sidebar.sci", -1);
exec(project_dir + "src/ui/toolbar.sci", -1);
exec(project_dir + "src/ui/education.sci", -1);
exec(project_dir + "src/ui/workspace_manager.sci", -1);
exec(project_dir + "src/ui/dashboard.sci", -1); // Comm Lab inner pipeline block diagram
exec(project_dir + "src/ui/main_dashboard.sci", -1); // GUIVerse platform launcher

// 5. Load Simulation Module Panels and Stubs
exec(project_dir + "src/communication/stubs/home.sci", -1);
exec(project_dir + "src/communication/analog_signal/signal_generator.sci", -1);
exec(project_dir + "src/communication/sampling/sampling.sci", -1);
exec(project_dir + "src/communication/quantization/quantization.sci", -1);
exec(project_dir + "src/communication/pcm/pcm.sci", -1);
exec(project_dir + "src/communication/stubs/linecoding.sci", -1);
exec(project_dir + "src/communication/stubs/modulation.sci", -1);
exec(project_dir + "src/communication/stubs/noise.sci", -1);
exec(project_dir + "src/communication/stubs/receiver.sci", -1);
exec(project_dir + "src/communication/stubs/ber.sci", -1);
exec(project_dir + "src/communication/stubs/eye.sci", -1);
exec(project_dir + "src/communication/stubs/constellation.sci", -1);
exec(project_dir + "src/communication/stubs/comparison.sci", -1);

// 6. Register Laboratories in the Registry
registerLab("Communication Laboratory", "Production Ready", "Comm", "cb_launch_comm_lab()");
registerLab("Signals & Systems", "Coming Soon", "SigSys", "");
registerLab("DSP Laboratory", "Coming Soon", "DSP", "");
registerLab("Analog Electronics", "Coming Soon", "Analog", "");
registerLab("Digital Electronics", "Coming Soon", "Digital", "");
registerLab("Control Systems", "Coming Soon", "Control", "");
registerLab("RF Laboratory", "Coming Soon", "RF", "");
registerLab("Circuit Simulation", "Coming Soon", "Circuit", "");

// 7. Initialize the Application Global State
state = init_global_state();

// 8. Close pre-existing figure window to avoid duplicate instances
h_old_fig = find_main_figure();
if ~isempty(h_old_fig) then
    close(h_old_fig);
end

// 9. Instantiate Main GUI Window
fig = figure(...
    "Position", [100, 100, 1200, 750], ...
    "Figure_name", "GUIVerse - Modular Virtual Engineering Laboratory", ...
    "MenuBar", "none", ...
    "ToolBar", "none", ...
    "tag", "commverse_main_figure");

// Apply main background color
colors = get_theme_colors();
fig.background = color(colors.bg_main(1)*255, colors.bg_main(2)*255, colors.bg_main(3)*255);

// Store state in figure's user_data
state.ui.fig = fig;
fig.user_data = state;

// 10. Create Layout Partition Frames (Normalized Coordinates)
// - Launcher Main Dashboard Frame (Full screen, visible by default)
f_dashboard = uicontrol(fig, ...
    "style", "frame", ...
    "units", "normalized", ...
    "position", [0.0, 0.0, 1.0, 1.0], ...
    "visible", "on");
style_control(f_dashboard, "card_frame");
set(f_dashboard, "BackgroundColor", colors.bg_workspace);

// - Coming Soon Panel Frame (Full screen, hidden by default)
f_coming_soon = uicontrol(fig, ...
    "style", "frame", ...
    "units", "normalized", ...
    "position", [0.0, 0.0, 1.0, 1.0], ...
    "visible", "off");
style_control(f_coming_soon, "card_frame");
set(f_coming_soon, "BackgroundColor", colors.bg_workspace);

// - Top Toolbar Frame (Hidden by default)
f_toolbar = uicontrol(fig, ...
    "style", "frame", ...
    "units", "normalized", ...
    "position", [0.005, 0.945, 0.990, 0.050], ...
    "visible", "off");
style_control(f_toolbar, "card_frame");
set(f_toolbar, "BackgroundColor", colors.bg_main);

// - Left Sidebar Frame (Hidden by default)
f_sidebar = uicontrol(fig, ...
    "style", "frame", ...
    "units", "normalized", ...
    "position", [0.005, 0.045, 0.175, 0.895], ...
    "visible", "off");
style_control(f_sidebar, "card_frame");
set(f_sidebar, "BackgroundColor", colors.bg_main);

// - Center Workspace Panel Frame (Hidden by default)
f_workspace = uicontrol(fig, ...
    "style", "frame", ...
    "units", "normalized", ...
    "position", [0.185, 0.045, 0.560, 0.895], ...
    "visible", "off");
style_control(f_workspace, "card_frame");
set(f_workspace, "BackgroundColor", colors.bg_workspace);

// - Right Educational Card Panel Frame (Hidden by default)
f_education = uicontrol(fig, ...
    "style", "frame", ...
    "units", "normalized", ...
    "position", [0.750, 0.045, 0.245, 0.895], ...
    "visible", "off");
style_control(f_education, "card_frame");
set(f_education, "BackgroundColor", colors.bg_main);

// - Bottom Status Bar Frame (Hidden by default)
f_status = uicontrol(fig, ...
    "style", "frame", ...
    "units", "normalized", ...
    "position", [0.005, 0.005, 0.990, 0.035], ...
    "visible", "off");
style_control(f_status, "card_frame");
set(f_status, "BackgroundColor", colors.bg_main);

// 11. Save frame references back to state structure
state.ui.frame_dashboard = f_dashboard;
state.ui.frame_coming_soon = f_coming_soon;
state.ui.frame_toolbar = f_toolbar;
state.ui.frame_sidebar = f_sidebar;
state.ui.frame_workspace = f_workspace;
state.ui.frame_education = f_education;
state.ui.frame_status = f_status;

// Maintain legacy mappings for backward compatibility
state.ui.toolbar_panel = f_toolbar;
state.ui.sidebar_panel = f_sidebar;
state.ui.workspace_panel = f_workspace;
state.ui.education_panel = f_education;
state.ui.status_panel = f_status;
fig.user_data = state;

// 12. Instantiate Sub-Shell Layouts
ui_create_sidebar(fig, f_sidebar);
ui_create_toolbar(fig, f_toolbar);
ui_create_status_bar(fig, f_status);
ui_create_education(fig, f_education);
ui_create_main_dashboard(fig, f_dashboard);
ui_create_coming_soon(fig, f_coming_soon);

// 13. Instantiate all Module Panels inside Center Workspace
home_create_panel(fig, f_workspace);
ui_create_persistent_workspace(fig, f_workspace);
linecoding_create_panel(fig, f_workspace);
modulation_create_panel(fig, f_workspace);
noise_create_panel(fig, f_workspace);
receiver_create_panel(fig, f_workspace);
ber_create_panel(fig, f_workspace);
eye_create_panel(fig, f_workspace);
constellation_create_panel(fig, f_workspace);
comparison_create_panel(fig, f_workspace);

// 14. Run initial update pipeline to calculate default metrics
pipeline_update("signal");

// Pre-render and populate all module UI objects with their default DSP states in the background
state = fig.user_data;
mprintf("[INIT] Pre-rendering Analog Signal Generator background data...\n");
ui_render_module("signal_generator", state);
mprintf("[INIT] Pre-rendering Sampling background data...\n");
ui_render_module("sampling", state);
mprintf("[INIT] Pre-rendering Quantization background data...\n");
ui_render_module("quantization", state);
mprintf("[INIT] Pre-rendering PCM background data...\n");
ui_render_module("pcm", state);

// 15. Set default inner lab workspace panel to Home (block diagram)
state = fig.user_data;
state.active_module = "home";
fig.user_data = state;

disp("GUIVerse Laboratory Platform initialized successfully!");
