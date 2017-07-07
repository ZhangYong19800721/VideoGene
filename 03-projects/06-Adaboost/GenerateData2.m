function [points,labels] = GenerateData(N)
%GENERATEDATA 产生训练数据
%   
    points = 20 * rand(2,N) - repmat([10 10]',1,N);
    labels = ones(1,N);
    for i = 1:N
        if abs(points(1,i) - points(2,i)) > 2
            labels(i) = -1;
        end
    end
end

