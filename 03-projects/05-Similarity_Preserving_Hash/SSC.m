function H = SSC(data, G)
%SSC ���ġ�Learning Task-Specific Similarity����2005�꣩��3.2.1��Algorithm 5 
%   �˴���ʾ��ϸ˵��
    H = [];
    [~,N] = size(data.similar);       % ����������ĸ���
    [D,~] = size(data.points(:,1));   % ���ݵ�ά��
    W = ones(1,N)/N;                  % ��ʼ��Ȩֵ
    for d = 1:D
        func = @(x)project_function(x,d);
        [T,TP,FP] = ThresholdRate_Supervised(data,func,W);
        idx = (TP-FP) >= G;
        H = [H;[d*ones(sum(idx),1) T(idx)']];
    end
end

