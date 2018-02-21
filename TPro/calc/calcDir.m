function dir = calcDir(dy, dx) 
    endLow = size(dy,1);
    dir = zeros(size(dy,1), size(dy,2));
    for i = 1:endLow
        v1 = [dy(i, :); (-1).*dx(i, :)];
        check_v1 = sum(v1.*v1);
        v1(:,check_v1==0) = NaN;
        dir(i,:) = atan2d(v1(2,:),v1(1,:));
    end
    dir = single(mod(dir + 360, 360));
end
