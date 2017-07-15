%%
function trimmedImage = getOneFlyBoxImage(image, pointX, pointY, direction, boxSize, i)
    trimmedImage = getOneFlyBoxImage_(image, pointX(i), pointY(i), direction(:,i), boxSize);
end