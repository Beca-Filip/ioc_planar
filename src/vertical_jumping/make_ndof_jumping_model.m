function [opti, vars] = make_ndof_jumping_model(n, N)
    if N <= 2
        error('Need N>2.');
    end

    opti = casadi.Opti();
    
    % Parameters
    vars.parameters.dt = opti.parameter(1);
    vars.parameters.q0 = opti.parameter(n);
    vars.parameters.dq0 = opti.parameter(n);
    
    vars.parameters.mu = opti.parameter(1);

    vars.parameters.L = opti.parameter(n);
    vars.parameters.COM = opti.parameter(2, n);
    vars.parameters.M = opti.parameter(n);
    vars.parameters.I = opti.parameter(n);
    vars.parameters.qmin = opti.parameter(n);
    vars.parameters.qmax = opti.parameter(n);
    vars.parameters.dqmin = opti.parameter(n);
    vars.parameters.dqmax = opti.parameter(n);
    vars.parameters.taumin = opti.parameter(n);
    vars.parameters.taumax = opti.parameter(n);
    vars.parameters.zmpmin = opti.parameter(1);
    vars.parameters.zmpmax = opti.parameter(1);

    vars.parameters.gravity = opti.parameter(2);
    vars.parameters.Fext = cell(n, 1);
    for ii = 1 : n
        vars.parameters.Fext{ii} = opti.parameter(3, N-1);
    end

    % Variables
    % vars.variables.tau = opti.variable(n, N-2);
    vars.variables.ddq = opti.variable(n, N-1);
    vars.variables.dq = opti.variable(n, N);
    vars.variables.q = opti.variable(n, N);
    
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
    vars.functions.Acomtotal = zeros(2, N, class(vars.variables.ddq));
    for ii = 1 : n
        vars.functions.Pcomtotal = vars.functions.Pcomtotal + vars.parameters.M(ii) * vars.functions.Pcom{ii}(1:2, :);
        vars.functions.Vcomtotal = vars.functions.Vcomtotal + vars.parameters.M(ii) * vars.functions.Vcom{ii}(1:2, :);
        vars.functions.Acomtotal = vars.functions.Acomtotal + vars.parameters.M(ii) * vars.functions.Acom{ii}(1:2, :);
    end
    vars.functions.Pcomtotal = vars.functions.Pcomtotal / sum(vars.parameters.M);
    vars.functions.Vcomtotal = vars.functions.Vcomtotal / sum(vars.parameters.M);
    vars.functions.Acomtotal = vars.functions.Acomtotal / sum(vars.parameters.M);
    
    vars.functions.zmp = vars.functions.F{1}(3, 1:end-1) ./ vars.functions.F{1}(2, 1:end-1);

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

    vars.constraints.friction_cone = [ ...
        vars.functions.F{1}(1, :) - vars.parameters.mu * vars.functions.F{1}(2, :);
        -vars.functions.F{1}(1, :) - vars.parameters.mu * vars.functions.F{1}(2, :);
    ];
    
    vars.constraints.positive_vertical_takeoff_velocity = -vars.functions.Vcomtotal(2, end);
    vars.constraints.vertical_stability = [-vars.functions.zmp + vars.parameters.zmpmin; vars.functions.zmp - vars.parameters.zmpmax];
    
    % Costs
    vars.costs.avg_joint_torque_cost = sum(sum(vars.functions.model_tau.^2)) / N / n;
    vars.costs.avg_joint_torque_change_cost = sum(sum( diff(vars.functions.model_tau, 1, 2).^2 )) ./ vars.parameters.dt^2 / N / n;
    vars.costs.avg_joint_vel_cost = sum(sum(vars.variables.dq.^2)) / N / n;
    vars.costs.avg_joint_acc_cost = sum(sum(vars.variables.ddq.^2)) / N / n;
    vars.costs.avg_joint_jer_cost = sum(sum(diff(vars.variables.ddq, 1, 2).^2)) ./ vars.parameters.dt.^2 / N / n;
    vars.costs.avg_ee_vel_cost = sum(sum(vars.functions.V{end}.^2)) / N;
    vars.costs.avg_ee_acc_cost = sum(sum(vars.functions.A{end}.^2)) / N;
    vars.costs.avg_ee_jer_cost = sum(sum(diff(vars.functions.A{end}, 1, 2).^2)) ./ vars.parameters.dt.^2 / N;

    vars.costs.max_com_height_cost = -(vars.functions.Pcomtotal(2, end) + vars.functions.Vcomtotal(2, end)^2 ./ (2 * abs(vars.parameters.gravity(2)))); 
    vars.costs.com_horizontal_vel_cost = vars.functions.Vcomtotal(1, end).^2; 
    vars.costs.takeoff_grf_cost = vars.functions.F{1}(2, end).^2;
    
    % Set
    opti.subject_to(vars.constraints.initial_pos == 0);
    opti.subject_to(vars.constraints.initial_vel == 0);
    opti.subject_to(vars.constraints.dynamics_pos == 0);
    opti.subject_to(vars.constraints.dynamics_vel == 0);
    opti.subject_to(vars.constraints.takeoff_grf == 0);

    opti.subject_to(vars.constraints.angle_lower_limits(:) <= 0);
    opti.subject_to(vars.constraints.angle_upper_limits(:) <= 0);
    opti.subject_to(vars.constraints.velocity_lower_limits(:) <= 0);
    opti.subject_to(vars.constraints.velocity_upper_limits(:) <= 0);
    opti.subject_to(vars.constraints.torque_lower_limits(:) <= 0);
    opti.subject_to(vars.constraints.torque_upper_limits(:) <= 0);
    opti.subject_to(vars.constraints.vertical_grf <= 0);
    opti.subject_to(vars.constraints.friction_cone(:) <= 0);
    opti.subject_to(vars.constraints.positive_vertical_takeoff_velocity <= 0);
    opti.subject_to(vars.constraints.vertical_stability(:) <= 0);
end