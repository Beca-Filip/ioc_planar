function vars = make_ndof_jumping_model_sym(n, N)
    if N <= 2
        error('Need N>2.');
    end
    
    % Parameters
    vars.parameters.dt = sym("dt", [1, 1]);
    vars.parameters.q0 = sym("q0", [n, 1]);
    vars.parameters.dq0 = sym("dq0", [n, 1]);

    vars.parameters.L = sym("L", [n, 1]);
    vars.parameters.COM = sym("COM", [2, n]);
    vars.parameters.M = sym("M", [n, 1]);
    vars.parameters.I = sym("I", [n, 1]);
    vars.parameters.qmin = sym("qmin", [n, 1]);
    vars.parameters.qmax = sym("qmax", [n, 1]);
    vars.parameters.dqmin = sym("dqmin", [n, 1]);
    vars.parameters.dqmax = sym("dqmax", [n, 1]);
    vars.parameters.taumin = sym("taumin", [n, 1]);
    vars.parameters.taumax = sym("taumax", [n, 1]);

    vars.parameters.gravity = sym("gravity", [2, 1]);
    vars.parameters.Fext = cell(n, 1);
    for ii = 1 : n
        % vars.parameters.Fext{ii} = sym(sprintf("Fext%02d", ii), [3, N-1]);
        vars.parameters.Fext{ii} = zeros([3, N-1], class(vars.parameters.dt));
    end

    % Variables
    % vars.variables.tau = sym("tau", [n, N-2]);
    vars.variables.ddq = sym("ddq", [n, N-1]);
    vars.variables.dq = sym("dq", [n, N]);
    vars.variables.q = sym("q", [n, N]);
    
    % Functions
    vars.functions.q = vars.variables.q;
    vars.functions.dq = horzcat(vars.variables.dq);
    vars.functions.ddq =  horzcat(vars.variables.ddq, zeros(n, 1, class(vars.variables.ddq)));
    vars.functions.Fext = cell(n, 1);
    for ii = 1 : n
        vars.functions.Fext{ii} = horzcat(vars.parameters.Fext{ii}, zeros(3, 1, class(vars.parameters.Fext{ii})));
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

    % Get total com
    vars.functions.Pcomtotal = zeros(2, N, class(vars.variables.ddq));
    vars.functions.Vcomtotal = zeros(2, N, class(vars.variables.ddq));
    for ii = 1 : n
        vars.functions.Pcomtotal = vars.functions.Pcomtotal + vars.parameters.M(ii) * vars.functions.Pcom{ii}(1:2, :);
        vars.functions.Vcomtotal = vars.functions.Vcomtotal + vars.parameters.M(ii) * vars.functions.Vcom{ii}(1:2, :);
    end
    vars.functions.Pcomtotal = vars.functions.Pcomtotal / sum(vars.parameters.M);
    vars.functions.Vcomtotal = vars.functions.Vcomtotal / sum(vars.parameters.M);

    % Constraints
    vars.constraints.initial_pos = vars.variables.q(:, 1) - vars.parameters.q0;
    vars.constraints.initial_vel = vars.variables.dq(:, 1) - vars.parameters.dq0;

    vars.constraints.dynamics_pos = vars.variables.q(:, 2:end) - vars.variables.q(:, 1:end-1) - vars.variables.dq(:, 1:end-1) .* vars.parameters.dt;
    vars.constraints.dynamics_vel = vars.variables.dq(:, 2:end) - vars.variables.dq(:, 1:end-1) - vars.variables.ddq .* vars.parameters.dt;

    vars.constraints.angle_lower_limits = -vars.variables.q + vars.parameters.qmin;
    vars.constraints.angle_upper_limits = vars.variables.q - vars.parameters.qmax;

    vars.constraints.velocity_lower_limits = -vars.variables.dq + vars.parameters.dqmin;
    vars.constraints.velocity_upper_limits = vars.variables.dq - vars.parameters.dqmax;
    
    vars.constraints.torque_lower_limits = -vars.functions.model_tau + vars.parameters.taumin;
    vars.constraints.torque_upper_limits = vars.functions.model_tau - vars.parameters.taumax;

    vars.constraints.takeoff_grf = vars.functions.F{1}(2, end);
    vars.constraints.vertical_grf = -vars.functions.F{1}(2, :);
    
    % Costs
    vars.costs.joint_torque_cost = sum(sum(vars.functions.model_tau.^2)) / N / n;
    vars.costs.joint_vel_cost = sum(sum(vars.variables.dq.^2)) / N / n;
    vars.costs.ee_vel_cost = sum(sum(vars.functions.V{end}.^2)) / N;
    vars.costs.joint_torque_change_cost = sum(sum( (vars.functions.model_tau(:, 2:end) - vars.functions.model_tau(:, 1:end-1)).^2 )) ./ vars.parameters.dt^2 / N / n;
    vars.costs.joint_jerk_cost = sum(sum( (vars.variables.ddq(:, 2:end) - vars.variables.ddq(:, 1:end-1)).^2 )) ./ vars.parameters.dt^2 / N / n;
    % vars.costs.goal_ee_pos_cost = sum((vars.functions.P{end}(1:2, end) - vars.parameters.goal).^2);
    % vars.costs.goal_joint_vel_cost = sum(sum(vars.variables.dq(:, end).^2));
    vars.costs.com_takeoff = -vars.functions.Pcomtotal(2, end) - vars.functions.Vcom{end}(2, end)^2 ./ (2 * abs(vars.parameters.gravity(2)));

    vars.costs.joint_torque_cost = vars.costs.joint_torque_cost ./ 8e1;
    vars.costs.joint_vel_cost = vars.costs.joint_vel_cost ./ 3e0;
    vars.costs.ee_vel_cost = vars.costs.ee_vel_cost ./ 2e1;
    vars.costs.joint_torque_change_cost = vars.costs.joint_torque_change_cost ./ 6e5;
    vars.costs.joint_jerk_cost = vars.costs.joint_jerk_cost ./ 2e6;
    % vars.costs.goal_ee_pos_cost = vars.costs.goal_ee_pos_cost ./ 1e-3;
    % vars.costs.goal_joint_vel_cost = vars.costs.goal_joint_vel_cost ./ 3e2;    
    
    % Set
    % opti.subject_to(vars.constraints.initial_pos == 0);
    % opti.subject_to(vars.constraints.initial_vel == 0);
    % opti.subject_to(vars.constraints.dynamics_pos == 0);
    % opti.subject_to(vars.constraints.dynamics_vel == 0);
    % opti.subject_to(vars.constraints.takeoff_grf == 0);

    % opti.subject_to(vars.constraints.angle_lower_limits(:) <= 0);
    % opti.subject_to(vars.constraints.angle_upper_limits(:) <= 0);
    % opti.subject_to(vars.constraints.velocity_lower_limits(:) <= 0);
    % opti.subject_to(vars.constraints.velocity_upper_limits(:) <= 0);
    % opti.subject_to(vars.constraints.torque_lower_limits(:) <= 0);
    % opti.subject_to(vars.constraints.torque_upper_limits(:) <= 0);
    % opti.subject_to(vars.constraints.vertical_grf <= 0);
end