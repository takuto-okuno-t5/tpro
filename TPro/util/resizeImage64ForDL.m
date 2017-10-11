%%
function Iout = resizeImage64ForDL(I)
    % Some images may be grayscale. Replicate the image 3 times to
    % create an RGB image. 
    %    if ismatrix(I)
    %        I = cat(3,I,I,I);
    %    end

    % Resize the image as required for the CNN. 
    if size(I,1) ~= 64 || size(I,2) ~= 64
        Iout = imresize(I, [64 64]);  
    else
        Iout = I;
    end
end
