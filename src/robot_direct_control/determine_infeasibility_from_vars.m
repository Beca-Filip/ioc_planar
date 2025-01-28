function [constraints_violated, constraint_violations] = determine_infeasibility_from_vars(vars, varargin)

if nargin > 1
    eps = varargin{1};
else
    eps = 1e-6;
end

constr_names = fieldnames(vars.constraints);
for constr_cell = constr_names.'
    disp(constr_cell{1})
    constr = constr_cell{1};
    
    % Verify violation
    constraints_violated.(constr) = reshape(find(vars.constraints.(constr) > eps), 1, []);
    constraint_violations.(constr) = reshape(vars.constraints.(constr)(constraints_violated.(constr)), 1, []);
end

end