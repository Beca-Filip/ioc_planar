function pMarkers = markersProjectToPlane(Markers, a, b)
%
%   a.' * yhati = b
%   yi - yhati = alphai * a
%   therefore
%   alphai = a.' * yi - b
%   yhati = yi - alphai * a
%         = yi - a * a.' yi + b * a
%         = (I - a * a.') * yi + b * a

if numel(b) ~= 1
    error("b must be a scalar.");
end
if numel(a) ~= 3
    error("a must be a 3-vector.");
end

% Multiply markers (whose 3D coordinates are along the 2nd dimension) by
% the projection matrix
pMarkers = tensorprod((eye(3) - a  * a.'), Markers, 2, 2);
% Swap the 1st and the 2nd dimension to have the same dimension order as 
% Markers (because of how tensorprod works)
pMarkers = permute(pMarkers, [2, 1, 3]);
% Add b
pMarkers = pMarkers + b * reshape(a, [1, 3, 1]);
end