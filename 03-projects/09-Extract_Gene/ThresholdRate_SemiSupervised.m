function [Threshold,TruePositive,FalsePositive,v,PI] = ThresholdRate_SemiSupervised(data, project_func, weight_similar, weight_data)
%THRESHOLDRATE 论文“Learning Task-Specific Similarity”（2005年）中3.2节Algorithm 6
%  data: 数据集，数据集中包含数据点data.points和相似序列data.similar【2xNp】2行Np列，每一列表示一对相似数据对的下标，对应data.points中的下标
%  function_handle：映射函数，将数据点x映射到一个实数标量
%  weight_similar：权值向量，相似数据对的权值
%  weight_data：权值向量，数据点的权值

%  Threshold：输出的Threshold值，是一个向量，包括了所有可能的Threshold值
%  TruePositive：对应Threshold条件下的True Positive值，表示实际为正例，并且被判定为正例的概率
%  FalsePositive：对应Threshold条件下的False Positive值，表示实际为反例，但是被判定为正例的概率
    
    v = project_func(data.points); % 数据集中的每一个数据映射为一个标量值，存储在v中。

    u = unique(v); u = sort(u); Nu = length(u); % 去除v中的重复数据，排序
    delta = (u(2:Nu) - u(1:(Nu-1))) / 2; Nd = length(delta); 
    Threshold = u(1:Nd) + delta; Threshold = [u(1)-delta(1),Threshold,u(Nu) + delta(Nd)]; % 计算得到所有可能的Threshold
    TruePositive = zeros(size(Threshold)); PI = zeros(size(Threshold)); % 初始化两个值
    
    [~,Np] = size(data.similar); % 相似正例的个数
    vp = zeros(1,2*Np); dp = zeros(1,2*Np); wp = zeros(1,2*Np); % 初始化vp，dp，wp
    
    vp(    1 :    Np ) = project_func(data.points(:,data.similar(1,:)));
    vp((Np+1):(Np+Np)) = project_func(data.points(:,data.similar(2,:)));
    
    dp(    1 :    Np ) = (vp(    1 :    Np ) <= vp((Np+1):(Np+Np)));
    dp((Np+1):(Np+Np)) = (vp(    1 :    Np ) >  vp((Np+1):(Np+Np)));
    dp(dp == 0) = -1;
    
    wp(    1 :    Np ) = weight_similar;
    wp((Np+1):(Np+Np)) = weight_similar;
    
    Nt = length(Threshold);
    for j = 1:Nt
        idx_tp = (vp <= Threshold(j));
        TruePositive(j) = 1 - wp(idx_tp) * dp(idx_tp)';
        PI(j) = sum(weight_data(v <= Threshold(j)));    
    end
    
    FalsePositive = PI.^2 + (1 - PI).^2;
end
