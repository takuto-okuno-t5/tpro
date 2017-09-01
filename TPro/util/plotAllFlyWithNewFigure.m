%%
function retFigure = plotAllFlyWithNewFigure(handles, yvals, ymax, ymin, hFigure)
    if isempty(hFigure)
        retFigure = figure();
    else
        figure(hFigure);
        retFigure = hFigure;
    end
    for fn=1:size(yvals,2)
        hold on;
        plot(1:size(yvals,1), yvals(:,fn));
        hold off;
    end
    xlim([1 size(yvals,1)]);
    ylim([ymin ymax]);
    pause(0.2);
    axes(handles.axes1); % set back drawing area
    pause(0.2);
end
