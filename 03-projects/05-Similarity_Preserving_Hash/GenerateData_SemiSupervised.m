function [data, similar_pairs] = GenerateData_SemiSupervised(N)
%GENERATEDATA 产生一些测试数据
%   
    data = floor(256 * rand(2,N));
    similar_pairs  = [];
    
    for i = 1:N
        for j = (i+1):N
            if data(2,i) < 100 && data(2,j) < 100
                similar_pairs = [similar_pairs [i,j]'];
            elseif data(2,i) >= 100 && data(2,j) >= 100
                similar_pairs = [similar_pairs [i,j]'];
            end
        end
    end
end

