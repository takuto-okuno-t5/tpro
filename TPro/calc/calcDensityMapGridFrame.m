% ----- calculate density map (frame) -----
function gridCounts = calcDensityMapGridFrame(x, y, img_w, img_h, width, height)
    % calc grid count
    gridCounts = zeros(ceil(img_h / height), ceil(img_w / width));
    for i=1:length(x)
        ty = y(i);
        tx = x(i);
        if ~isnan(tx) && ~isnan(ty)
            ty = ceil(ty / height);
            tx = ceil(tx / width);
            gridCounts(tx, ty) = gridCounts(tx, ty) + 1;
        end
    end
end
