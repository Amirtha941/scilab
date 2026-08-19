# GUIVerse - Modular Virtual Engineering Laboratory Platform

**GUIVerse** is an interactive, modular virtual engineering laboratory platform built entirely in **Scilab**. Designed for undergraduate students in Electronics and Communication Engineering (ECE), it provides a single-window interface to simulate, analyze, and build intuition for digital communication chains in real-time.

---

## 🚀 Key Features

GUIVerse v1.0 implements the first four primary stages of the physical layer communication link:

1. **Analog Message Source Generator**
   * Real-time generation of baseband continuous signals: Cosine waves, Square pulse trains, Triangle waveforms, and Pseudo-Random Binary Sequences (PRBS).
   * Sliders for Amplitude, Frequency, and Phase adjustments.
   * Dynamic calculations for Time Period ($T$), Peak-to-Peak ($V_{pp}$), and RMS ($V_{rms}$) values.

2. **Uniform Sampling & Whittaker Reconstruction**
   * Discretization of baseband signals at customizable sampling rates ($f_s$).
   * Double-axes visualization: Original vs. Reconstructed overlay (left) and Discrete Sample Stems (right).
   * Real-time aliasing detection based on the Nyquist-Shannon criteria ($f_s < 2f_m$).
   * Sinc interpolation matrix calculation to perform Whittaker-Shannon reconstruction, with live Root-Mean-Square Error (RMSE) metrics.

3. **Uniform & Non-Uniform Quantization**
   * Resolution mapping supporting $2, 4, 8, 16, 32,$ and $64$ discrete levels ($N$-bit depth).
   * Supports **Uniform Midrise**, **Uniform Midtread**, and **Non-Uniform $\mu$-law Companding** ($\mu=255$) compression and expansion.
   * Live calculations of step size ($\Delta$), maximum error, measured Signal-to-Quantization Noise Ratio (SQNR), and theoretical sinusoidal SQNR ($1.76 + 6.02N$ dB).

4. **PCM Encoding & Serial Link**
   * Binary encoding of quantized voltage indices to $N$-bit parallel binary words.
   * Parallel-to-serial conversion flattening indices into a continuous bitstream.
   * Computation of transmission bit rate ($R_b = f_s \log_2(L)$) and minimum Nyquist channel bandwidth ($B_{min} = R_b/2$).
   * Complete receiver decoding and Whittaker-Shannon recovery visualization.
   * Scrollable sample-by-sample index mapping table displaying: `Sample # \| Time (s) \| Sample (V) \| Quant (V) \| Code Index \| Binary Word`.

---

## 🛠️ Codebase Architecture

The application implements a custom **Single-window MVC-like pattern** designed to bypass Scilab's Java Swing and OpenGL repaint limitations:

* **Persistent Workspace Manager**: Pre-allocates uicontrol widgets and plot coordinate axes *once* at startup. When navigating between modules, layouts, visibilities, and label bindings are reconfigured **in-place** to avoid graphical flickering or overlapping canvases.
* **Centralized Reactive Pipeline**: When a user adjusts a parameter, a callback writes to the global state (stored in the main figure's `user_data` property) and triggers `pipeline_update(start_stage)`. Recalculations are propagated downstream from the modified stage, preventing redundant calculations.
* **Swing-to-OpenGL Sync**: Rendering transitions follow a strict sequence (Panel Visible $\rightarrow$ Widget Reconfigure $\rightarrow$ DSP Compute $\rightarrow$ Axes Visible $\rightarrow$ centralized `drawnow()`) to flush Swing and OpenGL repaints atomically.
* **Theory & Insights Integration**: An educational side panel displays theoretical details, formulas, and ECE exam insights (aligned with GATE syllabus) dynamically matched to the active module.
* **Pop-out Analysis Views**: Magnifying glass buttons next to plots open separate figures, cloning the active module's curves onto pop-out screens for high-resolution analysis.

---

## 📂 Directory Structure

```
GUIVerse/
├── guiverse.sce              # Application entry point script
├── README.md                 # Project documentation and manual
├── src/
│   ├── core/
│   │   ├── constants.sci     # DSP and mathematical constants
│   │   ├── theme.sci         # Theme colors, styling wrappers, and figure lookups
│   │   ├── callbacks.sci     # Sliders, dropdowns, reset, and plot callbacks
│   │   └── registry.sci      # Laboratory registration and launcher controllers
│   ├── state/
│   │   └── state.sci         # Centralized state templates and list maps
│   ├── router/
│   │   └── router.sci        # Routing engine and Centralized Pipeline Update
│   ├── communication/
│   │   ├── analog_signal/
│   │   │   ├── signal_dsp.sci       # Signal generator DSP algorithms
│   │   │   └── signal_generator.sci # Signal UI rendering function definitions
│   │   ├── sampling/
│   │   │   ├── sampling_dsp.sci     # Discretization and sinc reconstruction DSP
│   │   │   └── sampling.sci         # Sampling UI rendering function definitions
│   │   ├── quantization/
│   │   │   ├── quantization_dsp.sci # Midrise/midtread/mu-law quantizer DSP
│   │   │   └── quantization.sci     # Quantization UI rendering function definitions
│   │   ├── pcm/
│   │   │   ├── pcm_dsp.sci          # Parallel binary encoding, serialization, decoding DSP
│   │   │   └── pcm.sci              # PCM UI rendering function definitions
│   │   └── stubs/                   # Planned ECE modules placeholder panels
│   │       ├── home.sci             # Home panel wrapper (delegates to dashboard.sci)
│   │       ├── linecoding.sci       # Stub for NRZ/RZ/Manchester line codes
│   │       ├── modulation.sci       # Stub for ASK/FSK/PSK carriers
│   │       ├── noise.sci            # Stub for AWGN channels
│   │       ├── receiver.sci         # Stub for matched filters and correlators
│   │       ├── ber.sci              # Stub for BER performance plots
│   │       ├── eye.sci              # Stub for Inter-Symbol Interference (ISI) diagrams
│   │       ├── constellation.sci    # Stub for complex IQ vector spaces
│   │       └── comparison.sci       # Stub for spectral efficiency comparison
│   └── ui/
│       ├── widgets.sci       # Card frames, slider, dropdown groups, and status updates
│       ├── sidebar.sci       # Left navigation sidebar builder
│       ├── toolbar.sci       # Top toolbar (Reset, Export Report, Theme toggles)
│       ├── education.sci     # Dynamic theory console and insights compiler
│       ├── workspace_manager.sci # Shared persistent workspace builder
│       ├── dashboard.sci     # Laboratory Home dashboard and block diagram
│       └── main_dashboard.sci# Platform launcher, resume cards, and laboratory grid
└── tests/
    └── test_scilab_atomic_render.sce # Visual repaint performance diagnostic script
```

---

## 🏃 How to Run the Application

### Prerequisites
* **Scilab 6.x** or **Scilab 2024/2025** (Runs natively without external toolboxes).
* OpenGL-enabled graphics card/drivers.

### Execution Steps
1. Start Scilab.
2. In the Scilab console, navigate to the `GUIVerse` directory:
   ```scilab
   cd 'path/to/GUIVerse'
   ```
3. Run the main entry script:
   ```scilab
   exec('guiverse.sce');
   ```
4. The **GUIVerse Main Launcher** will open. Click **Launch** on the *Communication Laboratory* card to open the workspace.
5. Navigate through the laboratory by clicking on the left sidebar menus or clicking directly on the block diagram stages in the Home dashboard.
6. Click **Reset System** on the top toolbar to restore default parameters, or click **Exit to Launcher** on the sidebar to return to the launcher menu.
7. Click the **magnifying glass (🔍)** icon next to any plot card to pop out a resizable analysis window.

---

## 🧪 Visual Repaint Diagnostic Test

The project includes an automated diagnostic test to verify Scilab's repainting latency under different layout patterns.

To run the diagnostic test:
1. In the Scilab console, navigate to the `GUIVerse` folder.
2. Run the test script:
   ```scilab
   exec('tests/test_scilab_atomic_render.sce');
   ```
3. The script will open and close figures sequentially, measuring latency in milliseconds for six rendering patterns (normal creation, hidden initialization, parent frame switches, multiple panel swaps, Swing-only, and single-panel in-place swap).
4. View the results printed in the Scilab console. (The *Single-Panel Swap* pattern validated in Test F is the stabilized method utilized in the GUIVerse workspace).

---

## 🗺️ Roadmap & Future Modules

GUIVerse is structured to accommodate future laboratories (DSP, Signals & Systems, Control Systems, Analog/Digital Electronics) and additional digital communication modules:

* **Phase 2 (Line Coding & Carriers)**: Implement line coding algorithms (NRZ, RZ, Manchester, Bipolar AMI) and digital carriers (ASK, FSK, BPSK, QPSK, QAM).
* **Phase 3 (Impairments)**: Introduce AWGN channel noise generators, phase offsets, and attenuation factors.
* **Phase 4 (Advanced Visuals)**: Implement constellation explorers, eye diagram generators, matched filters, and Monte Carlo bit error rate (BER) testers.
* **Phase 5 (Classroom Integration)**: Guided laboratory exercises, student progress saving, interactive quizzes, and signable PDF report exports.
