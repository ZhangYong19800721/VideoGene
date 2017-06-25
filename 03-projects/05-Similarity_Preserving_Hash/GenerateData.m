function [points,similar] = GenerateData(N)
%GENERATEDATA 产生训练数据
%   在第2个维度上，距离越小越相似，小于10时相似，否则不相似

    points = floor(200 * rand(2,N));
    points = points - repmat([100 100]',1,N);
    similar = [];
    N = length(points);
    for i = 1:N
        for j = (i+1):N
            if abs(norm(points(2,i),2) - norm(points(2,j),2)) < 20
                similar = [similar [i j +1]'];
            else
                similar = [similar [i j -1]'];
            end
        end
    end
end

