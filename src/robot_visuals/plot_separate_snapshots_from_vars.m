function plot_separate_snapshots_from_vars(vars, nsnapshots)
%PLOT_SEPARATE_SNAPSHOTS_FROM_VARS plots snapshots in subfigures.
%
%   PLOT_SEPARATE_SNAPSHOTS_FROM_VARS(vars, nsnapshots) plots nsnapshots
%   separate snapshots in subfigures. Variable nsnapshots should be between
%   1 and 12.

    if nargin < 2
        nsnapshots = 12;
    end
    if nsnapshots < 1 || nsnapshots > 12
        error("numpts should be between 1 and 12.")
    end
    
    % Maximum 2 rows, starting from 3 snapshots
    nrows = min(2, 1 + mod(nsnapshots-1, 2));
    ncols = ceil(nsnapshots / nrows);

    [n, N] = size(vars.variables.q);

    % Plot robot configurations
    timegrid = floor(linspace(1, N, nsnapshots));
    for row = 1 : nrows
        for col = 1 : ncols
            snapnum = (row - 1) * ncols + col;
            ii = timegrid(snapnum);
            subplot(nrows, ncols, snapnum)
            [P, ~, ~, ~] = snapshot_from_vars(vars, ii, 10, 1);
            dP = P(end, :) - P(end-1, :);
            alpha = .2;
            text(P(end, 1) + alpha * dP(1), P(end, 2) + alpha * dP(2), sprintf("%d", ii-1), 'FontSize', 15, 'Interpreter', 'latex', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

            % cosmetics
            axis('equal');
            expandAxes(1.2);
            grid;
            if nrows == 1 || (nrows == 2 && snapnum > ncols)
                xlabel('Sagittal axis: $x$ [m]', 'Interpreter', 'latex', 'FontSize', 10);
            end
            if snapnum == 1 || (nrows == 2 && snapnum == ncols + 1)
                ylabel('Vertical axis: $z$ [m]', 'Interpreter', 'latex', 'FontSize', 10);
            end
            ax = gca; ax.FontSize = 10; ax.TickLabelInterpreter = 'latex';
        end
    end
    
end