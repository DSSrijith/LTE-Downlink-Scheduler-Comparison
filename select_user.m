function k = select_user(sched, r, R, t, K)
% SELECT_USER Purpose: select one user according to an LTE scheduler rule.
% Inputs: sched, scheduler name; r, K x 1 rates; R, K x 1 average rates; t, TTI index; K, user count.
% Outputs: k, selected user index.
% Equations: RR k = mod(t-1,K)+1; MaxCI maximizes r; PF maximizes r./R.

switch sched
    case 'RR'
        k = mod(t - 1, K) + 1;
    case 'MaxCI'
        [~, k] = max(r);
    case 'PF'
        [~, k] = max(r ./ R);
    otherwise
        error('select_user:UnknownScheduler', 'Unknown scheduler "%s". Use RR, MaxCI, or PF.', sched);
end
end
