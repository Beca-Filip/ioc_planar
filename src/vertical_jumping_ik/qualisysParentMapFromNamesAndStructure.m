function parentMap = qualisysParentMapFromNamesAndStructure(markerNames, parentStruct)
    parentMap = zeros(size(markerNames), 'int64');
    childNames_ = string(fieldnames(parentStruct));
    for n = 1 : length(childNames_)
        childName = childNames_(n);
        parentName = parentStruct.(childName);

        childBoolIdx = strcmp(markerNames, childName);
        parentIdx = find(strcmp(markerNames, parentName));

        parentMap(childBoolIdx) = parentIdx;
    end
end