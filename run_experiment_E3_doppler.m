% RUN_EXPERIMENT_E3_DOPPLER Purpose: compare scheduler throughput over Doppler frequencies.
% Inputs: uses default parameters with fd set to each requested value.
% Outputs: results/E3_doppler.csv and plots/E3_doppler_K10_seeds10.png.
% Equation: fading correlation is rho = besselj(0,2*pi*fd*Ts).

params = default_params();
project_root = fileparts(mfilename('fullpath'));
results_dir = fullfile(project_root, 'results');
plots_dir = fullfile(project_root, 'plots');
fd_values = [5 50 200];
num_fd = numel(fd_values);
num_schedulers = numel(params.schedulers);
row_count = num_fd * params.num_seeds * num_schedulers;
fd_column = zeros(row_count, 1);
scheduler_column = cell(row_count, 1);
seed_column = zeros(row_count, 1);
cell_tp_column = zeros(row_count, 1);
fairness_column = zeros(row_count, 1);
tp_p5_column = zeros(row_count, 1);
mean_cell_tp = zeros(num_schedulers, num_fd);
ci_cell_tp = zeros(num_schedulers, num_fd);
row = 0;
for fd_index = 1:num_fd
    params_fd = params;
    params_fd.fd = fd_values(fd_index);
    cell_values = zeros(params.num_seeds, num_schedulers);
    for seed = 1:params.num_seeds
        rng(seed);
        [~, gbar] = user_setup(params_fd.K, params_fd.d_min, params_fd.d_max, params_fd.ple, params_fd.snr_ref_dB);
        H = generate_channels(params_fd, seed);
        for scheduler_index = 1:num_schedulers
            out = run_simulation(params_fd, params.schedulers{scheduler_index}, H, gbar, []);
            row = row + 1;
            fd_column(row) = params_fd.fd;
            scheduler_column{row} = params.schedulers{scheduler_index};
            seed_column(row) = seed;
            cell_tp_column(row) = out.cell_tp;
            fairness_column(row) = out.fairness;
            tp_p5_column(row) = out.tp_p5;
            cell_values(seed, scheduler_index) = out.cell_tp;
        end
    end
    mean_cell_tp(:, fd_index) = mean(cell_values, 1)';
    ci_cell_tp(:, fd_index) = 1.96 * std(cell_values, 0, 1)' / sqrt(params.num_seeds);
end
results_table = table(fd_column, scheduler_column, seed_column, cell_tp_column, fairness_column, tp_p5_column, ...
    'VariableNames', {'fd_Hz', 'scheduler', 'seed', 'cell_tp_bps', 'fairness', 'tp_p5_bps'});
writetable(results_table, fullfile(results_dir, 'E3_doppler.csv'));

figure('Visible', 'off'); hold on;
for scheduler_index = 1:num_schedulers
    errorbar(fd_values, mean_cell_tp(scheduler_index, :) / 1e6, ci_cell_tp(scheduler_index, :) / 1e6, '-o', ...
        'DisplayName', params.schedulers{scheduler_index});
end
grid on; xlabel('Maximum Doppler frequency (Hz)'); ylabel('Cell throughput (Mbps)'); legend('Location', 'best');
print(fullfile(plots_dir, sprintf('E3_doppler_K%d_seeds%d.png', params.K, params.num_seeds)), '-dpng', '-r150');
close;
