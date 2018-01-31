%%
function wingImage = applyWingFilter(img, wingColorMin, wingColorMax)
    wingImage = img;
    wingImage(wingImage >= wingColorMax) = 255;
    wingImage(wingImage <= wingColorMin) = 255;
    wingImage = 255 - wingImage;
    wingImage(wingImage > 0) = 255;

    % blur and cut again
    wingImage = imgaussfilt(wingImage, 1);
    wingImage(wingImage <= wingColorMin) = 0;
    wingImage(wingImage > wingColorMin) = 255;
end
