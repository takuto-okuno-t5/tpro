%%
function plotWithNewFigure(handles, yval, ymax, ymin)
    figure;
    hold on;
    plot(1:length(yval), yval);
    xlim([1 length(yval)]);
    ylim([ymin ymax]);
    hold off;
    pause(0.2);
    axes(handles.axes1); % set back drawing area
    pause(0.2);
end
