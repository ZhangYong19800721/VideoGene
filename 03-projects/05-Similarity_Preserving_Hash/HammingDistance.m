function d = HammingDistance( point1, point2 )
%HAMMINGDISTANCE 计算两个点point1和point2之间的汉明距离
%   
    d = sum(abs(point1 - point2));
end

