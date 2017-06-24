function [points,labels] = GenerateData3(N)
%GENERATEDATA ����ѵ������
%   �ڵ�2��ά���ϣ�����ԽСԽ���ƣ�С��10ʱ���ƣ���������

    points = floor(100 * rand(2,N)); % �������еĵ�
    similar = [];
    for i = 1:N
        for j = (i+1):N
            if abs(points(2,i) - points(2,j)) < 10
                similar = [similar [i j +1]'];
            else
                similar = [similar [i j -1]'];
            end
        end
    end
    
    points = [points(:,similar(1,:));
              points(:,similar(2,:))];
    labels = similar(3,:);
end

