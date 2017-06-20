function [T,TP,FP] = ThresholdRate_SemiSupervised(data, similar_pairs, f, w, s)
%THRESHOLDRATE ���ġ�Learning Task-Specific Similarity����2005�꣩��3.2��Algorithm 6
%  data: ���ݼ������ݼ��а������ݵ�
%  similar_pairs: ���Ƶ����ݶԣ���2xNp��2��Np�У�ÿһ�б�ʾһ���������ݶԵ��±꣬��Ӧdata�е��±ꡣ
%  f��ӳ�亯���������ݵ�xӳ�䵽һ��ʵ������
%  w��Ȩֵ�������������ݶԵ�Ȩֵ
%  s��Ȩֵ���������ݵ��Ȩֵ
%  T�������Thresholdֵ����һ�����������������п��ܵ�Thresholdֵ
%  TP����ӦT�����µ�True Positiveֵ����ʾʵ��Ϊ���������ұ��ж�Ϊ�����ĸ���
%  FP����ӦT�����µ�False Positiveֵ����ʾʵ��Ϊ���������Ǳ��ж�Ϊ�����ĸ���

    [~,N] = size(data); % ���ݼ��й���N�����ݵ�
    v = zeros(1,N);   % ���ݼ��е�ÿһ������ӳ��Ϊһ������ֵ���洢��v��
    
    parfor n=1:N 
        v(n) = f(data(:,n)); 
    end

    u = unique(v); % ȥ��v�е��ظ�����
    u = sort(u); % ����
    delta = (u(2:length(u)) - u(1:(length(u)-1))) / 2;
    T = u(1:length(delta)) + delta;
    T = [u(1) - delta(1),T,u(length(u)) + delta(length(delta))]; % ����õ����п��ܵ�Threshold
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
    
    [svp,idx] = sort(vp); sdp = dp(idx); swp = wp(idx); % ����
    
    for j = 1:length(T)
        idx_tp = svp <= T(j);
        TP(j) = 1 - swp(idx_tp) * sdp(idx_tp)';
        PI(j) = sum(s(v <= T(j)));    
    end
    
    FP = PI.^2 + (1 - PI).^2;
end
