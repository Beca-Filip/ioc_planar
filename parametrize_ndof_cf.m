function [opti, vars] = parametrize_ndof_cf(vars, opti)
    
    % The precomputed costs and their number
    cost_names = fieldnames(vars.costs);
    ncosts = length(cost_names);

    % Create cost ponderation
    vars.compound.theta = opti.parameter(ncosts);
    
    % Initialize cost as ponderation 1 times cost 1
    cost = vars.compound.theta(1) * vars.costs.(cost_names{1});
    
    % Add all other costs with their ponderation
    for ii = 2 : ncosts
        cost = cost + vars.compound.theta(ii) * vars.costs.(cost_names{ii});
    end
    
    % Memorize the compound cost
    vars.compound.cost = cost;
    opti.minimize(cost);
end