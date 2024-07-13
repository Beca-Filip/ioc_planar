function [opti_ioc, vars_ioc] = make_ndof_ioc_model(n, N)
    % Make DOC model
    [opti_ioc, vars_ioc] = make_ndof_model(n, N);

    % Extract dual variables size
    ndual = size(opti_ioc.g, 1);
    % Extract parameters size
    cost_names = fieldnames(vars_ioc.costs);
    ncosts = length(cost_names);
    
    % Create dual variable parameter
    vars_ioc.variables.lambda = opti_ioc.variable(ndual);
    % Create model parameter
    vars_ioc.variables.theta = opti_ioc.variable(ncosts);
    
    % Prepare stationarity constraint
    % Compute cost and gradient
    vars_ioc.compound.cost = vars_ioc.variables.theta(1) * vars_ioc.costs.(cost_names{1});
    for ii = 2 : ncosts
        vars_ioc.compound.cost = vars_ioc.compound.cost + vars_ioc.variables.theta(ii) * vars_ioc.costs.(cost_names{ii});
    end
    vars_ioc.compound.cost_gradient = jacobian(vars_ioc.compound.cost, [vec(vars_ioc.variables.q); vec(vars_ioc.variables.dq); vec(vars_ioc.variables.ddq)]).';
    % Compute constraints and gradient
    vars_ioc.compound.constraints = [vec(vars_ioc.constraints.initial_pos); vec(vars_ioc.constraints.initial_vel); vec(vars_ioc.constraints.dynamics_pos); vec(vars_ioc.constraints.dynamics_vel); vec(vars_ioc.constraints.goal_ee)];
    vars_ioc.compound.constraints_gradient = jacobian(vars_ioc.compound.constraints, [vec(vars_ioc.variables.q); vec(vars_ioc.variables.dq); vec(vars_ioc.variables.ddq)]).';
    % Stationarity
    vars_ioc.compound.stationarity = vars_ioc.compound.cost_gradient + vars_ioc.compound.constraints_gradient * vars_ioc.variables.lambda;
    
    % Subject to
    opti_ioc.subject_to(vars_ioc.compound.stationarity == 0);
    opti_ioc.subject_to(sum(vars_ioc.variables.theta) == 1);
    opti_ioc.subject_to(vars_ioc.variables.theta >= 0);
    
    % Create input trajectory
    vars_ioc.target.q_target = opti_ioc.parameter(size(vars_ioc.variables.q, 1), size(vars_ioc.variables.q, 2));
    % Create L2 loss
    vars_ioc.target.loss = sum(sum((vars_ioc.variables.q - vars_ioc.target.q_target).^2));
    
    % Help search by constraining maximum-distance
    opti_ioc.subject_to(vec(vars_ioc.variables.q - vars_ioc.target.q_target) <= pi/4)
    opti_ioc.subject_to(vec(-vars_ioc.variables.q + vars_ioc.target.q_target) <= pi/4)

    % Optimize
    opti_ioc.minimize(vars_ioc.target.loss);
end