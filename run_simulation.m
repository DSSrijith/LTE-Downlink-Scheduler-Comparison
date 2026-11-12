function out = run_simulation(params, sched, H, gbar, tc_override)
% RUN_SIMULATION Purpose: simulate one stateful scheduler over a shared channel realization.
% Inputs: params, parameter struct; sched, scheduler name; H, K x T channels; gbar, K x 1 SNRs;
% tc_override, optional PF averaging window in TTIs.
% Outputs: out with per-user throughput, cell throughput, Jain index, and 5th-percentile throughput.
% Equation: tp_user = total_served/T, with one user served per TTI.

if nargin < 5 || isempty(tc_override)
    tc = params.tc;
else
    tc = tc_override;
end
K = params.K;
T = params.T;
R = params.R_init * ones(K, 1);
total_served = zeros(K, 1);

for t = 1:T
    r = compute_rate(gbar, H(:, t), params.W);
    k = select_user(sched, r, R, t, K);
    served = zeros(K, 1);
    served(k) = r(k);
    R = update_average(R, served, tc);
    total_served = total_served + served;
end

% total_served holds per-TTI rates in bps, so the time average is the mean over T TTIs; equivalently sum(served*Ts)/(T*Ts).
tp_user = total_served / T;
sorted_tp = sort(tp_user);
p5_index = max(1, ceil(0.05 * K));
out.user_tp = tp_user;
out.cell_tp = sum(tp_user);
out.fairness = jain_index(tp_user);
out.tp_p5 = sorted_tp(p5_index);
end
