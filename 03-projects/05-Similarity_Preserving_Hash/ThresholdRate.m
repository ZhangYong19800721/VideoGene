function [T,TP,FP] = ThresholdRate(data, f, w)
%THRESHOLDRATE ���ġ�Learning Task-Specific Similarity����2005�꣩��3.2��Algorithm 4 
%  data: ���ݼ������ݼ��а�����������data.x1��ʾ��1�����ݵ㣬data.x2��ʾ��2�����ݵ㣬data.l��ʾ�Ƿ����Ƶı�ǩ��+1��ʾ���ƣ�-1��ʾ������
%  f��ӳ�亯���������ݵ�xӳ�䵽һ��ʵ������
%  w��Ȩֵ��������Ӧÿһ�����ݶԵ�Ȩֵ
%  T�������Thresholdֵ����һ�����������������п��ܵ�Thresholdֵ
%  TP����ӦT�����µ�True Positiveֵ����ʾʵ��Ϊ���������ұ��ж�Ϊ�����ĸ���
%  FP����ӦT�����µ�False Positiveֵ����ʾʵ��Ϊ���������Ǳ��ж�Ϊ�����ĸ���

    N = length(data.l); % ���ݼ��й���N�����ݶԣ�ÿ�����ݶ���x1��x2��lable����ֵ
    v = zeros(1,2*N);   % ���ݼ��е�ÿһ������ӳ��Ϊһ������ֵ���洢��v��
    d = zeros(1,2*N);   % ��ʾ��С����
    q = zeros(1,2*N);   % Ȩֵ
    l = zeros(1,2*N);   % ��ǩ
    
    for n=1:N
        v(n+0) = f(data.x1(:,n));
        v(n+N) = f(data.x2(:,n));
        if v(n+0) <= v(n+N) d1 = +1; else d1 = -1; end
        if v(n+0) >  v(n+N) d2 = +1; else d2 = -1; end
        d(n+0) = d1; q(n+0) = w(n); l(n+0) = data.l(n);
        d(n+N) = d2; q(n+N) = w(n); l(n+N) = data.l(n);
    end
    
    [sv,idx] = sort(v); sd = d(idx); sw = q(idx); sl = l(idx); % ����
    sw(sl==+1) = sw(sl==+1) / sum(sw(sl==+1)); % Ȩֵ��һ��
    sw(sl==-1) = sw(sl==-1) / sum(sw(sl==-1)); % Ȩֵ��һ��
    
    u = unique(v); % ȥ���ظ�����
    u = sort(u); % ����
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
