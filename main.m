% MAIN Purpose: run sanity checks followed by all LTE scheduler experiments.
% Inputs: none; all experiment settings come from default_params.
% Outputs: CSV data in results/, PNG figures in plots/, and a printed default-case summary.
% Equation: displayed throughput is converted from bps to Mbps or kbps only for reporting.

clear; clc;
project_root = fileparts(mfilename('fullpath'));
cd(project_root);
addpath(project_root); addpath(fullfile(project_root, 'tests'));
if ~exist('results', 'dir')
    mkdir('results');
end
if ~exist('plots', 'dir')
    mkdir('plots');
end
run(fullfile(project_root, 'tests', 'sanity_checks.m'));

fprintf('Running E1: number of users experiment...\n');
timer_start = tic; run(fullfile(project_root, 'run_experiment_E1.m')); fprintf('E1 elapsed time: %.2f s\n', toc(timer_start));
fprintf('Running E2: PF averaging-window experiment...\n');
timer_start = tic; run(fullfile(project_root, 'run_experiment_E2_tc.m')); fprintf('E2 elapsed time: %.2f s\n', toc(timer_start));
fprintf('Running E3: Doppler experiment...\n');
timer_start = tic; run(fullfile(project_root, 'run_experiment_E3_doppler.m')); fprintf('E3 elapsed time: %.2f s\n', toc(timer_start));
fprintf('Running E4: distance experiment...\n');
timer_start = tic; run(fullfile(project_root, 'run_experiment_E4_distance.m')); fprintf('E4 elapsed time: %.2f s\n', toc(timer_start));

params = default_params();
rng(1); [~, gbar] = user_setup(params.K, params.d_min, params.d_max, params.ple, params.snr_ref_dB);
H = generate_channels(params, 1);
fprintf('\nDefault results (K=%d, tc=%d, fd=%g Hz, seed=1)\n', params.K, params.tc, params.fd);
fprintf('%-8s %18s %14s %22s\n', 'Scheduler', 'Cell tp (Mbps)', 'Jain index', '5th pct tp (kbps)');
for scheduler_index = 1:numel(params.schedulers)
    out = run_simulation(params, params.schedulers{scheduler_index}, H, gbar, []);
    fprintf('%-8s %18.6f %14.6f %22.6f\n', params.schedulers{scheduler_index}, out.cell_tp / 1e6, out.fairness, out.tp_p5 / 1e3);
end
