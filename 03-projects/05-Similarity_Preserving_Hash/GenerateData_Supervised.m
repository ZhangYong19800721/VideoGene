function [points, similar] = GenerateData_Supervised(N)
%GENERATEDATA 产生一些测试数据
%   
    points = floor(256 * rand(2,N));
    similar = [];
    
    for i = 1:N
        for j=(i+1):N
            if abs(points(2,i) - points(2,j)) <= 30
                similar = [similar [i j +1]'];
            else
                similar = [similar [i j -1]'];
            end
        end
    end
end

