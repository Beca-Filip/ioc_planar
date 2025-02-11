function planeHandle = myConstantPlane(a, p, range, varargin)
    if numel(p) ~= 3
        error("p must be a 3-vector.");
    end
    if numel(a) ~= 3
        error("a must be a 3-vector.");
    end
    a = reshape(a, 1, 3);

    w = null(a); % Find two orthonormal vectors which are orthogonal to v
    [P, Q] = meshgrid(range); % Provide a gridwork (you choose the size)
    X = p(1) + w(1,1)*P + w(1,2)*Q; % Compute the corresponding cartesian coordinates
    Y = p(2) + w(2,1)*P + w(2,2)*Q; % using the two vectors in w
    Z = p(3) + w(3,1)*P + w(3,2)*Q;
    planeHandle = surf(X, Y, Z, varargin{:});
end