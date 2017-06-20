function [T,TP,FP] = ThresholdRate_SemiSupervised(data, similar_pairs, f, w, s)
%THRESHOLDRATE 论文“Learning Task-Specific Similarity”（2005年）中3.2节Algorithm 6
%  data: 数据集，数据集中包含数据点
%  similar_pairs: 相似的数据对，【2xNp】2行Np列，每一列表示一对相似数据对的下标，对应data中的下标。
%  f：映射函数，将数据点x映射到一个实数标量
%  w：权值向量，相似数据对的权值
%  s：权值向量，数据点的权值
%  T：输出的Threshold值，是一个向量，包括了所有可能的Threshold值
%  TP：对应T条件下的True Positive值，表示实际为正例，并且被判定为正例的概率
%  FP：对应T条件下的False Positive值，表示实际为反例，但是被判定为正例的概率

    [~,N] = size(data); % 数据集中共有N个数据点
    v = zeros(1,N);   % 数据集中的每一个数据映射为一个标量值，存储在v中
    
    parfor n=1:N 
        v(n) = f(data(:,n)); 
    end

    u = unique(v); % 去除v中的重复数据
    u = sort(u); % 排序
    delta = (u(2:length(u)) - u(1:(length(u)-1))) / 2;
    T = u(1:length(delta)) + delta;
    T = [u(1) - delta(1),T,u(length(u)) + delta(length(delta))]; % 计算得到所有可能的Threshold
    TP = zeros(size(T));
    FP = zeros(size(T));
    PI = zeros(size(T));
    
    [~,Np] = size(similar_pairs);
    vp = zeros(1,2*Np);
    dp = zeros(1,2*Np);
    wp = zeros(1,2*Np);
    
    for i = 1:Np
        idx_1 = similar_pairs(1,i); x1 = data(:,idx_1); v1 = f(x1);
        idx_2 = similar_pairs(2,i); x2 = data(:,idx_2); v2 = f(x2);
        
        vp(i +  0) = v1;
        vp(i + Np) = v2;
        
        if v1 <= v2, d1 = +1; else d1 = -1; end
        if v1 >  v2, d2 = +1; else d2 = -1; end
        
        dp(i +  0) = d1;
        dp(i + Np) = d2;
        
        wp(i +  0) = w(i);
        wp(i + Np) = w(i);
    end
    
    [svp,idx] = sort(vp); sdp = dp(idx); swp = wp(idx); % 排序
    
    for j = 1:length(T)
        idx_tp = svp <= T(j);
        TP(j) = 1 - swp(idx_tp) * sdp(idx_tp)';
        PI(j) = sum(s(v <= T(j)));    
    end
    
    FP = PI.^2 + (1 - PI).^2;
end
