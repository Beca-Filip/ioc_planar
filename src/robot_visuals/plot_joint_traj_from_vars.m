function plot_joint_traj_from_vars(num_vars, varargin)

[n, N] = size(num_vars.variables.q);
t = linspace(0, (N-1) * num_vars.parameters.dt, N);

for ii = 1 : n
    subplot(n, 4, (ii-1) * 4 + 1)
    hold on;
    plot(t, num_vars.variables.q(ii, :), varargin{:});
    ylabel(sprintf("$q_{%d}$", ii), 'Interpreter', 'latex');
    
    if ii == n
        xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
    end

    subplot(n, 4, (ii-1) * 4 + 2)
    hold on;
    plot(t(1:end-1), num_vars.variables.dq(ii, :), varargin{:});
    ylabel(sprintf("$\\dot{q}_{%d}$", ii), 'Interpreter', 'latex');

    if ii == n
        xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
    end
    
    subplot(n, 4, (ii-1) * 4 + 3)
    hold on;
    plot(t(1:end-2), num_vars.variables.ddq(ii, :), varargin{:});
    ylabel(sprintf("$\\ddot{q}_{%d}$", ii), 'Interpreter', 'latex');

    if ii == n
        xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
    end
    
    subplot(n, 4, (ii-1) * 4 + 4)
    hold on;
    plot(t(1:end-2), num_vars.functions.model_tau(ii, 1:end-2), varargin{:});
    ylabel(sprintf("$\\tau_{%d}$", ii), 'Interpreter', 'latex');

    if ii == n
        xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
    end
end


end