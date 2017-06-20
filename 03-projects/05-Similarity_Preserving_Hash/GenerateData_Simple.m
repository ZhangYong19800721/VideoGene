function [x1, x2, l] = GenerateData_Simple(N)
%GENERATEDATA 产生一些测试数据
%   
    x1 = floor(256 * rand(2,N));
    x2 = floor(256 * rand(2,N));
    l  = zeros(1,N);
    
    for n = 1:N
        if x1(2,n) >= 100 && x2(2,n) >= 100
            l(n) = 1;
        elseif x1(2,n) < 100 && x2(2,n) < 100
            l(n) = 1;
        else
            l(n) = -1;
        end
    end
end

