function H = SupervisedBoostedSSC(data, M)
%SSC ���ġ�Learning Task-Specific Similarity����2005�꣩��3.3.2��Algorithm 7
% data: ���ݼ������ݼ��а�����������data.x1��ʾ��1�����ݵ㣬data.x2��ʾ��2�����ݵ㣬data.similar��ʾ�Ƿ����Ƶı�ǩ��+1��ʾ���ƣ�-1��ʾ������
% M: hash�����ĸ���

    H = [];
    N = length(data.similar); % ����������ĸ���
    D = length(data.x1(:,1)); % ���ݵ�ά��
    W = ones(1,N)/N;          % ��ʼ��Ȩֵ
    
    for m = 1:M
        Wp = sum(W(data.similar == +1));
        Wn = sum(W(data.similar == -1));
        
        r_max = -inf;
        for d = 1:D
            func = @(x)f(x,d);
            [T,TP,FP] = ThresholdRate(data,func,W);
            r = 2 * (TP - FP) + Wn - Wp;
            [r_max_d,r_max_d_idx] = max(r);
            if r_max_d > r_max
                r_max = r_max_d;
                d_best = d;
                T_best = T(r_max_d_idx);
            end
        end
        
        if (1+r_max)/(1-r_max) < 1  %TODO���������alfa�ķ�����������ģ���Ҫ�޸�
            break;
        else
            Alfa = 0.5 * log((1+r_max)/(1-r_max));
        end
        
        % ����Cm
        func_best = @(x)f(x,d_best);
        for n = 1:N
            R1(n) = func_best(data.x1(:,n));
            R2(n) = func_best(data.x2(:,n));
        end
        Cm = -1 * ones(1,N);
        Cm((R1<=T_best)&(R2<=T_best)) = 1;
        Cm((R1>=T_best)&(R2>=T_best)) = 1;
        
        % ����Ȩֵ
        W = W .* exp(-1 * data.similar .* Cm);
        W = W ./ sum(W);
        
        H = [H; [d_best T_best Alfa]];
    end
end

