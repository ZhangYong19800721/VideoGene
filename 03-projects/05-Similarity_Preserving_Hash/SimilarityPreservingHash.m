classdef SimilarityPreservingHash
    %SimilarityPreservingHash Similarity Preserving Hash类
    %   
    
    properties
        hypothesis;  % 包含若干个弱分类器的cell数组
        alfa;        % 每个弱分类器的投票权值
    end
    
    methods % 构造函数
        function obj = SimilarityPreservingHash()
            obj.hypothesis = [];
            obj.alfa = [];
        end
    end
    
    methods
        function obj  = train(obj,data,num_weak)
            %TRAIN 训练SimilarityPreservingHash模型
            %   输入：
            %   data：训练数据，data.points表示数据点，data.similar包含[i j
            %         s]'，其中i和j表示point数组的下标，s表示两个元素是否相似
            %   weight：初始的权值，要求非负，且sum(weight)=1。
            %   num_weak：表示弱分类器的个数
            %
            %   输出：
            %   obj：训练后的SimilarityPreservingHash对象
            
            [D,N] = size(data.points);   % D表示数据的维度，N表示数据点个数
            [~,P] = size(data.similar);  % P表示数据对的个数
            weight = ones(1,P) ./ P;     % 权值向量
            max_it = 1e5;                % 最大迭代次数
            learn_rate = 0.0001;         % 学习速度
            
            A = zeros(D);                      % 将A初始化为一个全0方阵
            B = sign(randn(1,D));              % 将B初始化为一个随机正负1向量
            C = 0;                             % 将C初始化为0
            f_func = @(x)f_quadratic(x,A,B,C); % 得到f函数
            f_value  = f_func(data.points);    % 对所有的数据点计算f函数的值
            C = -1 * median(f_value);          % 将C设定为f函数值序列的中位数
            f_func = @(x)f_quadratic(x,A,B,C); % 重新初始化f函数
            f_value  = f_func(data.points);    % 重新计算所有数据点的f函数值
            max_f_value = max(f_value);        % 得到最大值
            min_f_value = min(f_value);        % 得到最小值
            r = log((1 - 0.999) / 0.999) / min(abs(max_f_value),abs(min_f_value)); % 初始化gamma的值
            
            for m = 1:num_weak % 迭代开始
                % 找到一个使得（3.22）式中的r最大化的弱分类器
                for it = 1:max_it
                    h_func = logistic(f_func,r);       % 绑定gamma参数，得到h函数（或更新h函数）
                    weak_c = weak_classifier(h_func);  % 绑定h函数，得到弱分类器（或更新弱分类器）
                    Cp = weak_c.do(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
                    Rm = sum(weight .* data.similar(3,:) .* Cp)
                    
                    % 计算梯度
                    h_value  = h_func.do(data.points);
                    gradient_h_C  = h_value .* (h_value - 1) * r;
                    
                    for n = 1:N
                        gradient_h_A{n} = gradient_h_C(n) * data.points(:,n) * data.points(:,n)';
                        gradient_h_B{n} = gradient_h_C(n) * data.points(:,n)';
                    end
                    
                    for p = 1:P
                        x1_idx = data.similar(1,p); x2_idx = data.similar(2,p);
                        gradient_c_A{p} = 4 * (gradient_h_A{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_A{x2_idx} * (h_value(x1_idx) - 0.5));
                        gradient_c_B{p} = 4 * (gradient_h_B{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_B{x2_idx} * (h_value(x1_idx) - 0.5));
                        gradient_c_C{p} = 4 * (gradient_h_C(x1_idx) * (h_value(x2_idx) - 0.5) + gradient_h_C(x2_idx) * (h_value(x1_idx) - 0.5));
                    end
                    
                    gradient_r_A = zeros(D); gradient_r_B = zeros(1,D); gradient_r_C = 0;
                    for p = 1:P
                        gradient_r_A = gradient_r_A + weight(p) * data.similar(3,p) * gradient_c_A{p};
                        gradient_r_B = gradient_r_B + weight(p) * data.similar(3,p) * gradient_c_B{p};
                        gradient_r_C = gradient_r_C + weight(p) * data.similar(3,p) * gradient_c_C{p};
                    end
                    
                    A = A + learn_rate * gradient_r_A;
                    B = B + learn_rate * gradient_r_B;
                    C = C + learn_rate * gradient_r_C;
                    f_func = @(x)f_quadratic(x,A,B,C); % 更新f函数
                end
                
                
                

                if r_max >= 1        
                    % TODO
                elseif r_max <= 0
                    % TODO                   
                else
                    current_alfa = 0.5 * log((1+r_max)/(1-r_max));
                end
                
                weak_classifer_best = WeakClassifierSCC(@(x)project_function(x,d_best),t_best);
                obj.hypothesis{1+length(obj.hypothesis)} = weak_classifer_best;
                obj.alfa = [obj.alfa current_alfa];
                
                c = weak_classifer_best.predict(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
                weight = weight .* exp(-1 * current_alfa * data.similar(3,:) .* c);
                weight = weight ./ sum(weight);
            end
        end
        
        function C    = hashcode(obj,points)
            
        end
    end
end

