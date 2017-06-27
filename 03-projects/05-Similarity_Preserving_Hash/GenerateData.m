function [points,similar] = GenerateData(N)
%GENERATEDATA 产生训练数据
%   在第2个维度上，距离越小越相似，小于10时相似，否则不相似

%     points = []; similar = [];
%     r = 20; alfa = linspace(0,2*pi,N);
%     x = r * cos(alfa); y = r * sin(alfa);
%     points = [x;y];
%     
%     r = 40;
%     x = r * cos(alfa); y = r * sin(alfa);
%     points = [points [x;y]];
%     
%     for i = 1:(2*N)
%         for j = (i+1):(2*N)
%             if norm(points(:,i),2) < 30 && norm(points(:,j),2) < 30
%                 similar = [similar [i j +1]'];
%             elseif norm(points(:,i),2) >= 30 && norm(points(:,j),2) >= 30
%                 similar = [similar [i j +1]'];
%             else
%                 similar = [similar [i j -1]'];
%             end
%         end
%     end
    
    points = floor(200 * rand(2,N));
    points = points - repmat([100 100]',1,N);
    similar = [];
    N = length(points);
    for i = 1:N
        for j = (i+1):N
            if abs(norm(points(:,i),2) - norm(points(:,j),2)) < 20
                similar = [similar [i j +1]'];
            else
                similar = [similar [i j -1]'];
            end
        end
    end
end

