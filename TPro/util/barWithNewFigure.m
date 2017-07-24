%%
function barWithNewFigure(handles, yval, ymax, ymin, xstart, xend)
    figure;
    hold on;
    bar(xstart:xend, yval);
    xlim([(xstart-1) xend]);
    ylim([ymin ymax]);
    hold off;
    pause(0.1);
    axes(handles.axes1); % set back drawing area
end
