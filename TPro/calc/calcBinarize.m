function matout = calcBinarize(mat, threshold)
    mat(mat <= threshold) = 0;
    mat(mat > threshold) = 1;    
    matout = mat;
end
