%%
function addResult2Axes(handles, result, itemName, popupmenu)
    listItems = cellstr(get(popupmenu,'String'));
    added = sum(strcmp(itemName, listItems));
    if added == 0
        listItems = [listItems;{itemName}];
        set(popupmenu,'String',listItems);
    end
    setappdata(handles.figure1,itemName,result); % update shared

    % update axes
    idx = 0;
    for i=1:length(listItems)
        if strcmp(listItems{i},itemName)
            idx = i; break;
        end
    end
    if idx > 0
        set(popupmenu,'Value',idx);
    end
end
