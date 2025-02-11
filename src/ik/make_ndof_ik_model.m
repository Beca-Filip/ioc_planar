function [opti, vars] = make_ndof_ik_model(n)
    opti = casadi.Opti();
    
    % Parameters
    vars.parameters.L = opti.parameter(n);
    vars.parameters.qmin = opti.parameter(n);
    vars.parameters.qmax = opti.parameter(n);
    vars.parameters.Ptarget = opti.parameter(2, n);

    % Variables
    vars.variables.q = opti.variable(n);

    % Constants
    dq = zeros(size(vars.variables.q), class(vars.variables.q));
    ddq = zeros(size(vars.variables.q), class(vars.variables.q));
    COM = zeros(2, n, class(vars.variables.q));
    M = zeros(size(vars.variables.q), class(vars.variables.q));
    I = zeros(size(vars.variables.q), class(vars.variables.q));

    % Functions
    [~, vars.functions.P, ~, ~, ~, ~, ~] ...
        = forward_propagation( ...
            vars.variables.q, ...
            dq, ...
            ddq, ...
            vars.parameters.L, ...
            COM,...
            M,...
            I...
        );

    vars.functions.Ptarget = zeros(size(vars.parameters.Ptarget), class(vars.parameters.Ptarget));
    for ii = 1 : n
        vars.functions.Ptarget(:, ii) = vars.functions.P{ii+1}(1:2);
    end

    vars.functions.markerwise_error = sum((vars.functions.Ptarget - vars.parameters.Ptarget).^2, 1).';

    % Constraints
    vars.constraints.angle_lower_limits = -vars.variables.q + vars.parameters.qmin;
    vars.constraints.angle_upper_limits = vars.variables.q - vars.parameters.qmax;
    
    % Costs
    vars.costs.avg_error = sum(vars.functions.markerwise_error) ./ numel(vars.functions.markerwise_error);
    
    % Set
    opti.subject_to(vars.constraints.angle_lower_limits <= 0);
    opti.subject_to(vars.constraints.angle_upper_limits <= 0);

    opti.minimize(vars.costs.avg_error);
end