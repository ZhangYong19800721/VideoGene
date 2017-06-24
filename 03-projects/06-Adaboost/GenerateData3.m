function [points,labels] = GenerateData3(N)
%GENERATEDATA 产生训练数据
%   在第2个维度上，距离越小越相似，小于10时相似，否则不相似

    points = floor(100 * rand(2,N)); % 产生所有的点
    similar = [];
    for i = 1:N
        for j = (i+1):N
            if abs(points(2,i) - points(2,j)) < 10
                similar = [similar [i j +1]'];
            else
                similar = [similar [i j -1]'];
            end
        end
    end
    
    points = [points(:,similar(1,:));
              points(:,similar(2,:))];
    labels = similar(3,:);
end

