function [X,Y,Z] = amtiFixedVertices()

    w = 0.6;
    l = 0.4;
    d = 0.72;
    V1 = [0, 0, 0; l, 0, 0; l, w, 0; 0, w, 0].';
    V2 = V1 + [0; d; 0];

    X = horzcat(V1(1, :).', V2(1, :).');
    Y = horzcat(V1(2, :).', V2(2, :).');
    Z = horzcat(V1(3, :).', V2(3, :).');
end