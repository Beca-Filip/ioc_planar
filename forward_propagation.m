function [Pcom, P, Vcom, V, Acom, A, Fcom] = forward_propagation(q, dq, ddq, L, COM, M, I)

n = size(q, 1);
N = size(q, 2);
P = cell(n+1, 1);
P{1} = zeros(3, N, class(q));
V = cell(n+1, 1);
V{1} = zeros(3, N, class(q));
A = cell(n+1, 1);
A{1} = zeros(3, N, class(q));

Pcom = cell(n, 1);
Vcom = cell(n, 1);
Acom = cell(n, 1);
Fcom = cell(n, 1);

for ii = 1 : n

    Pcom{ii} = zeros(3, N, class(q));
    Pcom{ii}(1, :) = P{ii}(1, :) + COM(1, ii) .* cos(sum(q(1:ii, :), 1)) - COM(2, ii) .* sin(sum(q(1:ii, :), 1));
    Pcom{ii}(2, :) = P{ii}(2, :) + COM(1, ii) .* sin(sum(q(1:ii, :), 1)) + COM(2, ii) .* cos(sum(q(1:ii, :), 1));
    Pcom{ii}(3, :) = P{ii}(3, :) + q(ii, :);
    
    P{ii + 1} = zeros(3, N, class(q));
    P{ii + 1}(1, :) = P{ii}(1, :) + L(ii) .* cos(sum(q(1:ii, :), 1));
    P{ii + 1}(2, :) = P{ii}(2, :) + L(ii) .* sin(sum(q(1:ii, :), 1));
    P{ii + 1}(3, :) = P{ii}(3, :) + q(ii, :);

    Vcom{ii} = zeros(3, N, class(q));
    Vcom{ii}(1, :) = V{ii}(1, :) - COM(1, ii) .* sin(sum(q(1:ii, :), 1)) .* sum(dq(1:ii, :), 1) - COM(2, ii) .* cos(sum(q(1:ii, :), 1)) .* sum(dq(1:ii, :), 1);
    Vcom{ii}(2, :) = V{ii}(2, :) + COM(2, ii) .* cos(sum(q(1:ii, :), 1)) .* sum(dq(1:ii, :), 1) - COM(2, ii) .* sin(sum(q(1:ii, :), 1)) .* sum(dq(1:ii, :), 1);
    Vcom{ii}(3, :) = V{ii}(3, :) + dq(ii, :);

    V{ii + 1} = zeros(3, N, class(q));
    V{ii + 1}(1, :) = V{ii}(1, :) - L(ii) .* sin(sum(q(1:ii, :), 1)) .* sum(dq(1:ii, :), 1);
    V{ii + 1}(2, :) = V{ii}(2, :) + L(ii) .* cos(sum(q(1:ii, :), 1)) .* sum(dq(1:ii, :), 1);
    V{ii + 1}(3, :) = V{ii}(3, :) + dq(ii, :);

    
    Acom{ii} = zeros(3, N, class(q));
    Acom{ii}(1, :) = Acom{ii}(1, :) - COM(1, ii) .* cos(sum(q(1:ii, :), 1)) .* (sum(dq(1:ii, :), 1).^2) ...
                                    - COM(1, ii) .* sin(sum(q(1:ii, :), 1)) .* sum(ddq(1:ii, :), 1) ...
                                    + COM(2, ii) .* sin(sum(q(1:ii, :), 1)) .* (sum(dq(1:ii, :), 1).^2) ...
                                    - COM(2, ii) .* cos(sum(q(1:ii, :), 1)) .* sum(ddq(1:ii, :), 1);
    Acom{ii}(2, :) = Acom{ii}(2, :) - COM(2, ii) .* sin(sum(q(1:ii, :), 1)) .* (sum(dq(1:ii, :), 1).^2) ...
                                    + COM(2, ii) .* cos(sum(q(1:ii, :), 1)) .* sum(ddq(1:ii, :), 1) ...
                                    - COM(2, ii) .* cos(sum(q(1:ii, :), 1)) .* (sum(dq(1:ii, :), 1).^2) ...
                                    - COM(2, ii) .* sin(sum(q(1:ii, :), 1)) .* sum(ddq(1:ii, :), 1);
    Acom{ii}(3, :) = Acom{ii}(3, :) + ddq(ii, :);

    A{ii + 1} = zeros(3, N, class(q));
    A{ii + 1}(1, :) = A{ii}(1, :) - L(ii) .* cos(sum(q(1:ii, :), 1)) .* (sum(dq(1:ii, :), 1).^2) ...
                                  - L(ii) .* sin(sum(q(1:ii, :), 1)) .* sum(ddq(1:ii, :), 1);
    A{ii + 1}(2, :) = A{ii}(2, :) - L(ii) .* sin(sum(q(1:ii, :), 1)) .* (sum(dq(1:ii, :), 1).^2) ...
                                  + L(ii) .* cos(sum(q(1:ii, :), 1)) .* sum(ddq(1:ii, :), 1);
    A{ii + 1}(3, :) = A{ii}(3, :) + ddq(ii, :);

    Fcom{ii} = zeros(3, N, class(q));
    Fcom{ii}(1, :) = M(ii) .* Acom{ii}(1, :);
    Fcom{ii}(2, :) = M(ii) .* Acom{ii}(2, :);
    Fcom{ii}(3, :) = I(ii) .* Acom{ii}(3, :);
end

end