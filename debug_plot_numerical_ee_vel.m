function debug_plot_numerical_ee_vel(num_vars)

[n, N] = size(num_vars.variables.q);
ee_vel = num_vars.functions.V{end}(:, 1:end-1);
ee_pos = num_vars.functions.P{end};
ee_num_vel = diff(ee_pos, 1, 2) ./ num_vars.parameters.dt;

t = linspace(0, (N-2) * num_vars.parameters.dt, N-1);

subplot(3, 1, 1)
hold on;
plot(t, ee_num_vel(1, :), 'LineWidth', 2, 'DisplayName', 'Numerical');
plot(t, ee_vel(1, :), 'LineStyle', '--', 'LineWidth', 2, 'DisplayName', 'Symbolic');
xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex');
ylabel(sprintf("$V^{ee}_x$"), 'Interpreter', 'latex');

subplot(3, 1, 2)
hold on;
plot(t, ee_num_vel(2, :), 'LineWidth', 2, 'DisplayName', 'Numerical');
plot(t, ee_vel(2, :), 'LineStyle', '--', 'LineWidth', 2, 'DisplayName', 'Symbolic');
xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex');
ylabel(sprintf("$V^{ee}_y$"), 'Interpreter', 'latex');


subplot(3, 1, 3)
hold on;
plot(t, ee_num_vel(3, :), 'LineWidth', 2, 'DisplayName', 'Numerical');
plot(t, ee_vel(3, :), 'LineStyle', '--', 'LineWidth', 2, 'DisplayName', 'Symbolic');
xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex');
ylabel(sprintf("$V^{ee}_{\\theta}$"), 'Interpreter', 'latex');

legend('Location', 'best', 'Interpreter', 'latex');
end