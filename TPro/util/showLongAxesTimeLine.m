%%
function showLongAxesTimeLine(hObject, handles, t)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    yval = sharedInst.X(:);
    ymin = 0;
    ymax = 1;

    hObject.Box = 'off';
    hObject.Color = 'None';
    hObject.FontSize = 1;
    hObject.XMinorTick = 'off';
    hObject.YMinorTick = 'off';
    hObject.XTick = [0];
    hObject.YTick = [0];
    axes(hObject); % set drawing area
    cla;    
    hold on;
    % plot selected frame
    t2 = round((sharedInst.selectFrame - sharedInst.startFrame) / sharedInst.frameSteps) + 1;
    if abs(t-t2) >= 1
        xv = [double(t2)-0.5 double(t2)-0.5 double(t)+0.5 double(t)+0.5];
        yv = [ymin ymax ymax ymin];
        patch(xv,yv,[.1 .7 .1],'FaceAlpha',.4,'EdgeColor','none');
    end
    % plot current time line
    plot([t t], [ymin ymax], ':', 'markersize', 1, 'color', 'r', 'linewidth', 1)  % rodent 1 instead of Cz
    xlim([1 size(yval,1)]);
    ylim([ymin ymax]);
    hold off;
end
