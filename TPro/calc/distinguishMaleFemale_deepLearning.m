%%
function [ labels ] = distinguishMaleFemale_deepLearning(glayImages, netForMaleFemale, classifierMaleFemale)
    labels = cell(length(glayImages),1);

    % find direction for every blobs
    for i = 1:length(glayImages)
        img = glayImages{i};

        % Extract image features using the CNN
        imageFeatures = activations(netForMaleFemale, img, 11);

        % Make a prediction using the classifier
        labels{i} = predict(classifierMaleFemale, imageFeatures);
    end
end
