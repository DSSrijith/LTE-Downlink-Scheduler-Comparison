function J = jain_index(x)
% JAIN_INDEX Purpose: calculate Jain's fairness index for a nonnegative allocation.
% Inputs: x, vector of user throughputs or another allocation.
% Outputs: J, fairness index; returns zero when all entries are zero.
% Equation: J = (sum(x))^2/(numel(x)*sum(x.^2)).

sum_squares = sum(x .^ 2);
if sum_squares == 0
    J = 0;
    return;
end
J = sum(x) ^ 2 / (numel(x) * sum_squares);
lower_bound = 1 / numel(x) - 1e-9;
if J < lower_bound || J > 1 + 1e-9
    warning('jain_index:OutOfRange', 'Jain index %.16g is outside its expected range.', J);
end
end
