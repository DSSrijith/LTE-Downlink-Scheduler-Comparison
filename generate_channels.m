function H = generate_channels(params, seed)
% GENERATE_CHANNELS Purpose: generate reproducible K x T fading channels for one experiment seed.
% Inputs: params, parameter struct; seed, scalar random-number seed.
% Outputs: H, K x T complex channel matrix, one user per row.
% Equation: each row follows the AR(1) fading equation implemented by gen_fading.

rng(seed);
H = zeros(params.K, params.T);
for k = 1:params.K
    H(k, :) = gen_fading(params.T, params.fd, params.Ts);
end
end
