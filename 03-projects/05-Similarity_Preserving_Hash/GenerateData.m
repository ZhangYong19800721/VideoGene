function [x1, x2, l] = GenerateData(N)
%GENERATEDATA ����һЩ��������
%   
    x1 = floor(256 * rand(2,N));
    x2 = floor(256 * rand(2,N));
    l  = zeros(1,N);
    
    for n = 1:N
        if abs(norm(x1(:,n)) - norm(x2(:,n))) <= 10
            l(n) = 1;
        else 
            l(n) = -1;
        end
    end
end

