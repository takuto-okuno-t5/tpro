%%
function [ outputImage ] = PD_blobfilter( image, h, sigma )
    %   h & sigma : the bigger, the larger the blob can be found
    %   example : >>subplot(121); imagesc(h) >>subplot(122); mesh(h)
    %   >>colormap(jet)

    %   laplacian of a gaussian (LOG) template
    logKernel = fspecial('log', h, sigma);
    %   2d convolution
    outputImage = conv2(double(image), logKernel, 'same');
end
