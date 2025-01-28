Aeq = ones(size(vars.compound.theta.'));
beq = 1;

lb_theta = zeros(size(vars.compound.theta, 1));

tic
[opt_theta, opt_Err] = fmincon(@(theta) gradient_free_bilevel_inner_loop(theta, vars, opti, num_vars_noisy.variables.q), theta_2, [], [], Aeq, beq, lb_theta, [], []);
fprintf("Total time it took: %.6f s.\n", toc)