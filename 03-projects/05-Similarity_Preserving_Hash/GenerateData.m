function [points,similar] = GenerateData(N)
%GENERATEDATA 产生训练数据
%   
    points = floor(200 * rand(2,N));
    points = points - repmat([100 100]',1,N);
    similar = [];
    N = length(points);
    for i = 1:N
        for j = (i+1):N
            if abs(norm(points(:,i),2) - norm(points(:,j),2)) < 10
                similar = [similar [i j +1]'];
            else
                similar = [similar [i j -1]'];
            end
        end
    end
end

