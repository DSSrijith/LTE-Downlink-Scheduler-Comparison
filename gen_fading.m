function h = gen_fading(T, fd, Ts)
% GEN_FADING Purpose: generate correlated Rayleigh fading using an AR(1) model.
% Inputs: T, number of samples; fd, maximum Doppler frequency in Hz; Ts, sample time in s.
% Outputs: h, a 1 x T complex row vector with unit average power.
% Equations: rho = besselj(0,2*pi*fd*Ts), h(t) = rho*h(t-1) + sqrt(1-rho^2)*w(t),
% where w(t) = (randn + 1i*randn)/sqrt(2). This is an AR(1) approximation of Jakes' model.

rho = besselj(0, 2 * pi * fd * Ts);
h = zeros(1, T);
h(1) = (randn + 1i * randn) / sqrt(2);
innovation_scale = sqrt(max(0, 1 - rho^2));
for t = 2:T
    w_t = (randn + 1i * randn) / sqrt(2);
    h(t) = rho * h(t - 1) + innovation_scale * w_t;
end
end
