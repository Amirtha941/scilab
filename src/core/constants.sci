// =============================================================================
// CommVerse - Physical and DSP Constants
// File: src/core/constants.sci
// =============================================================================

function consts = get_constants()
    // Returns a structured container for physical, mathematical, and DSP defaults.
    // This avoids hardcoding variables and maintains single-point configuration.
    consts = struct(...
        "pi", %pi, ...
        "c", 299792458, ...       // Speed of light (m/s)
        "k_B", 1.380649e-23, ...  // Boltzmann's constant (J/K)
        "T_ref", 290, ...         // Standard Noise Temperature (K)
        "q", 1.602176634e-19, ... // Electron charge (C)
        "default_fs_analog", 2000.0, ... // Internal analog-equivalent sample rate
        "default_f_carrier", 100.0, ...  // Default RF carrier frequency (Hz)
        "max_plot_points", 1000 ...      // Max points to display for smooth UI plotting
    );
endfunction

function log_timing(stage, elapsed_ms)
    mprintf("[TIMING] %s: %.2f ms\n", stage, elapsed_ms);
endfunction
