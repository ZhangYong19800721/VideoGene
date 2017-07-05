function [Threshold,TruePositive,FalsePositive] = ThresholdRate_Supervised(data, project_func, weight)
%THRESHOLDRATE ���ġ�Learning Task-Specific Similarity����2005�꣩��3.2��Algorithm 4 
%  data: ���ݼ������ݼ��а������ݵ�data.points�ͱ�ǩ����data.similar��3xNp��3��Np�У�ÿһ�а���һ���±��ָʾ���Ƿ����Ƶı�ǩ+1��ʾ���ƣ�-1��ʾ������
%  project_func��ӳ�亯���������ݵ�xӳ�䵽һ��ʵ������
%  weight��Ȩֵ��������Ӧÿһ�����ݶԵ�Ȩֵ

%  Threshold�������Thresholdֵ����һ�����������������п��ܵ�Thresholdֵ
%  TruePositive����ӦT�����µ�True Positiveֵ����ʾʵ��Ϊ���������ұ��ж�Ϊ�����ĸ���
%  FalsePositive����ӦT�����µ�False Positiveֵ����ʾʵ��Ϊ���������Ǳ��ж�Ϊ�����ĸ���

    [~,N] = size(data.similar);                                             % ���ݼ��й���N�����ݶ�
    v = zeros(1,2*N); d = zeros(1,2*N); w = zeros(1,2*N); s = zeros(1,2*N); % ��ʼ��4��ֵ���ֱ��ʾӳ��ֵ������Ȩֵ����ǩ
    
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
    w(do_similar_idx) = 2 * w(do_similar_idx) ./ sum(w(do_similar_idx)); % ����Ȩֵ��һ��
    w(un_similar_idx) = 2 * w(un_similar_idx) ./ sum(w(un_similar_idx)); % ����Ȩֵ��һ��
    
    u = unique(v); u = sort(u); Nu = length(u); %ȥ��v�е��ظ�����,����
    delta = (u(2:Nu) - u(1:(Nu-1))) / 2; Nd = length(delta);
    Threshold = u(1:Nd) + delta;
    Threshold = [u(1) - delta(1),Threshold,u(Nu) + delta(Nd)]; % ����õ����п��ܵ�Threshold
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
