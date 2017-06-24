function y = predict(obj,points1,points2)
%PREDICT �ж��������Ƿ����ƣ�����Ϊ+1��������Ϊ-1
%   
    M = length(obj.alfa); % ���������ĸ���
    N = length(points1);  % ���ݵ���
    C = zeros(M,N);       % ���������ķ�����
    
    for m=1:M
        C(m,:) = obj.hypothesis{m}.predict(points1,points2);
    end
    
    y = sign(obj.alfa * C);
    y(y<=0) = -1;
end

