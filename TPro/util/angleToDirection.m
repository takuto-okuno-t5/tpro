%%
function directions = angleToDirection(angles, radius)
    directions = nan(length(angles), 2);
    ph = angles ./ 180 .* pi;
    directions(:,1) = radius*cos(ph');
    directions(:,2) = radius*sin(ph');
end
