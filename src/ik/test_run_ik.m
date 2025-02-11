function test_run_ik(n, N)
if nargin < 2
    N = 100;
end

t = linspace(0, 2*pi, N);
q = zeros(n, N);
for ii = 1 : n
    if ~mod(ii, 2)
        q(ii, :) = sin((1 + div(ii-1, 2)) * t);
    else
        q(ii, :) = pi/2 * cos((1 + div(ii-1, 2)) * t);
    end
end

% Needed for FK, but treated as constants
dq = zeros(size(q));
ddq = zeros(size(q));

L = ones(n, 1);
COM = zeros(2, n);
M = zeros(n, 1);
I = zeros(n, 1);

% FK
[~, P, ~, ~, ~, ~, ~] ...
    = forward_propagation( ...
        q, ...
        dq, ...
        ddq, ...
        L, ...
        COM,...
        M,...
        I...
    );

% Rearrange
P = cat(3, P{:});
P = permute(P, [2, 1, 3]);
% Remove 0th marker
P = P(:, :, 2:end);
% Remove orientation (theta)
P = P(:, 1:2, :);

% Limits
qmin = -pi * ones(n, 1);
qmax = pi * ones(n, 1);

% Run IK
q0 = q(:, 1);
[Q, MWE, E] = run_ik(n, L, qmin, qmax, P, q0);

figure('WindowState', 'fullscreen');
for ii = 1 : n
    subplot(n, 1, ii)
    hold on;
    plot(t, q(ii, :), 'g', 'LineWidth', 2, 'DisplayName', 'ref');
    plot(t, Q(ii, :), 'b--', 'LineWidth', 1, 'DisplayName', 'ik');
    grid;
    ylabel(sprintf("$q_{%d}(t), {\\rm mwe} = %.2f$", ii, sqrt(mean(MWE(ii, :)))), 'Interpreter', 'latex', 'FontSize', 15);
    if ii == n
        xlabel("$t$ [s]", 'Interpreter', 'latex', 'FontSize', 15);
    end
    if ii == 1
        legend("Location", "best", "FontSize", 15);
    end
end

end