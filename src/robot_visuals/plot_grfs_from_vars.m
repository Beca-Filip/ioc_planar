function plot_grfs_from_vars(num_vars, varargin)

[~, Ngrf] = size(num_vars.functions.F{1});
tgrf = linspace(0, (Ngrf-1) * num_vars.parameters.dt, Ngrf);

mulo = .6;
muhi = 1.;
mumi = .8;

subplot(3, 1, 1)
hold on;
plot(tgrf, num_vars.functions.F{1}(1, :), varargin{:});
% Coulomb cone
plot(tgrf, -mumi .* abs(num_vars.functions.F{1}(2, :)), 'Color', [0, 0.7, 0.7], varargin{:});
plot(tgrf, mumi .* abs(num_vars.functions.F{1}(2, :)), 'Color', [0.7, 0, 0.7], varargin{:});
ylabel("$F_{{\rm GRF}, x}$", 'Interpreter', 'latex');
grid;

subplot(3, 1, 2)
hold on;
plot(tgrf, num_vars.functions.F{1}(2, :), varargin{:});
plot(tgrf([1, end]), zeros(1, 2), 'Color', [0, 0.7, 0.7], varargin{:});
ylabel("$F_{{\rm GRF}, y}$", 'Interpreter', 'latex');
grid;

subplot(3, 1, 3)
hold on;
plot(tgrf, num_vars.functions.F{1}(3, :), varargin{:});
ylabel("$\tau_{{\rm GRF}, z}$", 'Interpreter', 'latex');
grid;
    
xlabel(sprintf("$t$ [s]"), 'Interpreter', 'latex')

end