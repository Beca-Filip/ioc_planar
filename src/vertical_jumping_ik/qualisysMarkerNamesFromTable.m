function markerNames = qualisysMarkerNamesFromTable(data)

    markerNames = data.Properties.VariableNames;
    markerNames = strrep(markerNames, "_pos_X", "");
    markerNames = strrep(markerNames, "_pos_Y", "");
    markerNames = strrep(markerNames, "_pos_Z", "");
    markerNames = unique(markerNames);
    markerNames = string(markerNames);
    
end