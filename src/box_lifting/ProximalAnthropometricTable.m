function ProximalAnthropometricTable(mass, height, sex, whose)
%PROXIMALANTRHOPOMETRICTABLE returns an anthropometric table where all
%quantities are expressed with respect to the proximal end of the segment,
%w.r.t. the foot.

if ~(0 <= mass && mass <= 600)
    error("Mass should be between 0 and 600kg.")
end
if ~(0 <= height && height <= 3)
    error("Height should be between 0 and 3m.")
end
if ~("male" == lower(sex) || "female" == lower(sex))
    error("Sex should be 'male' or 'female'.")
end
if ~("winter" == lower(whose) || "deleva" == lower(whose) || "dumas" == lower(whose))
    error("Whose should be 'winter', 'deleva', or 'dumas'.");
end

if (lower(sex) == "female")
    sex = 1;
elseif (lower(sex) == "male")
    sex = 2;
end


seg_names= [
    "headwithneck";
    "thorax";
    "abdomen";
    "pelvis";
    "upperarm";
    "forearm";
    "hand";
    "thigh";
    "shank";
    "foot";
];

if (lower(whose) == "dumas")
    
    headwithneck_params = [ ...
        243, 278;
        6.7, 6.7;
        0.8, 2.0;
        55.9, 53.4;
        -0.1, 0.1;
        30, 28;
        24, 21;
        31, 30;
        5i, 7i;
        1, 2i;
        0, 3;
    ];
    
    thorax_params = [ ...
        322, 334;
        26.3, 30.4;
        1.5, 0.0;
        -54.2, -55.5;
        0.1, -0.4;
        38, 43;
        32, 33;
        34, 36;
        12i, 11i;
        3i, 1;
        1, 3;
    ];
    
    abdomen_params = [
        125, 151;
        4.1, 2.9;
        21.9, 17.6;
        -41.0, -36.1;
        0.3, -3.3;
        65, 54;
        78, 66;
        52, 40;
        25, 11;
        3i, 6i;
        5i, 5i;
    ];
    
    pelvis_params = [ ...
        103, 93;
        14.7, 14.2;
        -7.2, -0.2;
        -22.8, -28.2;
        0.2, -0.6;
        95, 102;
        105, 106;
        82, 96;
        35i, 25i;
        3i, 12i;
        2i, 8i;
    ];
    
    upperarm_params = [ ...
        251, 277;
        2.3, 2.4;
        -5.5, 1.8;
        -50.0, -48.2;
        -3.3, -3.1;
        30, 29;
        15, 13;
        30, 30;
        3i, 5;
        5, 3;
        3, 13i;
    ];
    
    forearm_params = [ ...
        247, 283;
        1.4, 1.7;
        2.1, -1.3;
        -41.1, -41.7;
        1.9, 1.1;
        27, 28;
        14, 11;
        25, 28;
        10, 8;
        3, 1i;
        13i, 2;
    ];
    
    hand_params = [ ...
        71, 80;
        0.5, 0.6;
        7.7, 8.2;
        -76.8, -83.9;
        4.8, 7.5;
        64, 61;
        43, 38;
        59, 56;
        29, 22;
        23, 15;
        28i, 20i;
    ];
    
    thigh_params = [ ...
        379, 432;
        14.6, 12.3;
        -7.7, -4.1;
        -37.7, -42.9;
        0.8, 3.3;
        31, 29;
        19, 15;
        32, 30;
        7i, 7;
        2, 2i;
        7i, 7i;
    ];
    
    shank_params = [ ...
        388, 433;
        4.5, 4.8;
        -4.9, -4.8;
        -40.4, -41.0;
        3.1, 0.7;
        28, 28;
        10, 10;
        28, 28;
        2, 4i;
        1, 2i;
        6, 4;
    ];
    
    foot_params = [ ...
        117, 139;
        1.0, 1.2;
        38.2, 50.2;
        -30.9, -19.9;
        5.5, 3.4;
        24, 22;
        50, 49;
        50, 48;
        15i, 17;
        9, 11i;
        5i, 0;
    ];
end


params = cat(3, ...
    headwithneck_params, ...
    thorax_params, ...
    abdomen_params, ...
    pelvis_params, ...
    upperarm_params, ...
    forearm_params, ...
    hand_params, ...
    thigh_params, ...
    shank_params, ...
    foot_params ...
);

disp("params")
size(params)

segLength_mm = squeeze(params(1, sex, :));
segMass_perc = squeeze(params(2, sex, :));
segCoM_perc = squeeze(params(3:5, sex, :));
segInertiaMoments_perc = squeeze(params(6:8, sex, :));
segInertiaProducts_perc = squeeze(params(9:11, sex, :));

disp("extracted")
size(segLength_mm)
size(segMass_perc)
size(segCoM_perc)
size(segInertiaMoments_perc)
size(segInertiaProducts_perc)

segLength_m = segLength_mm ./ 1000 .* (height / meanHeight);
segMass_perc = segMass_perc .* (mass);
segCoM_perc = segCoM_perc .* segLength_m;
segInertiaMoments_perc = segInertiaMoments_perc .* segLength_m;
segInertiaProducts_perc = segInertiaProducts_perc .* segLength_m;


end