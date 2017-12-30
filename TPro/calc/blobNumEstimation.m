%%
function [expectNums, useTmplMatch, minNums] = blobNumEstimation(origAreas, blobAvgSize, blobSeparateRate, maxBlobs, tmplSepNum, divRate)
    blob_num = size(origAreas,1);
    expectNums = zeros(1,blob_num);
    useTmplMatch = zeros(1,blob_num);
    expectNums = zeros(1,blob_num);
    minNums = zeros(1,blob_num);
    for i = 1 : blob_num
        % check blobAreas dimension of current blob and how bigger than avarage.
        area_ratio = single(origAreas(i))/single(blobAvgSize*divRate);
        if (mod(area_ratio,1) >= blobSeparateRate)
            expect_num = area_ratio + (1-mod(area_ratio,1));
        else
            expect_num = floor(area_ratio); % floor to the nearest integer
        end
        if expect_num < 1
            expect_num = 1;
        end
        if tmplSepNum > 0 && expect_num >= tmplSepNum
            useTmplMatch(i) = 1;
        end
        expectNums(i) = expect_num;
        if expect_num <= 2
            minNums(i) = expect_num;
        else
            minNums(i) = expect_num - 1 - floor((expect_num - 1) / 5);
        end
    end

    totalExpect = sum(expectNums);
    totalMinExpect = sum(minNums);
    blobCount = length(origAreas);

    % min expect num should be smaller than maxBlobs (input)
    if maxBlobs > 0 && totalMinExpect > maxBlobs
        if blobCount >= maxBlobs
            % bad threshold setting !!
            minNums(:) = 1;
        else
            k = 0;
            diff = totalMinExpect - maxBlobs;
            idx = find(minNums >= 2);
            totalm2area = sum(origAreas(idx));
            [B, idx] = sort(origAreas,'descend');
            B = single(B) ./ totalm2area;
            while totalMinExpect > maxBlobs 
                idxk = idx(k+1);
                minNums(idxk) = minNums(idxk) - ceil(B(k+1) * diff);
                k = mod(k+1, length(idx));
                totalMinExpect = sum(minNums);
            end
        end
    end
    %{
    if maxBlobs > 0 && maxBlobs > total
        % maxBlobs mode. total number is less than maxBlobs. so add a shortage
        k = 0;
        if tmplSepNum > 0
            idx = find(expectNums >= tmplSepNum);
        else
            idx = [];
        end
        if ~isempty(idx)
            for j = 1:(maxBlobs - total)
                expectNums(idx(k+1)) = expectNums(idx(k+1)) + 1;
                k = mod(k+1, length(idx));
            end
        elseif ~isempty(origAreas)
            [B, idx] = sort(origAreas,'descend');
            for j = 1:(maxBlobs - total)
                expectNums(idx(k+1)) = expectNums(idx(k+1)) + 1;
                useTmplMatch(idx(k+1)) = 1; % force to use template matching
                k = mod(k+1, length(idx));
            end
        end
    end
    %}
end
