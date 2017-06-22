function H = SSC_SemiSupervisedBoosted(data, M)
%SSC 论文“Learning Task-Specific Similarity”（2005年）中3.3.3节
% data: 数据集，数据集中包含三个部分data.x1表示第1个数据点，data.x2表示第2个数据点，data.similar表示是否相似的标签，+1表示相似，-1表示不相似
% M: hash函数的个数

    H = [];
    [D,N ] = size(data.points);  % D 表示数据的维度，N表示数据样本点的个数
    [~,Np] = size(data.similar); % Np表示正例的个数  
    Wp = ones(1,Np)/Np;          % 初始化正例的权值
    S  = ones(1,N )/N ;          % 所有样本点的权值
    
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
                E_Cm   = 2*PJ(:,r_max_d_idx) - 1; %对应最佳的T的情况下的Cm的数学期望
            end
        end
        
        if r_max >= 1 || r_max <= 0
            break;
        else
            alfa = 0.5 * log((1+r_max)/(1-r_max));
        end
        
        % 计算Cm
        func_best = @(x)project_function(x,d_best);
        R1 = func_best(data.points(:,data.similar(1,:)));
        R2 = func_best(data.points(:,data.similar(2,:)));
            
        Cm = -1 * ones(1,Np);
        Cm((R1 <= T_best)&(R2 <= T_best)) = 1;
        Cm((R1 >  T_best)&(R2 >  T_best)) = 1;
        
        % 调整正例的权值
        Wp = Wp .* exp(-1 * alfa * Cm);
        Wp = Wp ./ sum(Wp);
        
        % 调整反例的权值
        S  = S  .* exp(alfa * E_Cm');
        S  = S  ./ sum(S);
        
        H = [H; [d_best T_best alfa]];
    end
end

