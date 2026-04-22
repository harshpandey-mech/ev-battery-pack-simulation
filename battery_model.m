function [V_oc, V_RC, V_terminal] = battery_model(I, SoC, p)
% BATTERY_MODEL  First-order Thevenin equivalent circuit for a Li-ion pack.
%
%   Implements the full Thevenin model as described in README and CV:
%
%       ┌─── R0_pack ───┬─── R1_pack ───┐
%       │               │               │
%    V_oc(SoC)      ╪ C1_pack ╪         V_terminal
%       │               │               │
%       └───────────────┴───────────────┘
%
%   Equations:
%     OCV  :  V_oc(k)  = N_S × [a_OCV + b_OCV × SoC(k)]
%
%     RC branch (discrete-time update):
%             V_RC(k) = V_RC(k-1) × exp(-Δt/τ) + R1 × I(k) × [1 - exp(-Δt/τ)]
%             where τ = R1_pack × C1_pack  (= 7.5 s)
%
%     Terminal voltage:
%             V_terminal(k) = V_oc(k) - I(k) × R0_pack - V_RC(k)
%
%   The RC branch captures charge-transfer transient dynamics that the
%   simple R0-only model misses — important for accurate pulse-load response
%   and BMS state estimation.
%
%   Physical interpretation of parameters:
%     R0  = ohmic resistance (electrolyte + contact + current collectors)
%     R1  = charge-transfer resistance (Butler-Volmer kinetics at electrode)
%     C1  = double-layer capacitance (electrode-electrolyte interface)
%
%   Inputs:
%     I    : current profile (A), N×1  [positive = discharge, negative = regen]
%     SoC  : state-of-charge (0–1), N×1
%     p    : parameter struct from main_simulation.m
%              p.N_S, p.a_OCV, p.b_OCV  — OCV model
%              p.R0_pack, p.R1_pack, p.C1_pack  — circuit elements
%              p.dt  — time step (s)
%
%   Outputs:
%     V_oc       : open-circuit voltage (V), N×1
%     V_RC       : RC branch voltage (V), N×1
%     V_terminal : terminal (loaded) voltage (V), N×1

N        = length(I);
dt       = p.dt;
tau      = p.R1_pack * p.C1_pack;   % RC time constant (s)
exp_fac  = exp(-dt / tau);           % pre-compute for efficiency

% ── OCV vector (pack level) ──────────────────────────────────────────────
% V_oc = N_S × (a_OCV + b_OCV × SoC)
V_oc = p.N_S .* (p.a_OCV + p.b_OCV .* SoC);

% ── RC branch voltage — discrete-time recursive update ────────────────────
% The exact discrete-time solution of dV_RC/dt = (R1·I - V_RC)/τ is:
%   V_RC(k) = V_RC(k-1)·exp(-Δt/τ) + R1·I(k)·[1 - exp(-Δt/τ)]
%
% This avoids numerical stiffness from the small time constant (τ = 7.5 s)
% and is the standard method in BMS embedded implementations.

V_RC       = zeros(N, 1);
V_RC(1)    = 0.0;    % RC capacitor uncharged at start of cycle

for k = 2 : N
    V_RC(k) = V_RC(k-1) * exp_fac + p.R1_pack * I(k) * (1.0 - exp_fac);
end

% ── Terminal voltage ──────────────────────────────────────────────────────
V_terminal = V_oc - I .* p.R0_pack - V_RC;

end
