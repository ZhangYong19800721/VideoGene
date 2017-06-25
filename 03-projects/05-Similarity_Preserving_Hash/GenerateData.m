function [points,similar] = GenerateData(N)
%GENERATEDATA ����ѵ������
%   �ڵ�2��ά���ϣ�����ԽСԽ���ƣ�С��10ʱ���ƣ���������

    points = floor(200 * rand(2,N));
    points = points - repmat([100 100]',1,N);
    similar = [];
    N = length(points);
    for i = 1:N
        for j = (i+1):N
            if abs(norm(points(2,i),2) - norm(points(2,j),2)) < 20
                similar = [similar [i j +1]'];
            else
                similar = [similar [i j -1]'];
            end
        end
    end
end

