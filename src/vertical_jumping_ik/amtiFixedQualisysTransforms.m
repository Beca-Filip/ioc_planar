function T = amtiFixedQualisysTransforms()
    %AMTIFIXEDQUALISYSTRANSFORMS returns fixed transforms to the Qualisys frame in
    %the FSPE lab.
    R1 = eye(3);
    R2 = rotationVectorToMatrix([0;0;1]*pi);
    
    p1 = [0.4; 0.6; 0] / 2;
    p2 = [0; 0.72; 0] + [0.4; 0.6; 0] / 2;

    T1 = eye(4);
    T2 = eye(4);
    T1(1:3, 1:3) = R1;
    T2(1:3, 1:3) = R2;
    T1(1:3, 4) = p1;
    T2(1:3, 4) = p2;

    T = cat(3, T1, T2);
end