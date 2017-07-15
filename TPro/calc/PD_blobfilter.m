%%
function [ outputImage ] = PD_blobfilter( image, h, sigma, type )
    %   h & sigma : the bigger, the larger the blob can be found
    %   example : >>subplot(121); imagesc(h) >>subplot(122); mesh(h)
    %   >>colormap(jet)

    % filter
    logKernel = fspecial(type, h, sigma);
    % apply filter
    switch(type)
    case 'log'
        %   laplacian of a gaussian (LOG) template
        outputImage = conv2(double(image), logKernel, 'same');
    case 'gaussian'
        image = double(imcomplement(image)) / 256;
        outputImage = conv2(image, logKernel, 'same');
    end
end
