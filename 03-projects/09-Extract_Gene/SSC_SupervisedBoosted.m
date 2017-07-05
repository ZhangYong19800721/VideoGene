function H = SSC_SupervisedBoosted(data, M)
%SSC ���ġ�Learning Task-Specific Similarity����2005�꣩��3.3.2��Algorithm 7
% data: ���ݼ�������data.points��ʾ���������㣬data.similar��ʾ�Ƿ����Ƶı�ǩ��
%       ÿһ������������1��2������ʾԪ�ص��±꣬��3������ʾ�Ƿ�����+1���ƣ�-1������
% M: hash�����ĸ���

    H = [];
    [~,N] = size(data.similar);     % ���ݶ������ĸ���
    D = length(data.points(:,1));   % ���ݵ�ά��
    W = ones(1,N)/N;                % ��ʼ��Ȩֵ
    
    for m = 1:M
        Wp = sum(W(data.similar(3,:) > 0));
        Wn = sum(W(data.similar(3,:) < 0));
        
        record = zeros(D,3);
        for d = 1:D
            func = @(x)project_function(x,d);
            [T,TP,FP] = ThresholdRate_Supervised(data,func,W);
            r = 2 * Wp * TP - 2 * Wn * FP + Wn - Wp;
            [r_max_d,r_idx_d] = max(r);
            record(d,:) = [r_max_d, d, T(r_idx_d)];
        end
        [r_max,r_idx] = max(record(:,1)); d_best = record(r_idx,2); T_best = record(r_idx,3);
        
        if r_max >= 1 || r_max <= 0
            break;
        else
            alfa = 0.5 * log((1+r_max)/(1-r_max));
        end
        
        % ����Cm
        func_best = @(x)project_function(x,d_best);
        R1 = func_best(data.points(:,data.similar(1,:)));
        R2 = func_best(data.points(:,data.similar(2,:)));
        
        Cm = -1 * ones(1,N);
        Cm((R1<=T_best)&(R2<=T_best)) = 1;
        Cm((R1> T_best)&(R2> T_best)) = 1;
        
        % ����Ȩֵ
        W = W .* exp(-1 * alfa * data.similar(3,:) .* Cm);
        W = W ./ sum(W);
        
        H = [H; [d_best T_best alfa]];
    end
end

