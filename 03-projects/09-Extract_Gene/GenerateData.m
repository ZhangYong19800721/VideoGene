function [points,similar] = GenerateData(N)
%GENERATEDATA ����ѵ������
%   �ڵ�2��ά���ϣ�����ԽСԽ���ƣ�С��10ʱ���ƣ���������

    points = floor(100 * rand(2,N));
    %points = points - repmat([100 100]',1,N);
    similar = [];
    N = length(points);
    for i = 1:N
        for j = (i+1):N
            if abs(points(2,i) - points(2,j)) < 10
                similar = [similar [i j +1]'];
            else
                similar = [similar [i j -1]'];
            end
        end
    end
end
