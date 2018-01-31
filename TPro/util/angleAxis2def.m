%%
function defangles = angleAxis2def(angles)
    defangles = mod(360 - angles, 360);
end
