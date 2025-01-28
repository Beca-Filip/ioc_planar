function [qlo, qhi] = humanJointLimits(n)
   qlo = deg2rad([30,  -5,   -180, -15, 0  ]);
   qhi = deg2rad([150, 180, 30,   225, 180]);

   qlo = qlo(1:n);
   qhi = qhi(1:n);
end