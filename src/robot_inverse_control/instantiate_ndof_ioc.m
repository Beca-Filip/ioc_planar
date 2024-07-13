function instantiate_ndof_ioc(vars_ioc, opti_ioc, lambda, theta, q_target)
    % Variables
    opti_ioc.set_initial(vars_ioc.variables.lambda, lambda);
    opti_ioc.set_initial(vars_ioc.variables.theta, theta);
    % Parameters
    opti_ioc.set_value(vars_ioc.target.q_target, q_target);
end