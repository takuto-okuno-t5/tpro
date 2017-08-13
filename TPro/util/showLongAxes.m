%% show long axis data function
function showLongAxes(hObject, handles, type, roi)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    
    % get data
    switch type
        case 'count'
            yval = getappdata(handles.figure1, [type '_' num2str(roi)]); % get data
            ymin = floor(min(yval) * 0.5);
            ymax = floor(max(yval) * 1.2);
            if ymax < 5
                ymax = 5;
            end
        otherwise
            data = getappdata(handles.figure1, [type '_' roi]); % get data
            if isempty(data)
                data = getappdata(handles.figure1, type);
            end
            if isempty(data) || isnan(data(1))
                yval = [];
                ymin = 0;
                ymax = 0;
            else
                yval = data(:);
                ymin = min(yval);
                ymax = max(yval);
                if 1 > ymin && ymin > 0
                    ymin = 0;
                end
            end
    end
    if ymin==ymax
        ymax = ymin + 1;
    end
    
    axes(hObject); % set drawing area
    cla;
    if isempty(yval)
        return; % noting to show
    end
    hold on;
    plot(1:size(yval,1), yval, 'Color', [.6 .6 1]);
    xlim([1 size(yval,1)]);
    ylim([ymin ymax]);
    hObject.Box = 'off';
    hObject.Color = [0 .05 .1];
    hObject.FontSize = 8;
    hObject.XMinorTick = 'off';
%    hObject.TightInset = hObject.TightInset / 2;
    % xtickOff
    % xticks(0); % from 2016b
    type = strrep(type, '_', ' ');
    text(10, (ymax*0.9+ymin*0.1), type, 'Color',[.6 .6 1], 'FontWeight','bold')
    hold off;
end
