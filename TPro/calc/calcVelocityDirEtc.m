%%
function [vxy, accVxy, updownVxy, dir, sideways, sidewaysVelocity, av, ecc, rWingAngle, lWingAngle, rWingAngleV, lWingAngleV] = calcVelocityDirEtc(keep_data, fpsNum, mmPerPixel)
    vxy = calcVxy(keep_data{3}, keep_data{4}) * fpsNum * mmPerPixel;
    accVxy = calcDifferential2(vxy);
    bin = calcBinarize(accVxy, 0);
    updownVxy = calcDifferential(bin);
    updownVxy(isnan(updownVxy)) = 0;
    dir = calcDir(keep_data{5}, keep_data{6});
    sideways = calcSideways(keep_data{2}, keep_data{1}, keep_data{8});
    sidewaysVelocity = calcSidewaysVelocity(vxy, sideways);
    av = abs(calcAngularVelocity(keep_data{8}));
    ecc = keep_data{7};
    if length(keep_data) > 8
        rWingAngle = 180 - mod(dir + 360 - angleAxis2def(keep_data{9}), 360);
        lWingAngle = mod(dir + 360 - angleAxis2def(keep_data{10}), 360) - 180;
        rWingAngleV = [nan(1,size(keep_data{1},2)); diff(rWingAngle)];
        lWingAngleV = [nan(1,size(keep_data{1},2)); diff(lWingAngle)];
    else
        rWingAngle = nan(size(keep_data{1},1), size(keep_data{1},2));
        lWingAngle = nan(size(keep_data{1},1), size(keep_data{1},2));
        rWingAngleV = rWingAngle;
        lWingAngleV = lWingAngle;
    end
end
