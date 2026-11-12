% RUN_EXPERIMENT_E4_DISTANCE Purpose: compare schedulers while varying the cell-edge distance.
% Inputs: uses default parameters with d_max set to each requested value.
% Outputs: results/E4_distance.csv and plots/E4_distance_K10_seeds10.png.
% Equation: gbar = 10.^((snr_ref_dB - 10*ple*log10(d/100))/10).

params = default_params();
project_root = fileparts(mfilename('fullpath'));
results_dir = fullfile(project_root, 'results');
plots_dir = fullfile(project_root, 'plots');
d_max_values = [300 600 900 1500];
num_distances = numel(d_max_values);
num_schedulers = numel(params.schedulers);
row_count = num_distances * params.num_seeds * num_schedulers;
d_max_column = zeros(row_count, 1);
scheduler_column = cell(row_count, 1);
seed_column = zeros(row_count, 1);
cell_tp_column = zeros(row_count, 1);
fairness_column = zeros(row_count, 1);
tp_p5_column = zeros(row_count, 1);
mean_cell_tp = zeros(num_schedulers, num_distances);
mean_fairness = zeros(num_schedulers, num_distances);
mean_tp_p5 = zeros(num_schedulers, num_distances);
row = 0;
for distance_index = 1:num_distances
    params_distance = params;
    params_distance.d_max = d_max_values(distance_index);
    cell_values = zeros(params.num_seeds, num_schedulers);
    fairness_values = zeros(params.num_seeds, num_schedulers);
    p5_values = zeros(params.num_seeds, num_schedulers);
    for seed = 1:params.num_seeds
        rng(seed);
        [~, gbar] = user_setup(params_distance.K, params_distance.d_min, params_distance.d_max, params_distance.ple, params_distance.snr_ref_dB);
        H = generate_channels(params_distance, seed);
        for scheduler_index = 1:num_schedulers
            out = run_simulation(params_distance, params.schedulers{scheduler_index}, H, gbar, []);
            row = row + 1;
            d_max_column(row) = params_distance.d_max;
            scheduler_column{row} = params.schedulers{scheduler_index};
            seed_column(row) = seed;
            cell_tp_column(row) = out.cell_tp;
            fairness_column(row) = out.fairness;
            tp_p5_column(row) = out.tp_p5;
            cell_values(seed, scheduler_index) = out.cell_tp;
            fairness_values(seed, scheduler_index) = out.fairness;
            p5_values(seed, scheduler_index) = out.tp_p5;
        end
    end
    mean_cell_tp(:, distance_index) = mean(cell_values, 1)';
    mean_fairness(:, distance_index) = mean(fairness_values, 1)';
    mean_tp_p5(:, distance_index) = mean(p5_values, 1)';
end
results_table = table(d_max_column, scheduler_column, seed_column, cell_tp_column, fairness_column, tp_p5_column, ...
    'VariableNames', {'d_max_m', 'scheduler', 'seed', 'cell_tp_bps', 'fairness', 'tp_p5_bps'});
writetable(results_table, fullfile(results_dir, 'E4_distance.csv'));

figure('Visible', 'off');
subplot(2, 2, [1 3]); hold on;
for scheduler_index = 1:num_schedulers
    plot(d_max_values, mean_tp_p5(scheduler_index, :) / 1e3, '-o', 'DisplayName', params.schedulers{scheduler_index});
end
grid on; xlabel('Maximum user distance (m)'); ylabel('5th-percentile throughput (kbps)'); legend('Location', 'best');
subplot(2, 2, 2); hold on;
for scheduler_index = 1:num_schedulers
    plot(d_max_values, mean_cell_tp(scheduler_index, :) / 1e6, '-o', 'DisplayName', params.schedulers{scheduler_index});
end
grid on; xlabel('Maximum user distance (m)'); ylabel('Cell throughput (Mbps)');
subplot(2, 2, 4); hold on;
for scheduler_index = 1:num_schedulers
    plot(d_max_values, mean_fairness(scheduler_index, :), '-o', 'DisplayName', params.schedulers{scheduler_index});
end
grid on; xlabel('Maximum user distance (m)'); ylabel('Jain index');
print(fullfile(plots_dir, sprintf('E4_distance_K%d_seeds%d.png', params.K, params.num_seeds)), '-dpng', '-r150');
close;
