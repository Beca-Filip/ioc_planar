function plot_joint_traj_from_vars(num_vars, varargin)

[n, Nq] = size(num_vars.variables.q);
[~, Ndq] = size(num_vars.variables.dq);
[~, Nddq] = size(num_vars.variables.ddq);
[~, Ntau] = size(num_vars.functions.model_tau);
tq = linspace(0, (Nq-1) * num_vars.parameters.dt, Nq);
tdq = linspace(0, (Ndq-1) * num_vars.parameters.dt, Ndq);
tddq = linspace(0, (Nddq-1) * num_vars.parameters.dt, Nddq);
ttau = linspace(0, (Nddq-1) * num_vars.parameters.dt, Ntau);

for ii = 1 : n
    subplot(n, 4, (ii-1) * 4 + 1)
    hold on;
    plot(tq, num_vars.variables.q(ii, :), varargin{:});
    if isfield(num_vars.parameters, 'qmin') && isfield(num_vars.parameters, 'qmax')
        plot(tq([1, end]), num_vars.parameters.qmin(ii) * ones(1, 2), 'Color', [0, 0.7, 0.7], varargin{:});
    plot(tq([1, end]), num_vars.parameters.qmax(ii) * ones(1, 2), 'Color', [0.7, 0, 0.7], varargin{:});
    end
    ylabel(sprintf("$q_{%d}$", ii), 'Interpreter', 'latex');
    grid;
    
    if ii == n
        xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
    end

    subplot(n, 4, (ii-1) * 4 + 2)
    hold on;
    plot(tdq, num_vars.variables.dq(ii, :), varargin{:});
    if isfield(num_vars.parameters, 'dqmin') && isfield(num_vars.parameters, 'dqmax')
        plot(tdq([1, end]), num_vars.parameters.dqmin(ii) * ones(1, 2), 'Color', [0, 0.7, 0.7], varargin{:});
        plot(tdq([1, end]), num_vars.parameters.dqmax(ii) * ones(1, 2), 'Color', [0.7, 0, 0.7], varargin{:});
    end
    ylabel(sprintf("$\\dot{q}_{%d}$", ii), 'Interpreter', 'latex');
    grid;

    if ii == n
        xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
    end
    
    subplot(n, 4, (ii-1) * 4 + 3)
    hold on;
    plot(tddq, num_vars.variables.ddq(ii, :), varargin{:});
    ylabel(sprintf("$\\ddot{q}_{%d}$", ii), 'Interpreter', 'latex');
    grid;

    if ii == n
        xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
    end
    
    subplot(n, 4, (ii-1) * 4 + 4)
    hold on;
    plot(ttau, num_vars.functions.model_tau(ii, :), varargin{:});
    if isfield(num_vars.parameters, 'taumin') && isfield(num_vars.parameters, 'taumax')
        plot(ttau([1, end]), num_vars.parameters.taumin(ii) * ones(1, 2), 'Color', [0, 0.7, 0.7], varargin{:});
        plot(ttau([1, end]), num_vars.parameters.taumax(ii) * ones(1, 2), 'Color', [0.7, 0, 0.7], varargin{:});
    end
    ylabel(sprintf("$\\tau_{%d}$", ii), 'Interpreter', 'latex');
    grid;

    if ii == n
        xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')
    end
end


end