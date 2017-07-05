function H = SSC(data, G)
%SSC 论文“Learning Task-Specific Similarity”（2005年）中3.2.1节Algorithm 5 
%   此处显示详细说明
    H = [];
    [~,N] = size(data.similar);       % 数据样本点的个数
    [D,~] = size(data.points(:,1));   % 数据的维度
    W = ones(1,N)/N;                  % 初始化权值
    for d = 1:D
        func = @(x)project_function(x,d);
        [T,TP,FP] = ThresholdRate_Supervised(data,func,W);
        idx = (TP-FP) >= G;
        H = [H;[d*ones(sum(idx),1) T(idx)']];
    end
end

