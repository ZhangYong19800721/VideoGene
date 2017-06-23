function y = predict(obj,points)
%PREDICT 判断两个点是否相似，相似为+1，不相似为-1
%   
    M = length(obj.alfa); % 弱分类器的个数
    N = length(points);  % 数据点数
    C = zeros(M,N);
    for m=1:M
        C(m,:) = obj.hypothesis{m}.predict(points);
    end
    y = sign(obj.alfa * C);
    y(y<=0) = -1;
end

