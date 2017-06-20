function [T,TP,FP] = ThresholdRate(data, f, w)
%THRESHOLDRATE ���ġ�Learning Task-Specific Similarity����2005�꣩��3.2��Algorithm 4 
%  data: ���ݼ������ݼ��а�����������data.x1��ʾ��1�����ݵ㣬data.x2��ʾ��2�����ݵ㣬data.similar��ʾ�Ƿ����Ƶı�ǩ��+1��ʾ���ƣ�-1��ʾ������
%  f��ӳ�亯���������ݵ�xӳ�䵽һ��ʵ������
%  w��Ȩֵ��������Ӧÿһ�����ݶԵ�Ȩֵ
%  T�������Thresholdֵ����һ�����������������п��ܵ�Thresholdֵ
%  TP����ӦT�����µ�True Positiveֵ����ʾʵ��Ϊ���������ұ��ж�Ϊ�����ĸ���
%  FP����ӦT�����µ�False Positiveֵ����ʾʵ��Ϊ���������Ǳ��ж�Ϊ�����ĸ���

    N = length(data.similar); % ���ݼ��й���N�����ݶԣ�ÿ�����ݶ���x1��x2��lable����ֵ
    v = zeros(1,2*N);   % ���ݼ��е�ÿһ������ӳ��Ϊһ������ֵ���洢��v��
    d = zeros(1,2*N);   % ��ʾ��С����
    q = zeros(1,2*N);   % Ȩֵ
    similar = zeros(1,2*N);   % ��ǩ
    
    for n=1:N
        v(n+0) = f(data.x1(:,n));
        v(n+N) = f(data.x2(:,n));
        if v(n+0) <= v(n+N), d1 = +1; else d1 = -1; end
        if v(n+0) >  v(n+N), d2 = +1; else d2 = -1; end
        d(n+0) = d1; q(n+0) = w(n); similar(n+0) = data.similar(n);
        d(n+N) = d2; q(n+N) = w(n); similar(n+N) = data.similar(n);
    end
    
    [sv,idx] = sort(v); sd = d(idx); sw = q(idx); ssimilar = similar(idx); % ����
    sw(ssimilar==+1) = sw(ssimilar==+1) / sum(sw(ssimilar==+1)); % Ȩֵ��һ��
    sw(ssimilar==-1) = sw(ssimilar==-1) / sum(sw(ssimilar==-1)); % Ȩֵ��һ��
    
    u = unique(v); % ȥ��v�е��ظ�����
    u = sort(u); % ����
    delta = (u(2:length(u)) - u(1:(length(u)-1))) / 2;
    T = u(1:length(delta)) + delta;
    T = [u(1) - delta(1),T,u(length(u)) + delta(length(delta))]; % ����õ����п��ܵ�Threshold
    
    for j = 1:length(T)
        idx_tp = (sv <= T(j) & ssimilar == +1);
        idx_fp = (sv <= T(j) & ssimilar == -1);
        TP(j) = 1 - sw(idx_tp) * sd(idx_tp)';
        FP(j) = 1 - sw(idx_fp) * sd(idx_fp)';
    end
end
