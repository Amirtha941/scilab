// =============================================================================
// CommVerse - Home Module Wiring
// File: src/modules/home.sci
// =============================================================================

function home_create_panel(fig, workspace_panel)
    // Creates the Home panel frame inside the main center workspace,
    // and delegates its widget population to the dashboard renderer.
    // Inputs:
    //   fig: graphic handle of the main window
    //   workspace_panel: handle of the center workspace container frame
    
    colors = get_theme_colors();
    
    h_panel = uicontrol(workspace_panel, ...
        "style", "frame", ...
        "units", "normalized", ...
        "position", [0, 0, 1, 1], ...
        "visible", "on"); // Home panel is visible on startup
    style_control(h_panel, "card_frame");
    set(h_panel, "BackgroundColor", colors.bg_workspace);
    
    // Build the interactive dashboard inside this panel
    ui_create_dashboard(fig, h_panel);
    
    // Register this panel in the global structure using list mapper helper
    state = fig.user_data;
    state = ui_set_module_panel(state, "home", h_panel);
    fig.user_data = state;
endfunction

