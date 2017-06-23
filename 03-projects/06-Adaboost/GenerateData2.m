function [points,labels] = GenerateData2(N)
%GENERATEDATA 产生训练数据
%   
    points = [];
    labels = [];
    while true
        p = floor(100 * rand(2,1));
        if sqrt(p(1).^2 + p(2).^2) < 50
            points = [points p];
            labels = [labels +1];
        end
        
        if sqrt(p(1).^2 + p(2).^2) > 60
            points = [points  p];
            labels = [labels -1];
        end
        
        if length(labels) >= N
            break;
        end
    end
end

