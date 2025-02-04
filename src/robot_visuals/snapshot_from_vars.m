function varargout = snapshot_from_vars(num_vars, ii, marker_size, line_width)
if nargin < 4
    line_width = 2;
end
if nargin < 3
    marker_size = 15;
end

n = size(num_vars.variables.q, 1);

hold all;

P = cell2mat(num_vars.functions.P);
Px = P(1 : 3 : end-2, ii);
Py = P(2 : 3 : end-1, ii);
Ptheta = P(3 : 3 : end, ii);
Ux = [num_vars.parameters.L; num_vars.parameters.L(end)] .* cos(Ptheta);
Vx = [num_vars.parameters.L; num_vars.parameters.L(end)] .* sin(Ptheta);
Uy = [num_vars.parameters.L; num_vars.parameters.L(end)] .* (-sin(Ptheta));
Vy = [num_vars.parameters.L; num_vars.parameters.L(end)] .* cos(Ptheta);

Pcom = cell2mat(num_vars.functions.Pcom);
Pcomx = Pcom(1 : 3 : end-2, ii);
Pcomy = Pcom(2 : 3 : end-1, ii);

if isfield(num_vars.functions, 'Pcomtotal')
    Pcomtotalx = num_vars.functions.Pcomtotal(1, ii);
    Pcomtotaly = num_vars.functions.Pcomtotal(2, ii);
end

plot(Px, Py, 'Color', [0, 0, 0], 'LineStyle', '-', 'Marker', 'o', 'MarkerSize', marker_size, 'LineWidth', line_width);

quiver(Px, Py, Ux, Vx, .1, 'LineWidth', line_width, 'Color', [1, 0, 0]);
quiver(Px, Py, Uy, Vy, .1, 'LineWidth', line_width, 'Color', [0, 1, 0]);

plot(Pcomx, Pcomy, 'Color', 'c', 'LineStyle', 'None', 'Marker', 'o', 'MarkerSize', marker_size, 'LineWidth', line_width);

if isfield(num_vars.functions, 'Pcomtotal')
    plot(Pcomtotalx, Pcomtotaly, 'Color', [0.2, 0.7, 0.05], 'LineStyle', 'None', 'Marker', 'square', 'MarkerSize', marker_size, 'LineWidth', line_width);
end

if nargout > 0
    varargout{1} = [Px, Py];
    varargout{2} = [Ux, Uy];
    varargout{3} = [Vx, Vy];
    varargout{4} = [Pcomx, Pcomy];    
end
end