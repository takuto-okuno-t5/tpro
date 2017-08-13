%% Object Detection Using Deep Learning
% This example shows how to train an object detector using deep learning
% and R-CNN (Regions with Convolutional Neural Networks).
%
% Copyright 2016 The MathWorks, Inc.

%% Overview
% This example shows how to train an R-CNN object detector for detecting
% stop signs. R-CNN is an object detection framework, which uses a
% convolutional neural network (CNN) to classify image regions within an
% image [1]. Instead of classifying every region using a sliding window,
% the R-CNN detector only processes those regions that are likely to
% contain an object. This greatly reduces the computational cost incurred
% when running a CNN.
%
% To illustrate how to train an R-CNN stop sign detector, this example
% follows the transfer learning workflow that is commonly used in deep
% learning applications. In transfer learning, a network trained on a large
% collection of images, such as ImageNet [2], is used as the starting point
% to solve a new classification or detection task. The advantage of using
% this approach is that the pre-trained network has already learned a rich
% set of image features that are applicable to a wide range of images. This
% learning is transferable to the new task by fine-tuning the network. A
% network is fine-tuned by making small adjustments to the weights such
% that the feature representations learned for the original task are
% slightly adjusted to support the new task.
%
% The advantage of transfer learning is that the number of images required
% for training and the training time are reduced. To illustrate these
% advantages, this example trains a stop sign detector using the transfer
% learning workflow. First a CNN is pre-trained using the CIFAR-10 data
% set, which has 50,000 training images. Then this pre-trained CNN is
% fine-tuned for stop sign detection using just 41 training images.
% Without, pre-training the CNN, training the stop sign detector would
% require many more images.
%
% Note: This example requires Computer Vision System Toolbox(TM), Image
% Processing Toolbox(TM), Neural Network Toolbox(TM), and Statistics and
% Machine Learning Toolbox(TM).
%
% Using a CUDA-capable NVIDIA(TM) GPU with compute capability 3.0 or higher
% is highly recommended for running this example. Use of a GPU requires the
% Parallel Computing Toolbox(TM).

function deepLearningFrontBack2
    isGrayScale = true;
    doTraining = true;
    width = 64;
    height = 64;
    cnnLayersFile = 'deeplearningFrontBack2.mat';

    % load CIFAR-10 image data
    [trainingImages, trainingLabels, testImages, testLabels, numImageCategories] = initCIFAR10Images(isGrayScale, width, height);

    if doTraining
        % load checkpoint file
        if exist(cnnLayersFile, 'file')
            load(cnnLayersFile);
            layers = netForFrontBack.Layers;
        else
            % Convolutional layer parameters
            filterSize = [5 5];
            numFilters = 48;
            numNeurons = 96;

            layers = constructNewCNNLayer(filterSize, numFilters, numNeurons, trainingImages, numImageCategories);
        end
        
        %% Train CNN Using CIFAR-10 Data
        % Now that the network architecture is defined, it can be trained using the
        % CIFAR-10 training data. First, set up the network training algorithm
        % using the |trainingOptions| function. The network training algorithm uses
        % Stochastic Gradient Descent with Momentum (SGDM) with an initial learning
        % rate of 0.001. During training, the initial learning rate is reduced
        % every 8 epochs (1 epoch is defined as one complete pass through the
        % entire training data set). The training algorithm is run for 40 epochs.
        %
        % Note that the training algorithm uses a mini-batch size of 128 images. If
        % using a GPU for training, this size may need to be lowered due to memory
        % constraints on the GPU.

        % Set the network training options
        opts = trainingOptions('sgdm', ...
            'Momentum', 0.9, ...
            'InitialLearnRate', 0.001, ...
            'LearnRateSchedule', 'piecewise', ...
            'LearnRateDropFactor', 0.1, ...
            'LearnRateDropPeriod', 8, ...
            'L2Regularization', 0.004, ...
            'MaxEpochs', 10, ...
            'MiniBatchSize', 128, ...
            'Verbose', true); 
        %    'CheckpointPath','.', ...

        %%
        % Train the network using the |trainNetwork| function. This is a
        % computationally intensive process that takes 20-30 minutes to complete.
        % To save time while running this example, a pre-trained network is loaded
        % from disk. If you wish to train the network yourself, set the
        % |doTraining| variable shown below to true.
        %
        % Note that a CUDA-capable NVIDIA(TM) GPU with compute capability 3.0 or
        % higher is highly recommeded for training.

        % A trained network is loaded from disk to save time when running the
        % example. Set this flag to true to train the network.
        netForFrontBack = trainNetwork(trainingImages, trainingLabels, layers, opts);
    else
        % Load pre-trained detector for the example.
        load(cnnLayersFile);
    end
    validateCNNLayer(netForFrontBack, testImages, testLabels);

    % training fly front back 
    trainingFlyFrontBack(isGrayScale, width, height, netForFrontBack);

    %% References
    % [1] Girshick, Ross, et al. "Rich feature hierarchies for accurate object
    % detection and semantic segmentation." Proceedings of the IEEE conference
    % on computer vision and pattern recognition. 2014.
    %
    % [2] Deng, Jia, et al. "Imagenet: A large-scale hierarchical image
    % database." Computer Vision and Pattern Recognition, 2009. CVPR 2009. IEEE
    % Conference on. IEEE, 2009.
    %
    % [3] Krizhevsky, Alex, and Geoffrey Hinton. "Learning multiple layers of
    % features from tiny images." (2009).
    %
    % [4] http://code.google.com/p/cuda-convnet/

    displayEndOfDemoMessage(mfilename)
end

%% 
function [trainingImages, trainingLabels, testImages, testLabels, numImageCategories] = initCIFAR10Images(isGrayScale, width, height)
    %% Download CIFAR-10 Image Data
    % Download the CIFAR-10 data set [3]. This dataset contains 50,000 training
    % images that will be used to train a CNN.

    % Download CIFAR-10 data to a temporary directory
    cifar10Data = tempdir;

    url = 'https://www.cs.toronto.edu/~kriz/cifar-10-matlab.tar.gz';

    helperCIFAR10Data.download(url, cifar10Data);

    % Load the CIFAR-10 training and test data. 
    [trainingImages, trainingLabels, testImages, testLabels] = helperCIFAR10Data.load(cifar10Data);
    trainingImages = imresize(trainingImages, [width height]);
    testImages = imresize(testImages, [width height]);

    if isGrayScale
        imageNum = size(trainingImages,4);
        trainingGrayImages = uint8(zeros(width,height,1,imageNum));
        for i=1:imageNum
            img = rgb2gray(trainingImages(:,:,:,i));
            trainingGrayImages(:,:,1,i) = img(:,:);
        end
        trainingImages = trainingGrayImages;

        imageNum = size(testImages,4);
        testGrayImages = uint8(zeros(width,height,1,imageNum));
        for i=1:imageNum
            img = rgb2gray(testImages(:,:,:,i));
            testGrayImages(:,:,1,i) = img(:,:);
        end
        testImages = testGrayImages;
    end

    %%
    % Each image is a 32x32 RGB image and there are 50,000 training samples.
    size(trainingImages)

    %%
    % CIFAR-10 has 10 image categories. List the image categories:
    numImageCategories = 10;

    %%

    % Display a few of the training images, resizing them for display.
    figure
    thumbnails = trainingImages(:,:,:,1:100);
    montage(thumbnails)
end

%%
function layers = constructNewCNNLayer(filterSize, numFilters, numNeurons, trainingImages, numImageCategories)
    %% Create A Convolutional Neural Network (CNN)
    % A CNN is composed of a series of layers, where each layer defines a
    % specific computation. The Neural Network Toolbox(TM) provides
    % functionality to easily design a CNN layer-by-layer. In this example, the
    % following layers are used to create a CNN:
    %
    % * |imageInputLayer|      - Image input layer
    % * |convolutional2dLayer| - 2D convolution layer for Convolutional Neural Networks
    % * |reluLayer|            - Rectified linear unit (ReLU) layer
    % * |maxPooling2dLayer|    - Max pooling layer
    % * |fullyConnectedLayer|  - Fully connected layer
    % * |softmaxLayer|         - Softmax layer
    % * |classificationLayer|  - Classification output layer for a neural network
    %
    % The network defined here is similar to the one described in [4] and
    % starts with an |imageInputLayer|. The input layer defines the type and
    % size of data the CNN can process. In this example, the CNN is used to
    % process CIFAR-10 images, which are 32x32 RGB images:

    % Create the image input layer for 32x32x3 CIFAR-10 images
    [height, width, numChannels, ~] = size(trainingImages);

    imageSize = [height width numChannels];
    inputLayer = imageInputLayer(imageSize)

    %%
    % Next, define the middle layers of the network. The middle layers are made
    % up of repeated blocks of convolutional, ReLU (rectified linear units),
    % and pooling layers. These 3 layers form the core building blocks of
    % convolutional neural networks. The convolutional layers define sets of
    % filter weights, which are updated during network training. The ReLU layer
    % adds non-linearity to the network, which allow the network to approximate
    % non-linear functions that map image pixels to the semantic content of the
    % image. The pooling layers downsample data as it flows through the
    % network. In a network with lots of layers, pooling layers should be used
    % sparingly to avoid downsampling the data too early in the network.

    middleLayers = [
        % The first convolutional layer has a bank of 32 5x5x3 filters. A
        % symmetric padding of 2 pixels is added to ensure that image borders
        % are included in the processing. This is important to avoid
        % information at the borders being washed away too early in the
        % network.
        convolution2dLayer(filterSize, numFilters, 'Padding', 2)

        % Note that the third dimension of the filter can be omitted because it
        % is automatically deduced based on the connectivity of the network. In
        % this case because this layer follows the image layer, the third
        % dimension must be 3 to match the number of channels in the input
        % image.

        % Next add the ReLU layer:
        reluLayer()

        % Follow it with a max pooling layer that has a 3x3 spatial pooling area
        % and a stride of 2 pixels. This down-samples the data dimensions from
        % 32x32 to 15x15.
        maxPooling2dLayer(3, 'Stride', 2)

        % Repeat the 3 core layers to complete the middle of the network.
        convolution2dLayer(filterSize, numFilters, 'Padding', 2)
        reluLayer()
        maxPooling2dLayer(3, 'Stride',2)

        convolution2dLayer(filterSize, 2 * numFilters, 'Padding', 2)
        reluLayer()
        maxPooling2dLayer(3, 'Stride',2)
    ]

    %%
    % A deeper network may be created by repeating these 3 basic layers.
    % However, the number of pooling layers should be reduced to avoid
    % downsampling the data prematurely. Downsampling early in the network
    % discards image information that is useful for learning.
    % 
    % The final layers of a CNN are typically composed of fully connected
    % layers and a softmax loss layer. 

    finalLayers = [
        % Add a fully connected layer with 64 output neurons. The output size of
        % this layer will be an array with a length of 64.
        fullyConnectedLayer(numNeurons)

        % Add an ReLU non-linearity.
        reluLayer

        % Add the last fully connected layer. At this point, the network must
        % produce 10 signals that can be used to measure whether the input image
        % belongs to one category or another. This measurement is made using the
        % subsequent loss layers.
        fullyConnectedLayer(numImageCategories)

        % Add the softmax loss layer and classification layer. The final layers use
        % the output of the fully connected layer to compute the categorical
        % probability distribution over the image classes. During the training
        % process, all the network weights are tuned to minimize the loss over this
        % categorical distribution.
        softmaxLayer
        classificationLayer
    ]

    %%
    % Combine the input, middle, and final layers.
    layers = [
        inputLayer
        middleLayers
        finalLayers
        ]

    %%
    % Initialize the first convolutional layer weights using normally
    % distributed random numbers with standard deviation of 0.0001. This helps
    % improve the convergence of training.

    layers(2).Weights = 0.0001 * randn([filterSize numChannels numFilters]);
end

%%
function validateCNNLayer(layers, testImages, testLabels)
    %% Validate CIFAR-10 Network Training
    % After the network is trained, it should be validated to ensure that
    % training was successful. First, a quick visualization of the first
    % convolutional layer's filter weights can help identify any immediate
    % issues with training. 

    % Extract the first convolutional layer weights
    w = layers.Layers(2).Weights;

    % rescale and resize the weights for better visualization
    [height, width, ~] = size(testImages);
    w = mat2gray(w);
    w = imresize(w, [width height]);

    figure
    montage(w)

    %%
    % The first layer weights should have some well defined structure. If the
    % weights still look random, then that is an indication that the network
    % may require additional training. In this case, as shown above, the first
    % layer filters have learned edge-like features from the CIFAR-10 training
    % data.
    %
    % To completely validate the training results, use the CIFAR-10 test data
    % to measure the classification accuracy of the network. A low accuracy
    % score indicates additional training or additional training data is
    % required. The goal of this example is not necessarily to achieve 100%
    % accuracy on the test set, but to sufficiently train a network for use in
    % training an object detector.

    % Run the network on the test set.
    YTest = classify(layers, testImages);

    % Calculate the accuracy.
    accuracy = sum(YTest == testLabels)/numel(testLabels)
end

%%
function trainingFlyFrontBack(isGrayScale, width, height, netForFrontBack)
    outputFolder = fullfile(tempdir, 'caltech101'); % define output folder
    rootFolder = fullfile(outputFolder, '101_ObjectCategories');
    categories = {'fly_back', 'fly_front'};

    %%
    % Create an |ImageDatastore| to help you manage the data. Because
    % |ImageDatastore| operates on image file locations, images are not loaded
    % into memory until read, making it efficient for use with large image
    % collections.
    imds = imageDatastore(fullfile(rootFolder, categories), 'LabelSource', 'foldernames');

    %%
    % The |imds| variable now contains the images and the category labels
    % associated with each image. The labels are automatically assigned from
    % the folder names of the image files. Use |countEachLabel| to summarize
    % the number of images per category.
    tbl = countEachLabel(imds)
    %%
    % Because |imds| above contains an unequal number of images per category,
    % let's first adjust it, so that the number of images in the training set
    % is balanced.

    minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category

    % Use splitEachLabel method to trim the set.
    imds = splitEachLabel(imds, minSetCount, 'randomize');

    % Notice that each set now has exactly the same number of images.
    countEachLabel(imds)

    %%
    % Below, you can see example images from three of the categories included
    % in the dataset.

    % Find the first instance of an image for each category
    fly_back = find(imds.Labels == 'fly_back', 1);
    fly_front = find(imds.Labels == 'fly_front', 1);

    figure
    subplot(3,3,1);
    imshow(readimage(imds,fly_back))
    subplot(3,3,2);
    imshow(readimage(imds,fly_front))

    % Set the ImageDatastore ReadFcn
    imds.ReadFcn = @(filename)readAndPreprocessImage(filename);

    %%
    % Note that other CNN models will have different input size constraints,
    % and may require other pre-processing steps.
    function Iout = readAndPreprocessImage(filename)
                
        I = imread(filename);
        
        % Some images may be grayscale. Replicate the image 3 times to
        % create an RGB image. 
        if ismatrix(I) && ~isGrayScale
            I = cat(3,I,I,I);
        end
        % Resize the image as required for the CNN. 
        Iout = imresize(I, [width, height]);  
        
        % Note that the aspect ratio is not preserved. In Caltech 101, the
        % object of interest is centered in the image and occupies a
        % majority of the image scene. Therefore, preserving the aspect
        % ratio is not critical. However, for other data sets, it may prove
        % beneficial to preserve the aspect ratio of the original image
        % when resizing.
    end

    %[trainingSet, testSet] = splitEachLabel(imds, 0.7, 'randomize');
    trainingSet = imds;
    testSet = imds;

    layerNumber = 11;
    trainingFeatures = activations(netForFrontBack, trainingSet, layerNumber, ...
        'MiniBatchSize', 32, 'OutputAs', 'columns');

    %% 
    % Note that the activations function automatically uses a GPU for
    % processing if one is available, otherwise, a CPU is used. Because of the
    % number of layers in AlexNet, using a GPU is highly recommended. Using a
    % the CPU to run the network will greatly increase the time it takes to
    % extract features.
    %
    % In the code above, the 'MiniBatchSize' is set 32 to ensure that the CNN
    % and image data fit into GPU memory. You may need to lower the
    % 'MiniBatchSize' if your GPU runs out of memory. Also, the activations
    % output is arranged as columns. This helps speed-up the multiclass linear
    % SVM training that follows.

    %% Train A Multiclass SVM Classifier Using CNN Features
    % Next, use the CNN image features to train a multiclass SVM classifier. A
    % fast Stochastic Gradient Descent solver is used for training by setting
    % the |fitcecoc| function's 'Learners' parameter to 'Linear'. This helps
    % speed-up the training when working with high-dimensional CNN feature
    % vectors, which each have a length of 4096.

    % Get training labels from the trainingSet
    trainingLabels = trainingSet.Labels;

    % Train multiclass SVM classifier using a fast linear solver, and set
    % 'ObservationsIn' to 'columns' to match the arrangement used for training
    % features.
    classifierFrontBack = fitcecoc(trainingFeatures, trainingLabels, ...
        'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');

    %% Evaluate Classifier
    % Repeat the procedure used earlier to extract image features from
    % |testSet|. The test features can then be passed to the classifier to
    % measure the accuracy of the trained classifier.

    % Extract test features using the CNN
    testFeatures = activations(netForFrontBack, testSet, layerNumber, 'MiniBatchSize',32);

    % Pass CNN image features to trained classifier
    predictedLabels = predict(classifierFrontBack, testFeatures);

    % Get the known labels
    testLabels = testSet.Labels;

    % Tabulate the results using a confusion matrix.
    confMat = confusionmat(testLabels, predictedLabels);

    % Convert confusion matrix into percentage form
    confMat = bsxfun(@rdivide,confMat,sum(confMat,2))
    %%

    % Display the mean accuracy
    mean(diag(confMat))

    %% Try the Newly Trained Classifier on Test Images
    % You can now apply the newly trained classifier to categorize new images.
    newImage = fullfile(rootFolder, 'fly_question', '00004_01.png');
    figure;
    imshow(newImage);

    % Pre-process the images as required for the CNN
    img = readAndPreprocessImage(newImage);

    % Extract image features using the CNN
    imageFeatures = activations(netForFrontBack, img, layerNumber);
    %%

    % Make a prediction using the classifier
    label = predict(classifierFrontBack, imageFeatures)

    save('./deeplearningFrontBack2.mat', 'classifierFrontBack', 'netForFrontBack');
end
