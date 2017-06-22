function H = SSC_SupervisedBoosted(data, M)
%SSC 论文“Learning Task-Specific Similarity”（2005年）中3.3.2节Algorithm 7
% data: 数据集，其中data.points表示数据样本点，data.similar表示是否相似的标签，
%       每一列三个数，第1和2个数表示元素的下标，第3个数表示是否相似+1相似，-1不相似
% M: hash函数的个数

    H = [];
    [~,N] = size(data.similar);     % 数据对样本的个数
    D = length(data.points(:,1));   % 数据的维度
    W = ones(1,N)/N;                % 初始化权值
    
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
        
        % 计算Cm
        func_best = @(x)project_function(x,d_best);
        R1 = func_best(data.points(:,data.similar(1,:)));
        R2 = func_best(data.points(:,data.similar(2,:)));
        
        Cm = -1 * ones(1,N);
        Cm((R1<=T_best)&(R2<=T_best)) = 1;
        Cm((R1> T_best)&(R2> T_best)) = 1;
        
        % 调整权值
        W = W .* exp(-1 * alfa * data.similar(3,:) .* Cm);
        W = W ./ sum(W);
        
        H = [H; [d_best T_best alfa]];
    end
end

