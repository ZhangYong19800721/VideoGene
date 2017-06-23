function C = hashcode(obj,points)
%HASHCODE 计算数据点的hash码
%   输入：
%   points：数据点
%
%   输出：
%   c：hash码
    
    N = length(points);
    M = length(obj.alfa);
    C = zeros(M,N);
    
    for m = 1:M
        C(m,:) = obj.hypothesis{m}.predict(points);
    end
    
    C = C>0;
end

