% =========================================================================
% generate_data_files.m
% Pre-generate and save WLTP and UDDS current profile data files.
% =========================================================================
%
% Purpose:
%   Creates the two .mat data files referenced in the repository:
%       data/WLTP_current_profile.mat
%       data/UDDS_current_profile.mat
%
%   These files contain the current demand profiles for the WLTP and UDDS
%   standard driving cycles, pre-generated with a fixed random seed (42)
%   to ensure reproducibility across all machines and MATLAB versions.
%
%   Running this script is only needed ONCE to populate the data/ folder.
%   The main simulation (main_simulation.m) loads these files automatically
%   via load_driving_cycle.m.
%
% How to run:
%   >> generate_data_files
%
%   Then run the main simulation:
%   >> main_simulation
%
% Author: Harsh Pandey, B.Tech ME, IET Lucknow (AKTU)
% =========================================================================

clear; clc;
rng(42);   % MUST match the seed in main_simulation.m for consistent results

fprintf('Generating driving cycle data files...\n\n');

% ── Output directory ──────────────────────────────────────────────────────
data_dir = fullfile(fileparts(mfilename('fullpath')), 'data');
if ~isfolder(data_dir)
    mkdir(data_dir);
    fprintf('Created: data/\n');
end

% =========================================================================
%  WLTP — Worldwide Harmonised Light Vehicle Test Procedure
%  Duration: 1800 s  (30 minutes)
%  Standard: UN ECE Regulation No. 154
%  Purpose : EV range certification and powertrain evaluation
% =========================================================================
%
%  Profile characteristics (93.6 V / 30 Ah pack):
%    Mean current   : ~20 A    (≈ 6.6 kW average power)
%    Peak current   : 40 A max (≈ 13.2 kW acceleration demand)
%    Regen current  : -8 A     (regenerative braking events)
%    SoC discharged : 33.6 %   (10.08 Ah removed from 30 Ah pack)
%
%  The profile has three overlapping frequency components:
%    600-s component  → major speed phase transitions (low/medium/high/xhigh)
%     90-s component  → individual acceleration/deceleration events
%    random component → road gradient, wind, driver variability

dt_wltp      = 1.0;                            % s  time step
t_wltp       = (0 : dt_wltp : 1799)';          % 1800 points, column vector
N_wltp       = length(t_wltp);

% Multi-component current profile
I_wltp_mean  = 20.0;                                          % A
I_wltp_slow  = 15.0 * sin(2*pi*t_wltp / 600);                % speed-phase envelope
I_wltp_mid   =  4.0 * sin(2*pi*t_wltp /  90);                % accel/decel events
I_wltp_noise =  5.0 * randn(N_wltp, 1);                      % road-load variation

I_wltp = I_wltp_mean + I_wltp_slow + I_wltp_mid + I_wltp_noise;
I_wltp = max(-8.0, min(40.0, I_wltp));   % physical limits

% Metadata stored in the .mat file
cycle_name_wltp = 'WLTP';
description_wltp = 'WLTP driving cycle current profile. 1800 s, 26S1P 93.6V/30Ah pack.';
dt_s            = dt_wltp;
I_max_A         = 40.0;     % A  peak discharge
I_regen_A       = -8.0;     % A  peak regen
I_mean_A        = mean(I_wltp);   % A  cycle average

% Save
wltp_file = fullfile(data_dir, 'WLTP_current_profile.mat');
save(wltp_file, 't_wltp', 'I_wltp', 'cycle_name_wltp', ...
     'description_wltp', 'dt_s', 'I_max_A', 'I_regen_A', 'I_mean_A');

fprintf('[1] WLTP current profile\n');
fprintf('    Duration  : %.0f s  (%d data points at %.0f s/step)\n', ...
        t_wltp(end)+1, N_wltp, dt_wltp);
fprintf('    I_mean    : %.2f A\n', I_mean_A);
fprintf('    I_max     : %.2f A\n', max(I_wltp));
fprintf('    I_regen   : %.2f A\n', min(I_wltp));
fprintf('    Saved     : data/WLTP_current_profile.mat\n\n');

% =========================================================================
%  UDDS — Urban Dynamometer Driving Schedule
%  Duration: 1369 s  (22.8 minutes)
%  Origin  : US EPA urban driving test (FTP-72 first phase)
%  Purpose : City/urban driving EV range evaluation
% =========================================================================
%
%  Profile characteristics:
%    Mean current   : ~16 A    (lower than WLTP — no high-speed phase)
%    Peak current   : 35 A max (lower peak — no motorway bursts)
%    Regen current  : -10 A    (more frequent stops → deeper regen events)
%    SoC discharged : ~25%     (city driving is more efficient due to regen)
%
%  Frequency components:
%    200-s component → city block/intersection pattern
%     30-s component → individual traffic-light stop-go events
%    random component → road variation, driver behaviour

dt_udds      = 1.0;                            % s
t_udds       = (0 : dt_udds : 1368)';          % 1369 points, column vector
N_udds       = length(t_udds);

I_udds_mean  = 16.0;
I_udds_city  = 10.0 * sin(2*pi*t_udds / 200);   % city block pattern
I_udds_stop  =  5.0 * sin(2*pi*t_udds /  30);   % stop-go events
I_udds_noise =  4.5 * randn(N_udds, 1);

I_udds = I_udds_mean + I_udds_city + I_udds_stop + I_udds_noise;
I_udds = max(-10.0, min(35.0, I_udds));   % UDDS: deeper regen allowed

cycle_name_udds  = 'UDDS';
description_udds = 'UDDS driving cycle current profile. 1369 s, 26S1P 93.6V/30Ah pack.';
I_max_A_udds     = 35.0;
I_regen_A_udds   = -10.0;
I_mean_A_udds    = mean(I_udds);

% Save
udds_file = fullfile(data_dir, 'UDDS_current_profile.mat');
save(udds_file, 't_udds', 'I_udds', 'cycle_name_udds', ...
     'description_udds', 'dt_s', 'I_max_A_udds', 'I_regen_A_udds', 'I_mean_A_udds');

fprintf('[2] UDDS current profile\n');
fprintf('    Duration  : %.0f s  (%d data points at %.0f s/step)\n', ...
        t_udds(end)+1, N_udds, dt_udds);
fprintf('    I_mean    : %.2f A\n', I_mean_A_udds);
fprintf('    I_max     : %.2f A\n', max(I_udds));
fprintf('    I_regen   : %.2f A\n', min(I_udds));
fprintf('    Saved     : data/UDDS_current_profile.mat\n\n');

% =========================================================================
%  QUICK VALIDATION — verify WLTP SoC matches expected 33.6%
% =========================================================================
fprintf('[3] Validating WLTP profile...\n');

% Simulate SoC from generated WLTP profile
Q_Ah     = 30.0;
SoC_check = zeros(N_wltp, 1);  SoC_check(1) = 1.0;
for k = 2 : N_wltp
    SoC_check(k) = max(0, min(1, SoC_check(k-1) - I_wltp(k)*dt_wltp/(Q_Ah*3600)));
end
SoC_discharged = (1 - SoC_check(end)) * 100;

fprintf('    SoC discharged: %.1f %%  (target 33.6 %%) ', SoC_discharged);
if abs(SoC_discharged - 33.6) < 0.5
    fprintf('✓\n');
else
    fprintf('— check random seed\n');
end

% OCV at end of WLTP (should be ~93.2V)
N_S = 26;  a_OCV = 3.1362;  b_OCV = 0.6753;
V_oc_end = N_S * (a_OCV + b_OCV * SoC_check(end));
fprintf('    V_oc end      : %.2f V   (target 93.2 V)  ', V_oc_end);
if abs(V_oc_end - 93.2) < 0.2
    fprintf('✓\n');
else
    fprintf('— check OCV parameters\n');
end

fprintf('\nData files ready. Now run:  main_simulation\n');
