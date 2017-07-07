classdef AdaBoost
    %UNTITLED AdaBoost类，实现AdaBoost算法
    %   
    
    properties
        hypothesis;  % 包含若干个弱分类器的cell数组
        alfa;        % 每个弱分类器的投票权值
    end
    
    methods
        function obj = AdaBoost()
            hypothesis = [];
            alfa = [];
        end
    end
    
    methods
        function obj  = train(obj,data,num_weak,max_it)
            %TRAIN 训练adaboost模型
            %   输入：
            %   data：训练数据，data.points表示数据点，data.labels包含+1或-1，
            %   用来指示data.points中数据点的分类
            %   num_weak：表示弱分类器的个数
            %   max_it：最大迭代次数
            %
            %   输出：
            %   obj：训练后的adaboost对象
            
            [D,N] = size(data.points);  % D数据的维度，N数据的个数
            weight = ones(1,N) ./ N;    % 样本对应的权值向量
            learn_rate = 0.01;
            
            for classifier_idx = 1:num_weak
                B = randn(1,D); % 初始化参数B
                f_func = F_Linear(B,0); % 初始化f函数
                f_value = f_func.do(data.points); % 对所有的点计算f函数的值
                C = -1 * median(f_value); % 初始化参数C为中值
                f_func = F_Linear(B,C); % 重新初始化f函数
                f_value = f_func.do(data.points); % 重新计算f函数的值
                f_value_max = max(f_value);
                f_value_min = min(f_value);
                gama = log((1 - 0.999) / 0.999) / min(abs(f_value_max),abs(f_value_min)); % 初始化gamma的值
                
                ob = Observer('name',1,100,'legend');
                
                for it = 0:max_it
                    f_func = F_Linear(B,C); % 更新f函数
                    h_func = F_Sigmoid(f_func,gama); % 更新h函数
                    classifier =  WeakClassifier(h_func); % 更新弱分类器
                    
                    c = classifier.do(data.points);
                    r = weight * (data.labels .* c)';
                    ob = ob.showit(r,'description');
                    
                    h_value = h_func.do(data.points);
                    gradient_c = 2 .* h_value .* (h_value - 1) .* gama;
                    gradient_c_B = repmat(gradient_c',1,2) .* data.points';
                    gradient_c_C = gradient_c;
                    
                    gradient_r_B = sum(repmat((weight .* data.labels)',1,D) .* gradient_c_B);
                    gradient_r_C = sum(weight .* data.labels .* gradient_c_C);
                    
                    B = B + learn_rate * gradient_r_B;
                    C = C + learn_rate * gradient_r_C;
                end
                
                for k = 1:K
                    weak_classifier = WeakClassifier(@project_function,XD(k),XT(k),XF(k));
                    c = weak_classifier.predict(data.points);
                    r(k) = weight * (data.labels .* c)';
                end
                
                [r_max,r_idx] = max(r); d_best = XD(r_idx); t_best = XT(r_idx); f_best = XF(r_idx);
                if r_max >= 1
                    weak_classifer_best = WeakClassifier(@project_function,d_best,t_best,f_best);
                    obj.hypothesis{1+length(obj.hypothesis)} = weak_classifer_best;
                    obj.alfa = [obj.alfa 1];
                    break;
                else
                    alfa = 0.5 * log((1+r_max)/(1-r_max));
                end
                
                weak_classifer_best = WeakClassifier(@project_function,d_best,t_best,f_best);
                obj.hypothesis{1+length(obj.hypothesis)} = weak_classifer_best;
                obj.alfa = [obj.alfa alfa];
                
                c = weak_classifer_best.predict(data.points);
                weight = weight .* exp(-1 * alfa * data.labels .* c);
                weight = weight ./ sum(weight);
            end
        end
        
        function y    = predict(obj,points)  % 使用经过训练的模型判断数据点的分类
            %PREDICT 判断两个点是否相似，相似为+1，不相似为-1
            %
            M = length(obj.alfa); % 弱分类器的个数
            N = length(points);  % 数据点数
            C = zeros(M,N);
            for m=1:M
                C(m,:) = obj.hypothesis{m}.predict(points);
            end
            y = sign(obj.alfa * C);
            y(y<=0) = -1;
        end
    end
end

