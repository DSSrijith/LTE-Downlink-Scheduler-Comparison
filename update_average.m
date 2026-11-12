function R = update_average(R, served, tc)
% UPDATE_AVERAGE Purpose: update exponential average throughput for every user.
% Inputs: R, prior K x 1 averages; served, K x 1 served rates; tc, averaging window in TTIs.
% Outputs: R, updated K x 1 average throughputs.
% Equation: R = (1 - 1/tc).*R + (1/tc).*served. This update runs for every scheduler,
% so the average is tracked even when only PF uses it.

R = (1 - 1 / tc) .* R + (1 / tc) .* served;
end
