%%
function showMainAxesRectangle(hObject, handles, rect)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared

    hObject.Box = 'off';
    hObject.Color = 'None';
    hObject.FontSize = 1;
    hObject.XMinorTick = 'off';
    hObject.YMinorTick = 'off';
    hObject.XTick = [0];
    hObject.YTick = [0];
    axes(hObject); % set drawing area
    cla;
    % show rectangle
    if ~isempty(rect)
        hold on;
        rectangle('Position', rect, 'EdgeColor', [.5 .5 .9]);
        hold off;
    end
    xlim([1 sharedInst.img_w]);
    ylim([1 sharedInst.img_h]);
end
