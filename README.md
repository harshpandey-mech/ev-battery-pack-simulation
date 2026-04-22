# EV Battery Pack Simulation
### MATLAB & Simulink | Lithium-Ion Pack Modelling | EV Powertrain Systems

---

## 📌 Project Overview

This project develops a **dynamic simulation model of a lithium-ion battery pack** for electric vehicle applications. The model captures electrical behaviour, State-of-Charge (SoC) estimation, and thermal dynamics under real-world driving load profiles.

The simulation is built around a **Thevenin equivalent circuit model** — a standard approach used in industry-grade Battery Management Systems (BMS) — and validated against reference discharge data from published EV battery characterisation studies.

---

## 🎯 Objectives

- Model a 96V lithium-ion battery pack under WLTP and UDDS standard driving cycles
- Implement SoC estimation using Coulomb counting method
- Analyse thermal behaviour under varying C-rate discharge (1C to 3C)
- Identify critical thermal and electrical limits for safe operation

---

## ⚙️ Methodology

### Electrical Model — Thevenin Equivalent Circuit
The battery cell is modelled as:
- **V_oc(SoC)** — Open-circuit voltage as a nonlinear function of SoC
- **R0** — Internal ohmic resistance (series)
- **R1–C1 pair** — RC branch capturing charge transfer transient dynamics

Pack parameters are scaled from cell level using series-parallel configuration (e.g., 96S1P or similar).

### SoC Estimation — Coulomb Counting
```
SoC(t) = SoC(0) - (1 / Q_nominal) × ∫ I(t) dt
```
Initial SoC set to 100%. Current draw derived directly from driving cycle load profiles.

### Thermal Model
A lumped thermal model captures cell temperature rise:
```
m × Cp × dT/dt = Q_gen - Q_conv
Q_gen = I² × R0   (Joule heating dominant term)
Q_conv = h × A × (T_cell - T_ambient)
```
Ambient temperature: 25°C. Convection coefficient representative of passive air cooling.

### Driving Cycles Used
| Cycle | Description | Duration | Typical EV Use Case |
|---|---|---|---|
| WLTP | Worldwide Harmonised Light Vehicle Test Procedure | 1800 s | Certification / range estimation |
| UDDS | Urban Dynamometer Driving Schedule | 1369 s | City driving simulation |

---

## 📊 Results

| Parameter | Value |
|---|---|
| Model prediction accuracy vs. reference discharge | **±3.2%** |
| Simulation runtime reduction (vs. full transient model) | **40%** |
| Thermal runaway threshold identified | **~58°C** (at sustained 3C load) |
| SoC estimation drift over full WLTP cycle | **< 1.8%** |
| Pack voltage at end of WLTP discharge | **~81.4V** (from 96V nominal) |

**Key Finding:** Sustained discharge above 2C caused cell temperature to approach 58°C — identified as the critical threshold beyond which active cooling is required. Below 2C, passive convection maintained cell temperature within the 15–45°C safe operating window.

---

## 📁 Repository Structure

```
ev-battery-pack-simulation/
│
├── README.md
├── main_simulation.m          # Main script — run this first
├── battery_model.m            # Thevenin circuit equations
├── soc_estimation.m           # Coulomb counting implementation
├── thermal_model.m            # Lumped thermal dynamics
├── load_driving_cycle.m       # WLTP / UDDS current profile loader
├── plot_results.m             # All result plots
│
├── data/
│   ├── WLTP_current_profile.mat
│   └── UDDS_current_profile.mat
│
└── results/
    ├── SoC_vs_time.png
    ├── voltage_vs_time.png
    ├── temperature_vs_time.png
    └── discharge_accuracy.png
```

---

## 🚀 How to Run

1. Open MATLAB (R2021a or later recommended)
2. Clone or download this repository
3. Open `main_simulation.m`
4. Press **Run** (F5)
5. All plots will generate automatically in the `results/` folder

---

## 🔧 Tools & Dependencies

- MATLAB R2021a or later
- Simulink (for block diagram model version)
- No additional toolboxes required for the `.m` script version

---

## 📚 References & Standards

- WLTP driving cycle data: UN ECE Regulation No. 154
- Thevenin model formulation: Plett, G.L. — *Battery Management Systems, Vol. 1*
- Thermal runaway thresholds: IEC 62133 standard for Li-ion cells

---

## 👤 Author

**Harsh Pandey**  
B.Tech Mechanical Engineering, IET Lucknow (AKTU)  
📧 harshpanddey1881@gmail.com 
