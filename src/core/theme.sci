// =============================================================================
// GUIVerse - Theme Definitions and Styling Utilities
// File: src/core/theme.sci
// =============================================================================

function colors = get_theme_colors()
    // Returns the color palette values (RGB vectors normalized to [0, 1])
    colors = struct(...
        "bg_main", [0.08, 0.09, 0.11], ...      // Dark slate background for sidebar (RGB 20, 22, 28)
        "bg_workspace", [0.12, 0.14, 0.17], ... // Slightly lighter for main workspace (RGB 30, 35, 43)
        "bg_panel", [0.15, 0.17, 0.20], ...     // Slate blue-gray for control cards (RGB 38, 43, 51)
        "bg_input", [0.20, 0.22, 0.26], ...     // Lightest dark for fields/sliders (RGB 51, 56, 66)
        "text_primary", [1.0, 1.0, 1.0], ...     // Pure white for readability (RGB 255, 255, 255)
        "text_muted", [0.75, 0.77, 0.80], ...   // Light gray-blue for secondary text (RGB 191, 196, 204)
        "text_dark", [0.45, 0.47, 0.50], ...    // Gray for disabled text (RGB 115, 120, 128)
        "accent_cyan", [0.00, 0.75, 0.75], ...  // Primary branding cyan (RGB 0, 191, 191)
        "accent_blue", [0.22, 0.53, 0.90], ...  // Digital signal color (RGB 56, 135, 230)
        "accent_green", [0.18, 0.70, 0.35], ... // Success/Pass state green (RGB 46, 178, 89)
        "accent_red", [0.85, 0.25, 0.25], ...   // Warning/Error state red (RGB 217, 64, 64)
        "accent_yellow", [0.90, 0.65, 0.12], ... // Highlights/GATE tips yellow (RGB 230, 165, 30)
        "font_name", "sansserif", ...
        "font_mono", "monospaced", ...
        "fs_title", 15, ...
        "fs_header", 12, ...
        "fs_normal", 10, ...
        "fs_small", 9 ...
    );
endfunction

function res = is_valid_handle(h)
    // Scilab-safe replacement for MATLAB's ishandle.
    // Checks if type is 9 (handle) and if the handle points to a valid graphic object.
    if type(h) == 9 then
        res = is_handle_valid(h);
    else
        res = %f;
    end
endfunction

function style_axes_dark(ax)
    // Styles a Scilab axes entity (ax) with a dark theme to match modern DSP software.
    // Inputs:
    //   ax: graphic handle of the axes (e.g. gca())
    
    if ~is_valid_handle(ax) | ax.type <> "Axes" then
        return; // Safe exit if not a valid axes handle
    end
    
    colors = get_theme_colors();
    
    // Convert normalized RGB colors to colormap index or use the color() function.
    c_bg = color(colors.bg_workspace(1)*255, colors.bg_workspace(2)*255, colors.bg_workspace(3)*255);
    c_fg = color(colors.text_primary(1)*255, colors.text_primary(2)*255, colors.text_primary(3)*255);
    c_grid = color(colors.bg_input(1)*255, colors.bg_input(2)*255, colors.bg_input(3)*255);
    c_muted = color(colors.text_muted(1)*255, colors.text_muted(2)*255, colors.text_muted(3)*255);
    
    // Background and frame properties
    ax.background = c_bg;
    ax.foreground = c_fg;
    ax.labels_font_color = c_muted;
    ax.labels_font_size = 2; // Clean medium size
    ax.labels_font_style = 6; // Sans-serif font (Helvetica)
    
    // Grid settings
    ax.grid = [c_grid, c_grid];
    ax.grid_style = [7, 7]; // Dotted line style
    ax.grid_thickness = [1, 1];
    
    // Title and Labels styling
    if is_valid_handle(ax.title) then
        ax.title.font_color = c_fg;
        ax.title.font_size = 2.5;
        ax.title.font_style = 6; // Bold/Sans-serif
    end
    
    if is_valid_handle(ax.x_label) then
        ax.x_label.font_color = c_muted;
        ax.x_label.font_size = 2;
        ax.x_label.font_style = 6;
    end
    
    if is_valid_handle(ax.y_label) then
        ax.y_label.font_color = c_muted;
        ax.y_label.font_size = 2;
        ax.y_label.font_style = 6;
    end
endfunction

function style_control(h, style_class)
    // Styles generic uicontrol objects based on a CSS-like class name.
    // Inputs:
    //   h: handle of the uicontrol
    //   style_class: string matching 'button', 'active_button', 'header', 'label', 'panel_frame', 'input'
    
    if ~is_valid_handle(h) then
        return;
    end
    
    colors = get_theme_colors();
    
    set(h, "FontName", colors.font_name);
    
    select style_class
    case "sidebar_button"
        set(h, "BackgroundColor", colors.bg_main);
        set(h, "ForegroundColor", colors.text_muted);
        set(h, "FontSize", colors.fs_normal);
        set(h, "FontWeight", "normal");
        
    case "sidebar_active_button"
        set(h, "BackgroundColor", colors.bg_panel);
        set(h, "ForegroundColor", colors.accent_cyan);
        set(h, "FontSize", colors.fs_normal);
        set(h, "FontWeight", "bold");
        
    case "header"
        set(h, "BackgroundColor", colors.bg_main);
        set(h, "ForegroundColor", colors.accent_cyan);
        set(h, "FontSize", colors.fs_title);
        set(h, "FontWeight", "bold");
        
    case "panel_header"
        set(h, "BackgroundColor", colors.bg_panel);
        set(h, "ForegroundColor", colors.accent_cyan);
        set(h, "FontSize", colors.fs_header);
        set(h, "FontWeight", "bold");
        
    case "label"
        set(h, "BackgroundColor", colors.bg_panel);
        set(h, "ForegroundColor", colors.text_primary);
        set(h, "FontSize", colors.fs_normal);
        set(h, "FontWeight", "normal");
        
    case "label_muted"
        set(h, "BackgroundColor", colors.bg_panel);
        set(h, "ForegroundColor", colors.text_muted);
        set(h, "FontSize", colors.fs_small);
        set(h, "FontWeight", "normal");
        
    case "card_frame"
        set(h, "BackgroundColor", colors.bg_panel);
        set(h, "Relief", "flat"); // Flat, modern card borders
        
    case "input"
        set(h, "BackgroundColor", colors.bg_input);
        set(h, "ForegroundColor", colors.text_primary);
        set(h, "FontSize", colors.fs_normal);
        
    case "action_button"
        set(h, "BackgroundColor", colors.accent_blue);
        set(h, "ForegroundColor", [1, 1, 1]); // Clean white text
        set(h, "FontSize", colors.fs_normal);
        set(h, "FontWeight", "bold");
    end
endfunction

function h_fig = find_main_figure()
    // Returns the current active figure handle directly.
    // In our single-window setup, this is always the main GUI window.
    h_fig = gcf();
endfunction
