// =============================================================================
// GUIVerse - Independent Scilab GUI Repaint Diagnostic Test
// File: c:\Users\acer\Downloads\GUIVerse\tests\test_scilab_atomic_render.sce
// =============================================================================

clc;
funcprot(0);
mode(0);
disp("=== SCILAB NATIVE GUI ATOMIC RENDERING DIAGNOSTIC ===");

function widgets = create_test_widgets(parent_panel, prefix)
    widgets = struct();
    widgets.labels = list();
    widgets.sliders = list();
    
    // Create 6 labels and sliders to simulate complex controls
    for i = 1:6
        y_pos = 0.35 - (i-1)*0.05;
        
        lbl = uicontrol(parent_panel, ...
            "style", "text", ...
            "units", "normalized", ...
            "position", [0.05, y_pos, 0.40, 0.04], ...
            "string", prefix + " Label " + string(i) + ": Initial Value");
            
        sld = uicontrol(parent_panel, ...
            "style", "slider", ...
            "units", "normalized", ...
            "position", [0.50, y_pos, 0.45, 0.04], ...
            "Min", 0, "Max", 100, "Value", 50);
            
        widgets.labels($+1) = lbl;
        widgets.sliders($+1) = sld;
    end
    
    // Create a dropdown
    widgets.popup = uicontrol(parent_panel, ...
        "style", "popupmenu", ...
        "units", "normalized", ...
        "position", [0.05, 0.05, 0.90, 0.05], ...
        "string", "Option A|Option B|Option C|Option D", ...
        "Value", 1);
        
    // Create a push button
    widgets.btn = uicontrol(parent_panel, ...
        "style", "pushbutton", ...
        "units", "normalized", ...
        "position", [0.05, 0.12, 0.90, 0.04], ...
        "string", prefix + " Push Button");
endfunction

// --- TEST A: Normal Creation ---
function test_a()
    disp("[TEST A] Creating widgets directly on a visible figure...");
    fig = figure("Figure_name", "Test A - Direct Visible Creation", "MenuBar", "none", "Position", [100, 100, 500, 450]);
    
    tic();
    panel = uicontrol(fig, "style", "frame", "units", "normalized", "position", [0, 0, 1, 1]);
    
    // Create axes
    ax = newaxes(panel);
    ax.axes_bounds = [0.1, 0.5, 0.8, 0.45];
    plot2d([0, 1], [0, 1]);
    
    // Create widgets
    w = create_test_widgets(panel, "A");
    drawnow();
    
    t_elapsed = toc() * 1000;
    disp(sprintf("  -> [TEST A] Completed in %.2f ms", t_elapsed));
    sleep(500);
    close(fig);
endfunction

// --- TEST B: Hidden Initialization ---
function test_b()
    disp("[TEST B] Creating widgets on invisible figure, then setting visible...");
    fig = figure("Figure_name", "Test B - Invisible-to-Visible", "MenuBar", "none", "Position", [100, 100, 500, 450], "visible", "off");
    
    tic();
    panel = uicontrol(fig, "style", "frame", "units", "normalized", "position", [0, 0, 1, 1]);
    
    // Create axes
    ax = newaxes(panel);
    ax.axes_bounds = [0.1, 0.5, 0.8, 0.45];
    plot2d([0, 1], [0, 1]);
    
    // Create widgets
    w = create_test_widgets(panel, "B");
    
    // Show figure
    set(fig, "visible", "on");
    drawnow();
    
    t_elapsed = toc() * 1000;
    disp(sprintf("  -> [TEST B] Completed in %.2f ms", t_elapsed));
    sleep(500);
    close(fig);
endfunction

// --- TEST C: Parent Panel Visibility ---
function test_c()
    disp("[TEST C] Creating on hidden panel container inside visible figure, then setting panel visible...");
    fig = figure("Figure_name", "Test C - Parent Panel Visibility Switch", "MenuBar", "none", "Position", [100, 100, 500, 450]);
    
    tic();
    panel = uicontrol(fig, "style", "frame", "units", "normalized", "position", [0, 0, 1, 1], "visible", "off");
    
    // Create axes
    ax = newaxes(panel);
    ax.axes_bounds = [0.1, 0.5, 0.8, 0.45];
    plot2d([0, 1], [0, 1]);
    ax.visible = "off";
    
    // Create widgets
    w = create_test_widgets(panel, "C");
    
    // Transition (make visible)
    set(panel, "visible", "on");
    ax.visible = "on";
    drawnow();
    
    t_elapsed = toc() * 1000;
    disp(sprintf("  -> [TEST C] Completed in %.2f ms", t_elapsed));
    sleep(500);
    close(fig);
endfunction

// --- TEST D: Multiple Panels Switching ---
function test_d()
    disp("[TEST D] Switching visibility between two pre-created panels...");
    fig = figure("Figure_name", "Test D - Multi-panel Switch", "MenuBar", "none", "Position", [100, 100, 500, 450]);
    
    // Pre-create Panel 1
    p1 = uicontrol(fig, "style", "frame", "units", "normalized", "position", [0, 0, 1, 1], "visible", "on");
    ax1 = newaxes(p1);
    ax1.axes_bounds = [0.1, 0.5, 0.8, 0.45];
    plot2d([0, 1], [0, 1]);
    w1 = create_test_widgets(p1, "P1");
    
    // Pre-create Panel 2
    p2 = uicontrol(fig, "style", "frame", "units", "normalized", "position", [0, 0, 1, 1], "visible", "off");
    ax2 = newaxes(p2);
    ax2.axes_bounds = [0.1, 0.5, 0.8, 0.45];
    plot2d([0, 1], [1, 0]);
    ax2.visible = "off";
    w2 = create_test_widgets(p2, "P2");
    
    drawnow();
    sleep(500);
    
    // Switch transition
    tic();
    drawlater();
    set(p1, "visible", "off");
    ax1.visible = "off";
    
    set(p2, "visible", "on");
    ax2.visible = "on";
    drawnow();
    
    t_elapsed = toc() * 1000;
    disp(sprintf("  -> [TEST D] Completed in %.2f ms", t_elapsed));
    sleep(500);
    close(fig);
endfunction

// --- TEST E: No OpenGL ---
function test_e()
    disp("[TEST E] Switching visibility between two pre-created panels containing NO axes/plots...");
    fig = figure("Figure_name", "Test E - No OpenGL", "MenuBar", "none", "Position", [100, 100, 500, 450]);
    
    // Panel 1 (visible)
    p1 = uicontrol(fig, "style", "frame", "units", "normalized", "position", [0, 0, 1, 1], "visible", "on");
    w1 = create_test_widgets(p1, "E1");
    
    // Panel 2 (invisible)
    p2 = uicontrol(fig, "style", "frame", "units", "normalized", "position", [0, 0, 1, 1], "visible", "off");
    w2 = create_test_widgets(p2, "E2");
    
    drawnow();
    sleep(500);
    
    // Switch transition
    tic();
    drawlater();
    set(p1, "visible", "off");
    set(p2, "visible", "on");
    drawnow();
    
    t_elapsed = toc() * 1000;
    disp(sprintf("  -> [TEST E] Completed in %.2f ms", t_elapsed));
    sleep(500);
    close(fig);
endfunction

// --- TEST F: No Parent Visibility Switching (Persistent Panel) ---
function test_f()
    disp("[TEST F] Swapping contents on a single persistent visible panel...");
    fig = figure("Figure_name", "Test F - Persistent Panel Swap", "MenuBar", "none", "Position", [100, 100, 500, 450]);
    
    panel = uicontrol(fig, "style", "frame", "units", "normalized", "position", [0, 0, 1, 1]);
    
    // Axes
    ax = newaxes(panel);
    ax.axes_bounds = [0.1, 0.5, 0.8, 0.45];
    plot2d([0, 1], [0, 1]);
    h_line = ax.children(1).children(1);
    
    // Widgets
    w = create_test_widgets(panel, "F1");
    drawnow();
    sleep(500);
    
    // Transition
    tic();
    drawlater();
    
    // Update graph
    h_line.data = [0, 1; 1, 0];
    
    // Update uicontrol states
    for i = 1:size(w.labels)
        set(w.labels(i), "string", "F2 Label " + string(i) + ": Updated Value");
        set(w.sliders(i), "Value", 80);
    end
    set(w.popup, "Value", 3);
    set(w.btn, "string", "F2 Push Button");
    
    drawnow();
    t_elapsed = toc() * 1000;
    disp(sprintf("  -> [TEST F] Completed in %.2f ms", t_elapsed));
    sleep(500);
    close(fig);
endfunction

// Run diagnostics sequential
test_a();
test_b();
test_c();
test_d();
test_e();
test_f();

disp("=== DIAGNOSTIC RUNS COMPLETED SUCCESSFULLY ===");
exit(0);
