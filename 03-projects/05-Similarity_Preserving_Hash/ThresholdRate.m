function [T,TP,FP] = ThresholdRate(data, f, w)
%THRESHOLDRATE 论文“Learning Task-Specific Similarity”（2005年）中3.2节Algorithm 4 
%  data: 数据集，数据集中包含三个部分data.x1表示第1个数据点，data.x2表示第2个数据点，data.l表示是否相似的标签，+1表示相似，-1表示不相似
%  f：映射函数，将数据点x映射到一个实数标量
%  w：权值向量，对应每一个数据对的权值
%  T：输出的Threshold值，是一个向量，包括了所有可能的Threshold值
%  TP：对应T条件下的True Positive值，表示实际为正例，并且被判定为正例的概率
%  FP：对应T条件下的False Positive值，表示实际为反例，但是被判定为正例的概率

    N = length(data.l); % 数据集中共有N个数据对，每个数据对有x1，x2，lable三个值
    v = zeros(1,2*N);   % 数据集中的每一个数据映射为一个标量值，存储在v中
    d = zeros(1,2*N);   % 表示大小方向
    q = zeros(1,2*N);   % 权值
    l = zeros(1,2*N);   % 标签
    
    for n=1:N
        v(n+0) = f(data.x1(:,n));
        v(n+N) = f(data.x2(:,n));
        if v(n+0) <= v(n+N) d1 = +1; else d1 = -1; end
        if v(n+0) >  v(n+N) d2 = +1; else d2 = -1; end
        d(n+0) = d1; q(n+0) = w(n); l(n+0) = data.l(n);
        d(n+N) = d2; q(n+N) = w(n); l(n+N) = data.l(n);
    end
    
    [sv,idx] = sort(v); sd = d(idx); sw = q(idx); sl = l(idx); % 排序
    sw(sl==+1) = sw(sl==+1) / sum(sw(sl==+1)); % 权值归一化
    sw(sl==-1) = sw(sl==-1) / sum(sw(sl==-1)); % 权值归一化
    
    u = unique(v); % 去除重复数据
    u = sort(u); % 排序
    delta = (u(2:length(u)) - u(1:(length(u)-1))) / 2;
    T = u(1:length(delta)) + delta;
    T = [u(1) - delta(1),T];
    
    for j = 1:length(T)
        idx_tp = (sv <= T(j) & sl == +1);
        idx_fp = (sv <= T(j) & sl == -1);
        TP(j) = 1 - sw(idx_tp) * sd(idx_tp)';
        FP(j) = 1 - sw(idx_fp) * sd(idx_fp)';
    end
end
