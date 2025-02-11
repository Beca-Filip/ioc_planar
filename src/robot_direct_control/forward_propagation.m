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

for k = 1 : n
    
    % Precompute reused quantities
    q_1k = q(1:k, :);
    sumq_1k = sum(q_1k, 1);
    cq_1k = cos(sumq_1k);
    sq_1k = sin(sumq_1k);

    dq_1k = dq(1:k, :);
    sumdq_1k = sum(dq_1k, 1);
    sqsumdq_1k = sumdq_1k.^2;
    
    ddq_1k = ddq(1:k, :);
    sumddq_1k = sum(ddq_1k, 1);

    % Propagate
    Pcom{k} = zeros(3, N, class(q));
    Pcom{k}(1, :) = P{k}(1, :) + COM(1, k) .* cq_1k - COM(2, k) .* sq_1k;
    Pcom{k}(2, :) = P{k}(2, :) + COM(1, k) .* sq_1k + COM(2, k) .* cq_1k;
    Pcom{k}(3, :) = P{k}(3, :) + q(k, :);
    
    P{k + 1} = zeros(3, N, class(q));
    P{k + 1}(1, :) = P{k}(1, :) + L(k) .* cq_1k;
    P{k + 1}(2, :) = P{k}(2, :) + L(k) .* sq_1k;
    P{k + 1}(3, :) = P{k}(3, :) + q(k, :);

    Vcom{k} = zeros(3, N, class(q));
    Vcom{k}(1, :) = V{k}(1, :) - COM(1, k) .* sq_1k .* sumdq_1k - COM(2, k) .* cq_1k .* sumdq_1k;
    Vcom{k}(2, :) = V{k}(2, :) + COM(1, k) .* cq_1k .* sumdq_1k - COM(2, k) .* sq_1k .* sumdq_1k;
    Vcom{k}(3, :) = V{k}(3, :) + dq(k, :);

    V{k + 1} = zeros(3, N, class(q));
    V{k + 1}(1, :) = V{k}(1, :) - L(k) .* sq_1k .* sumdq_1k;
    V{k + 1}(2, :) = V{k}(2, :) + L(k) .* cq_1k .* sumdq_1k;
    V{k + 1}(3, :) = V{k}(3, :) + dq(k, :);

    
    Acom{k} = zeros(3, N, class(q));
    Acom{k}(1, :) = Acom{k}(1, :) - COM(1, k) .* cq_1k .* (sqsumdq_1k) ...
                                    - COM(1, k) .* sq_1k .* sumddq_1k ...
                                    + COM(2, k) .* sq_1k .* (sqsumdq_1k) ...
                                    - COM(2, k) .* cq_1k .* sumddq_1k;
    Acom{k}(2, :) = Acom{k}(2, :) - COM(1, k) .* sq_1k .* (sqsumdq_1k) ...
                                    + COM(1, k) .* cq_1k .* sumddq_1k ...
                                    - COM(2, k) .* cq_1k .* (sqsumdq_1k) ...
                                    - COM(2, k) .* sq_1k .* sumddq_1k;
    Acom{k}(3, :) = Acom{k}(3, :) + ddq(k, :);

    A{k + 1} = zeros(3, N, class(q));
    A{k + 1}(1, :) = A{k}(1, :) - L(k) .* cq_1k .* (sqsumdq_1k) ...
                                  - L(k) .* sq_1k .* sumddq_1k;
    A{k + 1}(2, :) = A{k}(2, :) - L(k) .* sq_1k .* (sqsumdq_1k) ...
                                  + L(k) .* cq_1k .* sumddq_1k;
    A{k + 1}(3, :) = A{k}(3, :) + ddq(k, :);

    Fcom{k} = zeros(3, N, class(q));
    Fcom{k}(1, :) = M(k) .* Acom{k}(1, :);
    Fcom{k}(2, :) = M(k) .* Acom{k}(2, :);
    Fcom{k}(3, :) = I(k) .* Acom{k}(3, :);
end

end