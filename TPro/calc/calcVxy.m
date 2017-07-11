function vxy = calcVxy(vy, vx)
    endLow = size(vy,1);
    vxy = zeros(size(vy,1), size(vy,2));
    for i = 1:endLow
        vxy(i,:) = sqrt( vy(i,:).^2 +  vx(i,:).^2  );
    end
end
