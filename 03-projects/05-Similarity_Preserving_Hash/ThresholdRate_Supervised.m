function [Threshold,TruePositive,FalsePositive] = ThresholdRate_Supervised(data, project_func, weight)
%THRESHOLDRATE 论文“Learning Task-Specific Similarity”（2005年）中3.2节Algorithm 4 
%  data: 数据集，数据集中包含数据点data.points和标签序列data.similar【3xNp】3行Np列，每一列包含一对下标和指示其是否相似的标签+1表示相似，-1表示不相似
%  project_func：映射函数，将数据点x映射到一个实数标量
%  weight：权值向量，对应每一个数据对的权值

%  Threshold：输出的Threshold值，是一个向量，包括了所有可能的Threshold值
%  TruePositive：对应T条件下的True Positive值，表示实际为正例，并且被判定为正例的概率
%  FalsePositive：对应T条件下的False Positive值，表示实际为反例，但是被判定为正例的概率

    [~,N] = size(data.similar);                                             % 数据集中共有N个数据对
    v = zeros(1,2*N); d = zeros(1,2*N); w = zeros(1,2*N); s = zeros(1,2*N); % 初始化4个值，分别表示映射值，方向，权值，标签
    
    v(   1 :   N ) = project_func(data.points(:,data.similar(1,:)));
    v((N+1):(N+N)) = project_func(data.points(:,data.similar(2,:)));
    
    d(   1 :   N ) = (v(1:N) <= v((N+1):(N+N)));
    d((N+1):(N+N)) = (v(1:N) >  v((N+1):(N+N)));
    d(d ~= 1) = -1;
    
    w(   1 :   N ) = weight;
    w((N+1):(N+N)) = weight;
    
    s(   1 :   N ) = data.similar(3,:);
    s((N+1):(N+N)) = data.similar(3,:);

    do_similar_idx = (s>0); un_similar_idx = (s<0); 
    w(do_similar_idx) = 2 * w(do_similar_idx) ./ sum(w(do_similar_idx)); % 正例权值归一化
    w(un_similar_idx) = 2 * w(un_similar_idx) ./ sum(w(un_similar_idx)); % 反例权值归一化
    
    u = unique(v); u = sort(u); Nu = length(u); %去除v中的重复数据,排序
    delta = (u(2:Nu) - u(1:(Nu-1))) / 2; Nd = length(delta);
    Threshold = u(1:Nd) + delta;
    Threshold = [u(1) - delta(1),Threshold,u(Nu) + delta(Nd)]; % 计算得到所有可能的Threshold
    TruePositive = zeros(size(Threshold));
    FalsePositive = zeros(size(Threshold));
    
    Nt = length(Threshold);
    for j = 1:Nt
        idx_tp = (v <= Threshold(j) & do_similar_idx);
        idx_fp = (v <= Threshold(j) & un_similar_idx);
        TruePositive(j)  = 1 - w(idx_tp) * d(idx_tp)';
        FalsePositive(j) = 1 - w(idx_fp) * d(idx_fp)';
    end
end
