function params = default_params()
% DEFAULT_PARAMS Purpose: return default LTE downlink simulation parameters.
% Inputs: none.
% Outputs: params, a struct containing simulation and channel parameters.
% Equation: rates use r = W*log2(1 + SNR) in compute_rate.

params.W = 10e6;
params.Ts = 1e-3;
params.T = 20000;
params.K = 10;
params.tc = 100;
params.fd = 10;
params.d_min = 100;
params.d_max = 1000;
params.ple = 3.5;
params.snr_ref_dB = 30;
params.num_seeds = 10;
params.R_init = 1;
params.schedulers = {'RR', 'MaxCI', 'PF'};
end
