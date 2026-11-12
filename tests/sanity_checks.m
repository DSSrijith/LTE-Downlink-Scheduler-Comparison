% SANITY_CHECKS Purpose: validate fading, fairness, and scheduler accounting before experiments.
% Inputs: uses project functions and default parameters.
% Outputs: PASS or FAIL lines, diagnostic warnings, and an error if a required check fails.
% Equation: scheduler accounting requires sum(user_tp) = cell_tp.

test_folder = fileparts(mfilename('fullpath'));
project_root = fileparts(test_folder);
addpath(project_root);
overall_pass = true;

h = gen_fading(200000, 200, 1e-3);
mean_power = mean(abs(h) .^ 2);
if abs(mean_power - 1) <= 0.02
    fprintf('PASS a: mean fading power = %.6f\n', mean_power);
else
    fprintf('FAIL a: mean fading power = %.6f\n', mean_power);
    overall_pass = false;
end

h_low_fd = gen_fading(200000, 5, 1e-3);
h_high_fd = gen_fading(200000, 200, 1e-3);
lag_low_fd = abs(sum(h_low_fd(2:end) .* conj(h_low_fd(1:end-1))) / sqrt(sum(abs(h_low_fd(2:end)) .^ 2) * sum(abs(h_low_fd(1:end-1)) .^ 2)));
lag_high_fd = abs(sum(h_high_fd(2:end) .* conj(h_high_fd(1:end-1))) / sqrt(sum(abs(h_high_fd(2:end)) .^ 2) * sum(abs(h_high_fd(1:end-1)) .^ 2)));
fprintf('INFO b: lag-1 correlation fd=5 Hz = %.6f, fd=200 Hz = %.6f\n', lag_low_fd, lag_high_fd);
if lag_high_fd >= lag_low_fd
    fprintf('WARNING b: higher Doppler did not produce lower lag-1 correlation.\n');
else
    fprintf('PASS b: higher Doppler produced lower lag-1 correlation.\n');
end

equal_jain = jain_index(ones(5, 1));
single_jain = jain_index([1; 0; 0; 0; 0]);
if abs(equal_jain - 1) <= 1e-12 && abs(single_jain - 1 / 5) <= 1e-12
    fprintf('PASS c: Jain equal = %.6f, one-active = %.6f\n', equal_jain, single_jain);
else
    fprintf('FAIL c: Jain equal = %.6f, one-active = %.6f\n', equal_jain, single_jain);
    overall_pass = false;
end

params = default_params();
rng(1);
[~, gbar] = user_setup(params.K, params.d_min, params.d_max, params.ple, params.snr_ref_dB);
H = generate_channels(params, 1);
rr_out = run_simulation(params, 'RR', H, gbar, []);
maxci_out = run_simulation(params, 'MaxCI', H, gbar, []);
pf_out = run_simulation(params, 'PF', H, gbar, []);
fprintf('INFO d: cell_tp RR = %.6f bps, MaxCI = %.6f bps, PF = %.6f bps\n', rr_out.cell_tp, maxci_out.cell_tp, pf_out.cell_tp);
if maxci_out.cell_tp >= pf_out.cell_tp && pf_out.cell_tp >= rr_out.cell_tp
    fprintf('PASS d: MaxCI >= PF >= RR.\n');
else
    fprintf('WARNING d: MaxCI >= PF >= RR did not hold.\n');
end

all_nonnegative = all(rr_out.user_tp >= 0) && all(maxci_out.user_tp >= 0) && all(pf_out.user_tp >= 0);
rr_error = abs(sum(rr_out.user_tp) - rr_out.cell_tp);
maxci_error = abs(sum(maxci_out.user_tp) - maxci_out.cell_tp);
pf_error = abs(sum(pf_out.user_tp) - pf_out.cell_tp);
accounting_ok = rr_error <= 1e-6 * rr_out.cell_tp && maxci_error <= 1e-6 * maxci_out.cell_tp && pf_error <= 1e-6 * pf_out.cell_tp;
if all_nonnegative && accounting_ok
    fprintf('PASS e: nonnegative user throughput; max accounting error = %.6g bps\n', max([rr_error maxci_error pf_error]));
else
    fprintf('FAIL e: nonnegative = %d; accounting errors = [%.6g %.6g %.6g] bps\n', all_nonnegative, rr_error, maxci_error, pf_error);
    overall_pass = false;
end

params_f = default_params();
rng(1);
[~, gbar_f] = user_setup(params_f.K, params_f.d_min, params_f.d_max, params_f.ple, params_f.snr_ref_dB);
H_f = generate_channels(params_f, 1);
rr_out_f = run_simulation(params_f, 'RR', H_f, gbar_f, []);
maxci_out_f = run_simulation(params_f, 'MaxCI', H_f, gbar_f, []);
pf_out_f = run_simulation(params_f, 'PF', H_f, gbar_f, []);
fprintf('INFO f: RR cell_tp = %.6f Mbps\n', rr_out_f.cell_tp / 1e6);
fprintf('INFO f: MaxCI cell_tp = %.6f Mbps\n', maxci_out_f.cell_tp / 1e6);
fprintf('INFO f: PF cell_tp = %.6f Mbps\n', pf_out_f.cell_tp / 1e6);
cell_tp_f = [rr_out_f.cell_tp, maxci_out_f.cell_tp, pf_out_f.cell_tp];
if all(cell_tp_f >= 1e6 & cell_tp_f <= 1e9)
    fprintf('PASS f: all scheduler cell throughputs are between 1e6 and 1e9 bps.\n');
else
    fprintf('FAIL f: one or more scheduler cell throughputs are outside [1e6, 1e9] bps.\n');
    overall_pass = false;
end

if ~overall_pass
    error('sanity_checks:Failed', 'One or more required sanity checks failed.');
end
