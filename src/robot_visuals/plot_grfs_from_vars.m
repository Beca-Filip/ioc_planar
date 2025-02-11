function plot_grfs_from_vars(vars, varargin)

[~, Ngrf] = size(vars.functions.F{1});
tgrf = linspace(0, (Ngrf-1) * vars.parameters.dt, Ngrf);

mulo = .6;
muhi = 1.;
mumi = .8;

subplot(3, 1, 1)
hold on;
plot(tgrf, vars.functions.F{1}(1, :), varargin{:});
% Coulomb cone
plot(tgrf, -mumi .* abs(vars.functions.F{1}(2, :)), 'Color', [0, 0.7, 0.7], varargin{:});
plot(tgrf, mumi .* abs(vars.functions.F{1}(2, :)), 'Color', [0.7, 0, 0.7], varargin{:});
ylabel("$F_{{\rm GRF}, x}$", 'Interpreter', 'latex');
grid;

vars.functions.verticalGrfFromCom = sum(vars.parameters.M) * (abs(vars.parameters.gravity(2)) + vars.functions.Acomtotal(2, :));
% NnumA = size(vars.functions.verticalGrfFromCom, 2);

subplot(3, 1, 2)
hold on;
plot(tgrf, vars.functions.F{1}(2, :), varargin{:});
plot(tgrf, vars.functions.verticalGrfFromCom, varargin{:});
plot(tgrf([1, end]), zeros(1, 2), 'Color', [0, 0.7, 0.7], varargin{:});
ylabel("$F_{{\rm GRF}, y}$", 'Interpreter', 'latex');
grid;

subplot(3, 1, 3)
hold on;
plot(tgrf, vars.functions.F{1}(3, :), varargin{:});
ylabel("$\tau_{{\rm GRF}, z}$", 'Interpreter', 'latex');
grid;
    
xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')

end