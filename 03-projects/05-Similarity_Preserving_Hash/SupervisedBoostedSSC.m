function H = SupervisedBoostedSSC(data, M)
%SSC 论文“Learning Task-Specific Similarity”（2005年）中3.3.2节Algorithm 7
% data: 数据集，数据集中包含三个部分data.x1表示第1个数据点，data.x2表示第2个数据点，data.similar表示是否相似的标签，+1表示相似，-1表示不相似
% M: hash函数的个数

    H = [];
    N = length(data.similar); % 数据样本点的个数
    D = length(data.x1(:,1)); % 数据的维度
    W = ones(1,N)/N;          % 初始化权值
    
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
        
        if (1+r_max)/(1-r_max) < 1  %TODO：这个计算alfa的方法是有问题的，需要修改
            break;
        else
            Alfa = 0.5 * log((1+r_max)/(1-r_max));
        end
        
        % 计算Cm
        func_best = @(x)f(x,d_best);
        for n = 1:N
            R1(n) = func_best(data.x1(:,n));
            R2(n) = func_best(data.x2(:,n));
        end
        Cm = -1 * ones(1,N);
        Cm((R1<=T_best)&(R2<=T_best)) = 1;
        Cm((R1>=T_best)&(R2>=T_best)) = 1;
        
        % 调整权值
        W = W .* exp(-1 * data.similar .* Cm);
        W = W ./ sum(W);
        
        H = [H; [d_best T_best Alfa]];
    end
end

