function instantiate_ndof_jumping_model(vars, opti, dt, q0, dq0, mu, L, COM, M, I, qmin, qmax, dqmin, dqmax, taumin, taumax, gravity, Fext, ddq, dq, q)
    
    n = size(q0, 1);

    % Parameters
    opti.set_value(vars.parameters.dt, dt);
    opti.set_value(vars.parameters.q0, q0);
    opti.set_value(vars.parameters.dq0, dq0);

    opti.set_value(vars.parameters.mu, mu);

    opti.set_value(vars.parameters.L, L);
    opti.set_value(vars.parameters.COM, COM);
    opti.set_value(vars.parameters.M, M);
    opti.set_value(vars.parameters.I, I);
    opti.set_value(vars.parameters.qmin, qmin);
    opti.set_value(vars.parameters.qmax, qmax);
    opti.set_value(vars.parameters.dqmin, dqmin);
    opti.set_value(vars.parameters.dqmax, dqmax);
    opti.set_value(vars.parameters.taumin, taumin);
    opti.set_value(vars.parameters.taumax, taumax);

    opti.set_value(vars.parameters.gravity, gravity);
    
    for ii = 1 : n
        opti.set_value(vars.parameters.Fext{ii}, Fext{ii});
    end

    % Variables
    opti.set_initial(vars.variables.ddq, ddq);
    opti.set_initial(vars.variables.dq, dq);
    opti.set_initial(vars.variables.q, q);
end