function [points,similar] = GenerateData(N)
%GENERATEDATA ����ѵ������
%   �ڵ�2��ά���ϣ�����ԽСԽ���ƣ�С��10ʱ���ƣ���������

%     points1 = rand(2,N); % �������еĵ�
%     points1(1,:) =    floor(45 * points1(1,:)); points1(2,:) = floor(100 * points1(2,:));
%     points2 = rand(2,N);
%     points2(1,:) = 55+floor(45 * points2(1,:)); points2(2,:) = floor(100 * points2(2,:));
%     
%     figure(1);
%     plot(points1(1,:),points1(2,:),'go'); hold on;
%     plot(points2(1,:),points2(2,:),'go'); hold off;
%     
%     points = [points1 points2];
    points = floor(100 * rand(2,N));
    similar = [];
    N = length(points);
    for i = 1:N
        for j = (i+1):N
            if abs(points(2,i) - points(2,j)) < 30
                similar = [similar [i j +1]'];
            else
                similar = [similar [i j -1]'];
            end
        end
    end
end

