%%
function retFigure = plotWithNewFigure(handles, yval, ymax, ymin, hFigure)
    if isempty(hFigure)
        retFigure = figure();
    else
        figure(hFigure);
        retFigure = hFigure;
    end
    hold on;
    plot(1:length(yval), yval);
    xlim([1 length(yval)]);
    ylim([ymin ymax]);
    hold off;
    pause(0.2);
    axes(handles.axes1); % set back drawing area
    pause(0.2);
end
