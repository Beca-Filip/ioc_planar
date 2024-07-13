function debug_plot_numerical_joint_vel(num_vars)

    [n, N] = size(num_vars.variables.q);
    q = num_vars.variables.q;
    dq = num_vars.variables.dq;

    num_dq = (num_vars.variables.q(:, 2:end) - num_vars.variables.q(:, 1:end-1)) ./ num_vars.parameters.dt;
    % num_dq = diff(q, 1, 2) ./ num_vars.parameters.dt;

    num_q = [q(:, 1), q(:, 1) + cumsum(dq, 2) .* num_vars.parameters.dt];
    t_q = linspace(0, (N-1) * num_vars.parameters.dt, N);
    t_dq = linspace(0, (N-2) * num_vars.parameters.dt, N-1);
    
    for ii = 1 : n
        subplot(n, 2, 2 * (ii-1) + 1)
        hold on;
        plot(t_dq, num_dq(ii, :), 'LineWidth', 2, 'DisplayName', 'Numerical');
        plot(t_dq, dq(ii, :), 'LineStyle', '--', 'LineWidth', 2, 'DisplayName', 'Symbolic');
        xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex');
        ylabel(sprintf("$\\dot{q}_{%d}$", ii), 'Interpreter', 'latex');        
        legend('Location', 'best', 'Interpreter', 'latex');

        subplot(n, 2, 2 * (ii-1) + 2)
        hold on;
        plot(t_q, num_q(ii, :), 'LineWidth', 2, 'DisplayName', 'Numerical');
        plot(t_q, q(ii, :), 'LineStyle', '--', 'LineWidth', 2, 'DisplayName', 'Symbolic');
        xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex');
        ylabel(sprintf("$q_{%d}$", ii), 'Interpreter', 'latex');        
        legend('Location', 'best', 'Interpreter', 'latex');
    end
end