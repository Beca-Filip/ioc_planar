function instantiate_ndof_ik_model(vars, opti, L, qmin, qmax, Ptarget, q)
    % Parameters
    opti.set_value(vars.parameters.L, L);
    opti.set_value(vars.parameters.qmin, qmin);
    opti.set_value(vars.parameters.qmax, qmax);
    opti.set_value(vars.parameters.Ptarget, Ptarget);

    % Variables
    opti.set_initial(vars.variables.q, q);
end