function plot_snapshots_from_vars(vars, nsnapshots)
%PLOT_SNAPSHOTS_FROM_VARS plots snapshots in a single figure.
%
%   PLOT_SNAPSHOTS_FROM_VARS(vars, nsnapshots) plots nsnapshots snapshots 
%   in the same figure. Default value for nsnapshots is 5.
    if nargin < 2
        nsnapshots = 5;
    end
    
    [n, N] = size(vars.variables.q);
    % Plot cartesian EE traj
    plot(vars.functions.P{end}(1, :), vars.functions.P{end}(2, :), 'Color', [1, 1, 0], 'LineWidth', 2);

    % Plot cartesian segment COM trajectories
    for ii = 1 : n
        plot(vars.functions.Pcom{ii}(1, :), vars.functions.Pcom{ii}(2, :), 'Color', [0, 1, 1], 'LineWidth', 2);
    end

    % Plot cartesian total COM trajectory
    if isfield(vars.functions, 'Pcomtotal')
        plot(vars.functions.Pcomtotal(1, :), vars.functions.Pcomtotal(2, :), 'Color', [0.2, 0.7, 0.05], 'LineWidth', 2);
    end

    % Plot robot configurations
    for ii = floor(linspace(1, N, nsnapshots))
        [P, ~, ~, ~] = snapshot_from_vars(vars, ii);
        dP = P(end, :) - P(end-1, :);
        alpha = .2;
        text(P(end, 1) + alpha * dP(1), P(end, 2) + alpha * dP(2), sprintf("%d", ii-1), 'FontSize', 25, 'Interpreter', 'latex', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        snapshot_from_vars(vars, ii);
    end
end