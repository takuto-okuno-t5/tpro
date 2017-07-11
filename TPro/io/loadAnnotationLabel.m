%% load annotation_label.csv file
function loadAnnotationLabel(handles)
    labelFileName = 'annotation_label.csv';
    annoLabel = [];
    annoKeyMap = zeros(9,1);
    if exist(labelFileName, 'file')
        labelTable = readtable(labelFileName,'ReadVariableNames',false);
        labels = table2cell(labelTable);
        annoLabel = cell(max(cell2mat(labels(:,1))),1);
        for i=1:size(annoLabel,1)
            annoLabel{labels{i,1}} = labels{i,2};
            for j=1:9
                if j==labels{i,3}
                    annoKeyMap(j) = labels{i,1};
                    break;
                end
            end
        end
    end
    
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    sharedInst.annoLabel = annoLabel;
    sharedInst.annoKeyMap = annoKeyMap;
    setappdata(handles.figure1,'sharedInst',sharedInst); % set shared instance
end
