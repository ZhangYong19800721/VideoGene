function [Threshold,TruePositive,FalsePositive,v,PI] = ThresholdRate_SemiSupervised(data, project_func, weight_similar, weight_data)
%THRESHOLDRATE ���ġ�Learning Task-Specific Similarity����2005�꣩��3.2��Algorithm 6
%  data: ���ݼ������ݼ��а������ݵ�data.points����������data.similar��2xNp��2��Np�У�ÿһ�б�ʾһ���������ݶԵ��±꣬��Ӧdata.points�е��±�
%  function_handle��ӳ�亯���������ݵ�xӳ�䵽һ��ʵ������
%  weight_similar��Ȩֵ�������������ݶԵ�Ȩֵ
%  weight_data��Ȩֵ���������ݵ��Ȩֵ

%  Threshold�������Thresholdֵ����һ�����������������п��ܵ�Thresholdֵ
%  TruePositive����ӦThreshold�����µ�True Positiveֵ����ʾʵ��Ϊ���������ұ��ж�Ϊ�����ĸ���
%  FalsePositive����ӦThreshold�����µ�False Positiveֵ����ʾʵ��Ϊ���������Ǳ��ж�Ϊ�����ĸ���
    
    v = project_func(data.points); % ���ݼ��е�ÿһ������ӳ��Ϊһ������ֵ���洢��v�С�

    u = unique(v); u = sort(u); Nu = length(u); % ȥ��v�е��ظ����ݣ�����
    delta = (u(2:Nu) - u(1:(Nu-1))) / 2; Nd = length(delta); 
    Threshold = u(1:Nd) + delta; Threshold = [u(1)-delta(1),Threshold,u(Nu) + delta(Nd)]; % ����õ����п��ܵ�Threshold
    TruePositive = zeros(size(Threshold)); PI = zeros(size(Threshold)); % ��ʼ������ֵ
    
    [~,Np] = size(data.similar); % ���������ĸ���
    vp = zeros(1,2*Np); dp = zeros(1,2*Np); wp = zeros(1,2*Np); % ��ʼ��vp��dp��wp
    
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
