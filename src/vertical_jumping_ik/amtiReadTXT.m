function data = amtiReadTXT(fpath)
    data = readtable(fpath, 'FileType', 'text', 'Delimiter', ',');
    
    columnNames = { ...
        'forceX_1';
        'forceY_1';
        'forceZ_1';
        'momentX_1';
        'momentY_1';
        'momentZ_1';
        'forceX_2';
        'forceY_2';
        'forceZ_2';
        'momentX_2';
        'momentY_2';
        'momentZ_2';
    }.';
    data.Properties.VariableNames = columnNames;
end