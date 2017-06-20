function [data, similar_pairs] = GenerateData_SemiSupervised(N)
%GENERATEDATA 产生一些测试数据
%   
    data = floor(256 * rand(2,N));
    similar_pairs  = [];
    
    for i = 1:N
        for j = (i+1):N
            if abs(norm(data(:,i)) - norm(data(:,j))) <= 10
                similar_pairs = [similar_pairs [i,j]'];
            end
        end
    end
end

