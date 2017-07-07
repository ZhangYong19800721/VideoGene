function [points,similar] = GenerateDataL1(N)
%GENERATEDATA 产生训练数据
%   
    points = floor(200 * rand(2,N));
    points = points - repmat([100 100]',1,N);
    similar = [];
    N = length(points);
    for i = 1:N
        for j = (i+1):N
            if points(2,i) > 50 && points(2,j) > 50
                similar = [similar [i j +1]'];
            elseif points(2,i) > 0 && points(2,j) > 0 && points(2,i) <= 50 && points(2,j) <= 50
                similar = [similar [i j +1]'];
            elseif points(2,i) > -50 && points(2,j) > -50 && points(2,i) <= 0 && points(2,j) <= 0
                similar = [similar [i j +1]'];
            elseif points(2,i) > -100 && points(2,j) > -100 && points(2,i) <= -50 && points(2,j) <= -50
                similar = [similar [i j +1]'];
            else
                similar = [similar [i j -1]'];
            end
        end
    end
end

