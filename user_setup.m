function [d, gbar] = user_setup(K, d_min, d_max, ple, snr_ref_dB)
% USER_SETUP Purpose: draw user distances and their average linear SNR values.
% Inputs: K, user count; d_min and d_max in m; ple, path-loss exponent; snr_ref_dB at 100 m.
% Outputs: d and gbar, K x 1 column vectors of distances and average SNRs.
% Equation: gbar = 10.^((snr_ref_dB - 10*ple*log10(d/100))/10).

u = rand(K, 1);
d = d_min + (d_max - d_min) .* u;
gbar = 10 .^ ((snr_ref_dB - 10 * ple * log10(d / 100)) / 10);
end
