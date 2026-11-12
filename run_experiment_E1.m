% RUN_EXPERIMENT_E1 Purpose: compare schedulers while varying the number of users.
% Inputs: uses default_params and shared channels/users for every scheduler and seed.
% Outputs: results/E1_users.csv and cell-throughput and fairness figures in plots/.
% Equation: 95 percent CI = 1.96*std(x)/sqrt(n), evaluated across independent seeds.

params = default_params();
project_root = fileparts(mfilename('fullpath'));
results_dir = fullfile(project_root, 'results');
plots_dir = fullfile(project_root, 'plots');
K_values = [2 4 6 8 10 12 14 16 18 20];
num_K = numel(K_values);
num_schedulers = numel(params.schedulers);
rows_per_K = num_schedulers * params.num_seeds;
row_count = num_K * rows_per_K;
K_column = zeros(row_count, 1);
scheduler_column = cell(row_count, 1);
seed_column = zeros(row_count, 1);
cell_tp_column = zeros(row_count, 1);
fairness_column = zeros(row_count, 1);
tp_p5_column = zeros(row_count, 1);

mean_cell_tp = zeros(num_schedulers, num_K);
ci_cell_tp = zeros(num_schedulers, num_K);
mean_fairness = zeros(num_schedulers, num_K);
ci_fairness = zeros(num_schedulers, num_K);
row = 0;
for k_index = 1:num_K
    params_K = params;
    params_K.K = K_values(k_index);
    cell_values = zeros(params.num_seeds, num_schedulers);
    fairness_values = zeros(params.num_seeds, num_schedulers);
    for seed = 1:params.num_seeds
        rng(seed);
        [~, gbar] = user_setup(params_K.K, params_K.d_min, params_K.d_max, params_K.ple, params_K.snr_ref_dB);
        H = generate_channels(params_K, seed);
        for scheduler_index = 1:num_schedulers
            out = run_simulation(params_K, params.schedulers{scheduler_index}, H, gbar, []);
            row = row + 1;
            K_column(row) = params_K.K;
            scheduler_column{row} = params.schedulers{scheduler_index};
            seed_column(row) = seed;
            cell_tp_column(row) = out.cell_tp;
            fairness_column(row) = out.fairness;
            tp_p5_column(row) = out.tp_p5;
            cell_values(seed, scheduler_index) = out.cell_tp;
            fairness_values(seed, scheduler_index) = out.fairness;
        end
    end
    mean_cell_tp(:, k_index) = mean(cell_values, 1)';
    ci_cell_tp(:, k_index) = 1.96 * std(cell_values, 0, 1)' / sqrt(params.num_seeds);
    mean_fairness(:, k_index) = mean(fairness_values, 1)';
    ci_fairness(:, k_index) = 1.96 * std(fairness_values, 0, 1)' / sqrt(params.num_seeds);
end

results_table = table(K_column, scheduler_column, seed_column, cell_tp_column, fairness_column, tp_p5_column, ...
    'VariableNames', {'K', 'scheduler', 'seed', 'cell_tp_bps', 'fairness', 'tp_p5_bps'});
writetable(results_table, fullfile(results_dir, 'E1_users.csv'));

figure('Visible', 'off');
hold on;
for scheduler_index = 1:num_schedulers
    errorbar(K_values, mean_cell_tp(scheduler_index, :) / 1e6, ci_cell_tp(scheduler_index, :) / 1e6, '-o', ...
        'DisplayName', params.schedulers{scheduler_index});
end
grid on; xlabel('Number of users K'); ylabel('Cell throughput (Mbps)'); legend('Location', 'best');
print(fullfile(plots_dir, sprintf('E1_cell_tp_vs_K_T%d_seeds%d.png', params.T, params.num_seeds)), '-dpng', '-r150');
close;

figure('Visible', 'off');
hold on;
for scheduler_index = 1:num_schedulers
    errorbar(K_values, mean_fairness(scheduler_index, :), ci_fairness(scheduler_index, :), '-o', ...
        'DisplayName', params.schedulers{scheduler_index});
end
grid on; xlabel('Number of users K'); ylabel('Jain index'); legend('Location', 'best');
print(fullfile(plots_dir, sprintf('E1_jain_vs_K_T%d_seeds%d.png', params.T, params.num_seeds)), '-dpng', '-r150');
close;
