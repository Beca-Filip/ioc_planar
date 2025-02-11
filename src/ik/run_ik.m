function [Q, MWE, E, varargout] = run_ik(n, L, qmin, qmax, Ptarget_tensor, varargin)

% # Process inputs
if ~isempty(varargin)
    q = varargin{1};
else
    q = zeros(n, 1);
end
[N, ~, ~] = size(Ptarget_tensor);

% # Preallocate outputs
Q = zeros(n, N);
MWE = zeros(n, N);
E = zeros(1, N);

% Additional outputs
if nargout > 3
    Markers = zeros(N, 2, n);
end

% # Do the work
[opti, vars] = make_ndof_ik_model(n);

% ## Prepare optimization
% Casadi interface options
plugin_options = struct;
plugin_options.print_time = 0;
plugin_options.verbose = 0;
plugin_options.regularity_check = true;
% Ipopt options
solver_options.print_level = 0;
solver_options.sb ='yes';
solver_options.check_derivatives_for_naninf = 'yes';

opti.solver('ipopt', plugin_options, solver_options);

% ## Sample-by-sample IK
for ii = 1 : N
    % Update target
    Ptarget = squeeze(Ptarget_tensor(ii, :, :));
    instantiate_ndof_ik_model(vars, opti, L, qmin, qmax, Ptarget, q);
    
    % Solve
    sol = opti.solve();
    q = sol.value(vars.variables.q);
    mwe = sol.value(vars.functions.markerwise_error);
    e = sol.value(vars.costs.avg_error);
    
    % Store
    Q(:, ii) = q;
    MWE(:, ii) = mwe;
    E(ii) = e;

    % Additional outputs
    if nargout > 3
        Markers(ii, :, :) = sol.value(vars.functions.Ptarget);
    end
end

if nargout > 3
    varargout{1} = Markers;
end

end