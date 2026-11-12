function r = compute_rate(gbar, h_t, W)
% COMPUTE_RATE Purpose: calculate each user's instantaneous idealized Shannon rate.
% Inputs: gbar, K x 1 average SNR; h_t, K x 1 complex fading samples; W, bandwidth in Hz.
% Outputs: r, K x 1 instantaneous rates in bps.
% Equation: snr = gbar .* abs(h_t).^2 and r = W*log2(1 + snr). This is an idealized
% Shannon rate model, not a CQI-to-MCS table.

snr = gbar .* abs(h_t) .^ 2;
r = W * log2(1 + snr);
end
