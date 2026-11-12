% RUN_EXPERIMENT_E2_TC Purpose: study the proportional-fair averaging-window trade-off.
% Inputs: uses default parameters, tc values, and shared channels/users per seed.
% Outputs: results/E2_tc.csv and plots/E2_tc_tradeoff_K10_seeds10.png.
% Equation: PF selection maximizes r_k(t)/R_k(t), with R updated using each tc value.

params = default_params();
project_root = fileparts(mfilename('fullpath'));
results_dir = fullfile(project_root, 'results');
plots_dir = fullfile(project_root, 'plots');
tc_values = [1 10 100 1000];
num_tc = numel(tc_values);
num_schedulers = numel(params.schedulers);
row_count = num_tc * params.num_seeds * num_schedulers;
tc_column = zeros(row_count, 1);
scheduler_column = cell(row_count, 1);
seed_column = zeros(row_count, 1);
cell_tp_column = zeros(row_count, 1);
fairness_column = zeros(row_count, 1);
tp_p5_column = zeros(row_count, 1);
pf_cell = zeros(params.num_seeds, num_tc);
pf_fairness = zeros(params.num_seeds, num_tc);
reference_cell = zeros(params.num_seeds, 2);
reference_fairness = zeros(params.num_seeds, 2);
row = 0;

for seed = 1:params.num_seeds
    rng(seed);
    [~, gbar] = user_setup(params.K, params.d_min, params.d_max, params.ple, params.snr_ref_dB);
    H = generate_channels(params, seed);
    rr_out = run_simulation(params, 'RR', H, gbar, []);
    maxci_out = run_simulation(params, 'MaxCI', H, gbar, []);
    reference_cell(seed, :) = [rr_out.cell_tp, maxci_out.cell_tp];
    reference_fairness(seed, :) = [rr_out.fairness, maxci_out.fairness];
    for tc_index = 1:num_tc
        pf_out = run_simulation(params, 'PF', H, gbar, tc_values(tc_index));
        outputs = {rr_out, maxci_out, pf_out};
        for scheduler_index = 1:num_schedulers
            current_out = outputs{scheduler_index};
            row = row + 1;
            tc_column(row) = tc_values(tc_index);
            scheduler_column{row} = params.schedulers{scheduler_index};
            seed_column(row) = seed;
            cell_tp_column(row) = current_out.cell_tp;
            fairness_column(row) = current_out.fairness;
            tp_p5_column(row) = current_out.tp_p5;
        end
        pf_cell(seed, tc_index) = pf_out.cell_tp;
        pf_fairness(seed, tc_index) = pf_out.fairness;
    end
end

results_table = table(tc_column, scheduler_column, seed_column, cell_tp_column, fairness_column, tp_p5_column, ...
    'VariableNames', {'tc', 'scheduler', 'seed', 'cell_tp_bps', 'fairness', 'tp_p5_bps'});
writetable(results_table, fullfile(results_dir, 'E2_tc.csv'));

figure('Visible', 'off');
subplot(2, 1, 1);
semilogx(tc_values, mean(pf_cell, 1) / 1e6, '-o', 'DisplayName', 'PF'); hold on;
rr_mean = mean(reference_cell(:, 1)) / 1e6;
maxci_mean = mean(reference_cell(:, 2)) / 1e6;
plot([min(tc_values) max(tc_values)], [rr_mean rr_mean], '--', 'DisplayName', 'RR mean');
plot([min(tc_values) max(tc_values)], [maxci_mean maxci_mean], '--', 'DisplayName', 'MaxCI mean');
grid on; xlabel('PF averaging window t_c (TTIs)'); ylabel('Cell throughput (Mbps)'); legend('Location', 'best');
subplot(2, 1, 2);
semilogx(tc_values, mean(pf_fairness, 1), '-o', 'DisplayName', 'PF'); hold on;
rr_mean = mean(reference_fairness(:, 1));
maxci_mean = mean(reference_fairness(:, 2));
plot([min(tc_values) max(tc_values)], [rr_mean rr_mean], '--', 'DisplayName', 'RR mean');
plot([min(tc_values) max(tc_values)], [maxci_mean maxci_mean], '--', 'DisplayName', 'MaxCI mean');
grid on; xlabel('PF averaging window t_c (TTIs)'); ylabel('Jain index'); legend('Location', 'best');
print(fullfile(plots_dir, sprintf('E2_tc_tradeoff_K%d_seeds%d.png', params.K, params.num_seeds)), '-dpng', '-r150');
close;
