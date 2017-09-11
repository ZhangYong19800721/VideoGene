clear all
close all

load('nucleotides.mat');
[~,N] = size(nucleotide);

 %% ������
labels_neg = [];
for k = 1:15
    sequenc_idx = 1:N;
    shuffle_idx = randperm(N);
    labels_neg = [labels_neg [sequenc_idx; shuffle_idx; -ones(1,N)]];
end

 %% ȥ�����������ͬ����
idx = labels_neg(1,:) == labels_neg(2,:);
labels_neg = labels_neg(:,~idx);

 %% �Ӳ����Ƽ�����ȥ����֪���������ݶ�
load('labels_pos.mat');
labels_pos = labels; % �������Ʊ�ǩ���ݶ�

[~,U] = size(labels_neg);
[~,S] = size(labels_pos);

select = false(1,U);
for u = 1:U
    disp(sprintf('process:%f',u/U));
    i = labels_neg(1,u);
    j = labels_neg(2,u);
    
    idx1 = labels_pos(1,   :) == i | labels_pos(2,   :) == i;
    idx2 = labels_pos(1,idx1) == j | labels_pos(2,idx1) == j;
    if sum(idx2) == 0
        select(u) = true;
    end
end

labels_neg = labels_neg(:,select);
save('labels_neg.mat','labels_neg');





