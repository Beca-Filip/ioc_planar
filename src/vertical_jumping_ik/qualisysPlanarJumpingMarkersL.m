function Markers = qualisysPlanarJumpingMarkersL(data)

    l_metatarsal = data(:, ["l_metatarsal_pos_X", "l_metatarsal_pos_Y", "l_metatarsal_pos_Z"]);
    l_ankle = data(:, ["l_ankle_pos_X", "l_ankle_pos_Y", "l_ankle_pos_Z"]);
    l_knee = data(:, ["l_knee_pos_X", "l_knee_pos_Y", "l_knee_pos_Z"]);
    l_hip = data(:, ["l_hip_pos_X", "l_hip_pos_Y", "l_hip_pos_Z"]);
    l_shoulder = data(:, ["l_shoulder_pos_X", "l_shoulder_pos_Y", "l_shoulder_pos_Z"]);
    l_elbow = data(:, ["l_elbow_pos_X", "l_elbow_pos_Y", "l_elbow_pos_Z"]);
    l_wrist = data(:, ["l_wrist_pos_X", "l_wrist_pos_Y", "l_wrist_pos_Z"]);

    l_metatarsal = table2array(l_metatarsal);
    l_ankle = table2array(l_ankle);
    l_knee = table2array(l_knee);
    l_hip = table2array(l_hip);
    l_shoulder = table2array(l_shoulder);
    l_elbow = table2array(l_elbow);
    l_wrist = table2array(l_wrist);

    Markers = cat(3, l_metatarsal, l_ankle, l_knee, l_hip, l_shoulder, l_elbow, l_wrist);
end