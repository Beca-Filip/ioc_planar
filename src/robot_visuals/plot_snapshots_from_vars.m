function plot_snapshots_from_vars(num_vars, numpts)
    if nargin < 2
        numpts = 5;
    end
    
    [n, N] = size(num_vars.variables.q);
    % Plot cartesian EE traj
    plot(num_vars.functions.P{end}(1, :), num_vars.functions.P{end}(2, :), 'Color', [1, 1, 0], 'LineWidth', 2);

    % Plot cartesian segment COM trajectories
    for ii = 1 : n
        plot(num_vars.functions.Pcom{ii}(1, :), num_vars.functions.Pcom{ii}(2, :), 'Color', [0, 1, 1], 'LineWidth', 2);
    end

    % Plot robot configurations
    for ii = floor(linspace(1, N, numpts))
        [P, ~, ~, ~] = snapshot_from_vars(num_vars, ii);
        dP = P(end, :) - P(end-1, :);
        alpha = .2;
        text(P(end, 1) + alpha * dP(1), P(end, 2) + alpha * dP(2), sprintf("%d", ii-1), 'FontSize', 25, 'Interpreter', 'latex', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        snapshot_from_vars(num_vars, ii);
    end
end