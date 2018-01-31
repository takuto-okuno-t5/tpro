%%
function angles = directionToAngle(dirX, dirY)
    angles = nan(length(dirX), 1);
    angles(:,1) = atan2d(dirY ./ dirX);
    angles = mod(angles + 360, 360);
end
