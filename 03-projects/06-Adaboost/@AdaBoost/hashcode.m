function C = hashcode(obj,points)
%HASHCODE �������ݵ��hash��
%   ���룺
%   points�����ݵ�
%
%   �����
%   c��hash��
    
    N = length(points);
    M = length(obj.alfa);
    C = zeros(M,N);
    
    for m = 1:M
        C(m,:) = obj.hypothesis{m}.predict(points);
    end
    
    C = C>0;
end

