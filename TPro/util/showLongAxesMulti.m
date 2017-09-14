%% show long axis data function
function showLongAxesMulti(hObject, handles, type, roi, flyId)
    sharedInst = getappdata(handles.figure1,'sharedInst'); % get shared
    
    % get data
    data = getappdata(handles.figure1, [type '_' roi]); % get data
    if isempty(data)
        type2 = type;
        if exist('flyId','var') && ~isempty(flyId) && flyId == 0
            type2 = strrep(type, '_tracking', '');
        end
        data = getappdata(handles.figure1, type2);
    end
    if isempty(data) || isnan(data(1))
        yval = [];
        ymin = 0;
        ymax = 0;
        flyNum = 0;
    else
        if exist('flyId','var') && ~isempty(flyId) && flyId > 0 && size(data,1)~=1 && size(data,2)~=1
            if size(data,3) > 1
                mrIdx = 11;
                data = squeeze(data(:,:,mrIdx));
            end
            yval = data(:,flyId);
            flyNum = size(data,2);
            frameNum = size(data,1);
            ymin = min(min(data));
            ymax = max(max(data));
            means = zeros(frameNum,1);
            for i=1:frameNum
                means(i) = nanmean(data(i,:));
            end
        else
            yval = data(:);
            flyNum = 1;
            frameNum = length(yval);
            ymin = min(yval);
            ymax = max(yval);
            means = yval;
        end
        if 1 > ymin && ymin > 0
            ymin = 0;
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
    for i=1:flyNum
        plot(1:frameNum, data(:,i), 'Color', [.25 .25 .4]);
    end
    plot(1:frameNum, means, 'Color', [.25 .6 .25]);
    plot(1:frameNum, yval, 'Color', [1 .2 .2]);
    xlim([1 frameNum]);
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
