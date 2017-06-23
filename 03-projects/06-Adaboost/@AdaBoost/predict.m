function y = predict(obj,points)
%PREDICT �ж��������Ƿ����ƣ�����Ϊ+1��������Ϊ-1
%   
    M = length(obj.alfa); % ���������ĸ���
    N = length(points);  % ���ݵ���
    C = zeros(M,N);
    for m=1:M
        C(m,:) = obj.hypothesis{m}.predict(points);
    end
    y = sign(obj.alfa * C);
    y(y<=0) = -1;
end

