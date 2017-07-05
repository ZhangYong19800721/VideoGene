function H = SSC_SemiSupervisedBoosted(data, M)
%SSC ���ġ�Learning Task-Specific Similarity����2005�꣩��3.3.3��
% data: ���ݼ������ݼ��а�����������data.x1��ʾ��1�����ݵ㣬data.x2��ʾ��2�����ݵ㣬data.similar��ʾ�Ƿ����Ƶı�ǩ��+1��ʾ���ƣ�-1��ʾ������
% M: hash�����ĸ���

    H = [];
    [D,N ] = size(data.points);  % D ��ʾ���ݵ�ά�ȣ�N��ʾ����������ĸ���
    [~,Np] = size(data.similar); % Np��ʾ�����ĸ���  
    Wp = ones(1,Np)/Np;          % ��ʼ��������Ȩֵ
    S  = ones(1,N )/N ;          % �����������Ȩֵ
    
    for m = 1:M
        r_max = -inf;
        for d = 1:D
            func = @(x)project_function(x,d);
            [T,TP,~,v,PI] = ThresholdRate_SemiSupervised(data,func,Wp,S); Nt = length(T);
            v_mat = repmat(v',1,Nt); T_mat = repmat(T,N,1); h = (v_mat <= T_mat); PI = repmat(PI,N,1);
            PJ = h .* PI + (1-h) .* (1-PI);
            r = TP - 0.5 - S*(PJ-0.5);
            [r_max_d,r_max_d_idx] = max(r);
            if r_max_d > r_max
                r_max = r_max_d;
                d_best = d;
                T_best = T(r_max_d_idx);
                E_Cm   = 2*PJ(:,r_max_d_idx) - 1; %��Ӧ��ѵ�T������µ�Cm����ѧ����
            end
        end
        
        if r_max >= 1 || r_max <= 0
            break;
        else
            alfa = 0.5 * log((1+r_max)/(1-r_max));
        end
        
        % ����Cm
        func_best = @(x)project_function(x,d_best);
        R1 = func_best(data.points(:,data.similar(1,:)));
        R2 = func_best(data.points(:,data.similar(2,:)));
            
        Cm = -1 * ones(1,Np);
        Cm((R1 <= T_best)&(R2 <= T_best)) = 1;
        Cm((R1 >  T_best)&(R2 >  T_best)) = 1;
        
        % ����������Ȩֵ
        Wp = Wp .* exp(-1 * alfa * Cm);
        Wp = Wp ./ sum(Wp);
        
        % ����������Ȩֵ
        S  = S  .* exp(alfa * E_Cm');
        S  = S  ./ sum(S);
        
        H = [H; [d_best T_best alfa]];
    end
end

