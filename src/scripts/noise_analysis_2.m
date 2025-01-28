close all

n = 2;
% N = 20;
% T = 1.5;
N = 120;
T = 1.2;

% 
rng(420);
[opti, vars] = make_ndof_model(n, N);

% Parameters
% dt = 0.01;
dt = T / (N-1);
q0 = zeros(n, 1);
q0(1) = -pi/2 + 0.1; q0(2) = 0.1;
dq0 = zeros(n, 1);

L = ones(n, 1);
COM = vertcat(.5 * ones(1, n), zeros(1, n));
M = ones(n, 1);
I = 1/12 * ones(n, 1);

gravity = [0; -9.81];
Fext = cell(n, 1);
for ii = 1 : n
    Fext{ii} = zeros(3, N-2);
end

goal = [1.5; -0.6];

% % Variables
% ddq = zeros(n, N-2);
% dq = repmat(dq0, [1, N-1]);
% q = repmat(q0, [1, N]);

q = [ ...
    linspace(q0(1, 1), -1.0109, N);
    linspace(q0(2, 1), 1.2609, N); 
];

dq = diff(q, 1, 2) ./ dt;
ddq = diff(dq, 1, 2) ./ dt;


% Instantiate
instantiate_ndof_model(vars, opti, dt, q0, dq0, L, COM, M, I, gravity, Fext, goal, ddq, dq, q);

% Parametrize cost
[opti, vars] = parametrize_ndof_cf(vars, opti);

% Optimize options
opti.solver('ipopt');

% Optimize joint velocity
theta_1 = [5000, 1000, 200, 200, 200];
% theta_1 = [1, 200, 500, 300, 1];
% theta_1 = [1, 5000, 1];
theta_1 = theta_1 ./ sum(theta_1);
instantiate_parametrized_ndof_cf(vars, opti, theta_1);
% Solve
sol_1 = opti.solve();
% Numerize
lambda_1 = sol_1.value(opti.lam_g); % Extract dual variables
num_vars_1 = numerize_vars(vars, sol_1);

% Optimize other stuff
theta_2 = [200, 200, 200, 5000, 1000];
% theta_2 = [200, 150, 30];
theta_2 = theta_2 ./ sum(theta_2);
instantiate_parametrized_ndof_cf(vars, opti, theta_2);
sol_2 = opti.solve();
% Numerize
lambda_2 = sol_2.value(opti.lam_g); % Extract dual variables
num_vars_2 = numerize_vars(vars, sol_2);

%% Make IOC

[opti_ioc, vars_ioc] = make_ndof_ioc_model(n, N);

% Instantiate
instantiate_ndof_model(vars_ioc, opti_ioc, dt, q0, dq0, L, COM, M, I, gravity, Fext, goal, num_vars_2.variables.ddq, num_vars_2.variables.dq, num_vars_2.variables.q);

% Do IOC with different noise levels
Nnoise = 11;
noise_level_1 = logspace(-1, 1, Nnoise);
noise_level_2 = logspace(-1, 1, Nnoise);
Theta = nan(size(vars_ioc.variables.theta, 1), Nnoise, Nnoise);
Traj = nan([size(num_vars_2.variables.q), Nnoise, Nnoise]);
ThetaErr = nan(Nnoise, Nnoise);
TrajErr = nan(Nnoise, Nnoise);
NumVars = cell(Nnoise, Nnoise);

% Initialize noisy
num_vars_noisy = num_vars_1;

for ii = 1 : Nnoise
    for jj = 1 : Nnoise
        noise_variance = diag(deg2rad([noise_level_1(ii), noise_level_2(jj)]));
        noise = noise_variance * randn(size(num_vars_1.variables.q));
        num_vars_noisy.variables.q = num_vars_1.variables.q + noise;
        instantiate_ndof_ioc(vars_ioc, opti_ioc, lambda_2, theta_2, num_vars_noisy.variables.q);

        % Optimize options
        opti_ioc.solver('ipopt');
        sol_ioc = opti_ioc.solve();
        
        % Numerize
        num_vars_ioc = numerize_vars(vars_ioc, sol_ioc);

        % Store
        Theta(:, ii, jj) = num_vars_ioc.variables.theta;
        Traj(:, :, ii, jj) = num_vars_ioc.variables.q;
        ThetaErr(ii, jj) = norm(num_vars_ioc.variables.theta - reshape(theta_1, [], 1));
        TrajErr(ii, jj) = sqrt(num_vars_ioc.target.loss ./ numel(num_vars_ioc.variables.q));
        NumVars{ii, jj} = deepCopyStruct(num_vars_ioc);

        % Print identification
        printFormat = sprintf("True theta = [%s]\nId.  theta = [%s].\n", repmat('%.4f, ', 1, length(theta_1)), repmat('%.4f, ', 1, length(theta_1)));
        fprintf(printFormat, theta_1, num_vars_ioc.variables.theta);
    end
end

% Make grid
[noise_grid_1, noise_grid_2] = meshgrid(noise_level_1, noise_level_2);

%%

% Parameter errors
figure('Position', [100, 100, 700, 570]);
surf(noise_grid_1, noise_grid_2, ThetaErr.');
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
view(2);
c = colorbar; % Adds a color bar and returns its handle
% ylabel(c, {'Distance $\| \hat{\theta} - \theta \|_2$ between the true and the'; 'retrieved objective function parameters [1]'}, 'Interpreter', 'latex', 'FontSize', 15); % Labels the color bar
titleobj = title({'Distance $\| \hat{\theta} - \theta \|_2$ between the true and the'; 'retrieved objective function parameters [1]'}, 'Interpreter', 'latex', 'FontSize', 15);
% titleobj.Position(2) = titleobj.Position(2) + 100; 
caxis([min(ThetaErr(:)) max(ThetaErr(:))]); % Optional: Sets the color axis limits to the range of ThetaErr

xlabel({"Variance $\sigma_1$ of noise added"; "to the first joint's trajectory [$^\circ$]"}, 'Interpreter', 'latex', 'FontSize', 15);
ylabel({"Variance $\sigma_2$ of noise added"; "to the second joint's trajectory [$^\circ$]"}, 'Interpreter', 'latex', 'FontSize', 15);
ax = gca; ax.FontSize = 15; ax.TickLabelInterpreter = 'latex';

axis('square');

% Trajectory errors
degTrajErr = rad2deg(TrajErr).';

figure('Position', [100, 100, 700, 570]);
surf(noise_grid_1, noise_grid_2, degTrajErr);
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
view(2);
c = colorbar; % Adds a color bar and returns its handle
% ylabel(c, {'RMSE $\sqrt{\frac{1}{2N} \sum_{i} \sum_{k} (\hat{q}_{k, i} - q_{k, i})^2}$ between the noisy'; 'true and the retrieved optimal trajectory [$^\circ$]'}, 'Interpreter', 'latex', 'FontSize', 15); % Labels the color bar
title({'RMSE $\sqrt{\frac{1}{2N} \sum_{i} \sum_{k} (\hat{q}_{k, i} - q_{k, i})^2}$ between the noisy'; 'true and the retrieved optimal trajectory [$^\circ$]'}, 'Interpreter', 'latex', 'FontSize', 15);

xlabel({"Variance $\sigma_1$ of noise added"; "to the first joint's trajectory [$^\circ$]"}, 'Interpreter', 'latex', 'FontSize', 15);
ylabel({"Variance $\sigma_2$ of noise added"; "to the second joint's trajectory [$^\circ$]"}, 'Interpreter', 'latex', 'FontSize', 15);
ax = gca; ax.FontSize = 15; ax.TickLabelInterpreter = 'latex';

axis('square');

% Saving figures
% TileFigures

figure(1)
% exportgraphics(gcf, "../../img/ThetaErr.pdf", "ContentType", "vector");
exportgraphics(gcf, "../../img/ThetaErr.png", "ContentType", "image", "Resolution", 600);
% 
figure(2)
% exportgraphics(gcf, "../../img/TrajErr.pdf", "ContentType", "vector");
exportgraphics(gcf, "../../img/TrajErr.png", "ContentType", "image", "Resolution", 600);

%%

% Find the maximum traj RMSE
[maxErr, maxErrInd] = max(TrajErr, [], 'all');
[maxErrRow, maxErrCol] = ind2sub(size(TrajErr), maxErrInd);

% Find the median traj RMSE
medErrInd = find(TrajErr == median(TrajErr, 'all'));
[medErrRow, medErrCol] = ind2sub(size(TrajErr), medErrInd);

fprintf('Maximum-error producing noise level for joint 1: %d.\n', maxErrRow);
fprintf('Maximum-error producing noise level for joint 2: %d.\n', maxErrCol);
fprintf('Maximum-error producing noise level: trajectory error: %.2f.\n', rad2deg(TrajErr(maxErrRow, maxErrCol)));
fprintf('Maximum-error producing noise level: parameter error: %.2f.\n', ThetaErr(maxErrRow, maxErrCol));

fprintf('Median-error producing noise level for joint 1: %d.\n', medErrRow);
fprintf('Median-error producing noise level for joint 2: %d.\n', medErrCol);
fprintf('Median-error producing noise level: trajectory error: %.2f.\n', rad2deg(TrajErr(medErrRow, medErrRow)));
fprintf('Median-error producing noise level: parameter error: %.2f.\n', ThetaErr(medErrRow, medErrRow));

% figure('WindowState','maximized');
figure('Position', [30, 30, 720, 480], 'Units', 'Pixels');
hold on;
num_vars_noisy.variables.q = NumVars{maxErrRow, maxErrCol}.target.q_target;
plot_q_from_vars(num_vars_1, 'LineWidth', 3, 'LineStyle', '-', 'Color', 'b');
plot_q_from_vars(num_vars_noisy, 'LineWidth', 1, 'LineStyle', '-.', 'Color', 'r');
plot_q_from_vars(num_vars_2, 'LineWidth', 3, 'LineStyle', ':', 'Color', [.5, .5, .5]);
plot_q_from_vars(NumVars{maxErrRow, maxErrCol}, 'LineWidth', 3, 'LineStyle', '--', 'Color', 'green');
legobj=legend({"Ground truth~~~~~~~~~~~$\boldmath{q}_{True}$"; "Noisy data~~~~~~~~~~~~~~~$\boldmath{q} = \boldmath{q}_{True} + n$"; "IOC initialization~~~~~~$\boldmath{q}_0$"; "Recovered trajectory~~$\hat{\boldmath{q}}$"}, 'Interpreter', 'latex', 'FontSize', 15, 'Location', 'best');
applyLatexToAllSubplots(15);

% In order to resize plot (For Humanoids Poster)
% s1 = subplot(2, 1, 1, 'Units', 'Pixels');
% p1 = s1.Position;
% s2 = subplot(2, 1, 2, 'Units', 'Pixels');
% p2 = s2.Position;


% figure('WindowState','maximized');
figure('Position', [30, 30, 720, 480]);
hold on;
plot_q_from_vars(num_vars_1, 'LineWidth', 2, 'LineStyle', '-');
plot_q_from_vars(num_vars_2, 'LineWidth', 1, 'LineStyle', ':');
num_vars_noisy.variables.q = NumVars{medErrRow, medErrCol}.target.q_target;
plot_q_from_vars(NumVars{medErrRow, medErrCol}, 'LineWidth', 2, 'LineStyle', '--');
plot_q_from_vars(num_vars_noisy, 'LineWidth', 1, 'LineStyle', '-.');
legend({"$\boldmath{q}_{True}$"; "$\boldmath{q}_0$"; "$\hat{\boldmath{q}}$"; "$\boldmath{q} = \boldmath{q}_{True} + n$"}, 'Interpreter', 'latex', 'FontSize', 15, 'Location', 'best');
applyLatexToAllSubplots(15);

% TileFigures

figure(3)
% exportgraphics(gcf, "../../img/q-traj-max-error.pdf", "ContentType", "vector");
exportgraphics(gcf, "../../img/q-traj-max-error.png", "ContentType", "image", "Resolution", 600);

figure(4)
% exportgraphics(gcf, "../../img/ThetaErr.pdf", "ContentType", "vector");
exportgraphics(gcf, "../../img/q-traj-med-error.png", "ContentType", "image", "Resolution", 600);

%%
figure('WindowState', 'maximized');
hold all;
plot_snapshots_from_vars(num_vars_1, 10);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');
expandAxes(1.2);
grid;
xlabel('Sagittal axis: $x$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ylabel('Vertical axis: $z$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ax = gca; ax.FontSize = 25; ax.TickLabelInterpreter = 'latex';

figure('WindowState', 'maximized');
hold all;
plot_snapshots_from_vars(num_vars_2, 10);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');
expandAxes(1.2);
grid;
xlabel('Sagittal axis: $x$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ylabel('Vertical axis: $z$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ax = gca; ax.FontSize = 25; ax.TickLabelInterpreter = 'latex';

figure('WindowState', 'maximized');
hold all;
plot_snapshots_from_vars(num_vars_ioc, 10);
plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
axis('equal');
expandAxes(1.2);
grid;
xlabel('Sagittal axis: $x$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ylabel('Vertical axis: $z$ [m]', 'Interpreter', 'latex', 'FontSize', 25);
ax = gca; ax.FontSize = 25; ax.TickLabelInterpreter = 'latex';

%%
% close all
% 
% figure('WindowState', 'maximized');
% hold all;
% plot_snapshots_from_vars(num_vars_1, 10);
% plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
% axis('equal');
% 
% figure('WindowState', 'maximized');
% hold all;
% plot_snapshots_from_vars(num_vars_2, 10);
% plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
% axis('equal');
% 
% figure('WindowState', 'maximized');
% hold all;
% plot_snapshots_from_vars(num_vars_ioc, 10);
% plot(goal(1), goal(2), 'ro', 'MarkerFaceColor', 'auto', 'MarkerSize', 20);
% axis('equal');
% 
% figure('WindowState','maximized');
% hold on;
% plot_joint_traj_from_vars(num_vars_1);
% plot_joint_traj_from_vars(num_vars_noisy);
% % plot_joint_traj_from_vars(num_vars_2);
% plot_joint_traj_from_vars(num_vars_ioc);
% 
% % figure('WindowState','maximized');
% % hold on;
% % plot_compared_costs(num_vars_1);
% % plot_compared_costs(num_vars_2);
% % plot_compared_costs(num_vars_ioc);
% 
% 
% figure('WindowState','maximized');
% hold on;
% plot_segment_vels_from_vars(num_vars_1);
% plot_segment_vels_from_vars(num_vars_2);
% plot_segment_vels_from_vars(num_vars_ioc);
% 
% TileFigures