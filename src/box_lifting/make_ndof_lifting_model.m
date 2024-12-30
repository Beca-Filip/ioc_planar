function [opti, vars] = make_ndof_lifting_model(n, N)
    if N <= 2
        error('Need N>2.');
    end

    opti = casadi.Opti();
    
    % Parameters
    vars.parameters.dt = opti.parameter(1);
    vars.parameters.q0 = opti.parameter(n);
    vars.parameters.dq0 = opti.parameter(n);

    vars.parameters.L = opti.parameter(n);
    vars.parameters.COM = opti.parameter(2, n);
    vars.parameters.M = opti.parameter(n);
    vars.parameters.I = opti.parameter(n);
    vars.parameters.qmin = opti.parameter(n);
    vars.parameters.qmax = opti.parameter(n);
    vars.parameters.taumin = opti.parameter(n);
    vars.parameters.taumax = opti.parameter(n);

    vars.parameters.gravity = opti.parameter(2);
    vars.parameters.Fext = cell(n, 1);
    for ii = 1 : n
        vars.parameters.Fext{ii} = opti.parameter(3, N-2);
    end

    vars.parameters.goal = opti.parameter(2, 1);

    % Variables
    % vars.variables.tau = opti.variable(n, N-2);
    vars.variables.ddq = opti.variable(n, N-2);
    vars.variables.dq = opti.variable(n, N-1);
    vars.variables.q = opti.variable(n, N);
    
    % Functions
    vars.functions.q = vars.variables.q;
    vars.functions.dq = horzcat(vars.variables.dq, zeros(n, 1, class(vars.variables.dq)));
    vars.functions.ddq =  horzcat(vars.variables.ddq, zeros(n, 2, class(vars.variables.ddq)));
    vars.functions.Fext = cell(n, 1);
    for ii = 1 : n
        vars.functions.Fext{ii} = horzcat(vars.parameters.Fext{ii}, zeros(3, 2, class(vars.parameters.Fext{ii})));
    end
    
    
    [vars.functions.Pcom, vars.functions.P, vars.functions.Vcom, vars.functions.V, vars.functions.Acom, vars.functions.A, vars.functions.Fcom] ...
        = forward_propagation( ...
            vars.functions.q, ...
            vars.functions.dq, ...
            vars.functions.ddq, ...
            vars.parameters.L, ...
            vars.parameters.COM,...
            vars.parameters.M,...
            vars.parameters.I...
        );
    
    [vars.functions.F] ...
        = backward_propagation( ...
            vars.functions.Fcom, ...
            vars.functions.Fext, ...
            vars.functions.Pcom, ...
            vars.functions.P, ...
            vars.parameters.M, ...
            vars.parameters.gravity ...
        );

    % Get tau from model
    vars.functions.model_tau = zeros(n, N, class(vars.variables.ddq));
    for ii = 1 : n
        vars.functions.model_tau(ii, :) = vars.functions.F{ii}(3, :);
    end

    % Constraints
    vars.constraints.initial_pos = vars.variables.q(:, 1) - vars.parameters.q0;
    vars.constraints.initial_vel = vars.variables.dq(:, 1) - vars.parameters.dq0;

    vars.constraints.dynamics_pos = vars.variables.q(:, 2:end) - vars.variables.q(:, 1:end-1) - vars.variables.dq .* vars.parameters.dt;
    vars.constraints.dynamics_vel = vars.variables.dq(:, 2:end) - vars.variables.dq(:, 1:end-1) - vars.variables.ddq .* vars.parameters.dt;

    vars.constraints.angle_lower_limits = -vars.variables.q + vars.parameters.qmin;
    vars.constraints.angle_upper_limits = vars.variables.q - vars.parameters.qmax;
    
    vars.constraints.torque_lower_limits = -vars.functions.model_tau + vars.parameters.taumin;
    vars.constraints.torque_upper_limits = vars.functions.model_tau - vars.parameters.taumax;

    vars.constraints.goal_ee = vars.functions.P{end}(1:2, end) - vars.parameters.goal;
    
    % Costs
    vars.costs.joint_torque_cost = sum(sum(vars.functions.model_tau.^2)) / N / n;
    vars.costs.joint_vel_cost = sum(sum(vars.variables.dq.^2)) / N / n;
    vars.costs.ee_vel_cost = sum(sum(vars.functions.V{end}.^2)) / N;
    vars.costs.joint_torque_change_cost = sum(sum( (vars.functions.model_tau(:, 2:end) - vars.functions.model_tau(:, 1:end-1)).^2 )) ./ vars.parameters.dt^2 / N / n;
    vars.costs.joint_jerk_cost = sum(sum( (vars.variables.ddq(:, 2:end) - vars.variables.ddq(:, 1:end-1)).^2 )) ./ vars.parameters.dt^2 / N / n;
    % vars.costs.goal_ee_pos_cost = sum((vars.functions.P{end}(1:2, end) - vars.parameters.goal).^2);
    % vars.costs.goal_joint_vel_cost = sum(sum(vars.variables.dq(:, end).^2));

    vars.costs.joint_torque_cost = vars.costs.joint_torque_cost ./ 8e1;
    vars.costs.joint_vel_cost = vars.costs.joint_vel_cost ./ 3e0;
    vars.costs.ee_vel_cost = vars.costs.ee_vel_cost ./ 2e1;
    vars.costs.joint_torque_change_cost = vars.costs.joint_torque_change_cost ./ 6e5;
    vars.costs.joint_jerk_cost = vars.costs.joint_jerk_cost ./ 2e6;
    % vars.costs.goal_ee_pos_cost = vars.costs.goal_ee_pos_cost ./ 1e-3;
    % vars.costs.goal_joint_vel_cost = vars.costs.goal_joint_vel_cost ./ 3e2;    
    
    % Set
    opti.subject_to(vars.constraints.initial_pos == 0);
    opti.subject_to(vars.constraints.initial_vel == 0);
    opti.subject_to(vars.constraints.dynamics_pos == 0);
    opti.subject_to(vars.constraints.dynamics_vel == 0);
    opti.subject_to(vars.constraints.goal_ee == 0);
end
