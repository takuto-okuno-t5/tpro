%%
function directions = angleToDirection(angles, radius)
    directions = nan(length(angles), 2);
    for i=1:length(angles)
        ph = angles(i)/180 * pi;
        cosph =  cos(ph);
        sinph =  sin(ph);
        directions(i,:) = [radius*cosph, radius*sinph];
    end
end
