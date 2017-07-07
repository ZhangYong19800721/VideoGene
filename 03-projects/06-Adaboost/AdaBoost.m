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
        function obj  = train(obj,data,num_classifier,learn_rate_max,learn_rate_min,max_it)
            %TRAIN 训练adaboost模型
            %   输入：
            %   data：训练数据，data.points表示数据点，data.labels包含+1或-1，
            %   用来指示data.points中数据点的分类
            %   num_classifier：表示弱分类器的个数
            %   max_it：最大迭代次数
            %   learn_rate：学习速度
            % 
            %   输出：
            %   obj：训练后的adaboost对象
            
            ob_window_size = 100;
            [D,N] = size(data.points);  % D数据的维度，N数据的个数
            weight = ones(1,N) ./ N;    % 样本对应的权值向量
            momentum = 0.5;             % 初始化动量倍率为0.5
            
            for classifier_idx = 1:num_classifier
                ob = Observer('R-Value',2,ob_window_size,'xxx'); % 初始化一个观察者
                
                B = randn(1,D); % 初始化参数B
                f_func = F_Linear(B,0); % 初始化f函数
                f_value = f_func.do(data.points); % 对所有的点计算f函数的值
                C = -1 * median(f_value); % 初始化参数C为中值
                f_func = F_Linear(B,C); % 重新初始化f函数
                f_value = f_func.do(data.points); % 重新计算f函数的值
                f_value_max = max(f_value);
                f_value_min = min(f_value);
                gama = log((1 - 0.999) / 0.999) / min(abs(f_value_max),abs(f_value_min)); % 初始化gamma的值
                
                velocity_r_B = zeros(size(B));
                velocity_r_C = zeros(size(C));
                
                learn_rate = learn_rate_max;
                
                flag = false;
                r_ave_max = -inf;
                
                for it = 0:max_it
                    f_func = F_Linear(B,C); % 更新f函数
                    h_func = F_Sigmoid(f_func,gama); % 更新h函数
                    classifier =  WeakClassifier(h_func); % 更新弱分类器
                    
                    c = classifier.do(data.points);
                    r = weight * (data.labels .* c)';
                    
                    if learn_rate == learn_rate_min 
                        break; % 当学习速度下降到最小学习速度时，停止迭代
                    end
                    
                    if flag == false
                        r_list = r * ones(1,ob_window_size);   % 利用第一次计算得到的Rm值初始化Rm_record
                        r_ave_old = r - 100; % 初始化旧的窗口平均值
                        flag = true;
                    end
                    
                    r_list(mod(it,ob_window_size)+1) = r;     % 记录当前的Rm值到Rm_record数组中
                    r_ave_new = mean(r_list);          % 计算Rm的窗口平均值
                    
                    description = strcat('迭代次数: ', strcat(strcat(num2str(it),'/'),num2str(max_it)));
                    description = strcat(description, strcat(' 学习速率: ',num2str(learn_rate)));
                    description = strcat(description, strcat(' 目标函数: ',num2str(r)));
                    description = strcat(description, strcat(' Gama: ',num2str(gama)));
                    ob = ob.showit([r r_ave_new]',description);
                    
                    if mod(it,ob_window_size) == (ob_window_size-1)  % 如果到达窗口的末端
                        if r_ave_new < r_ave_old % 如果窗口平均值下降(出现震荡)就降低学习速度
                            learn_rate = max(0.5 * learn_rate,learn_rate_min);
                            % [best_r,best_idx] = max(r_list);
                            r_ave_old = r_ave_new;
                            continue;
                        else
                            if r_ave_new > r_ave_max
                                gama = 1.1 * gama;
                                r_ave_max = r_ave_new;
                            end
                            
                            if r_ave_new - r_ave_old < 1e-3
                                % 如果达到最大迭代次数Rm也不会增加超过当前值的1/100就缩减学习速度
                                learn_rate = max(0.5 * learn_rate,learn_rate_min);
                            end
                            r_ave_old = r_ave_new;
                        end
                    end
                    
                    
                    h_value = h_func.do(data.points);
                    gradient_c = 2 .* h_value .* (h_value - 1) .* gama;
                    gradient_c_B = repmat(gradient_c',1,D) .* data.points';
                    gradient_c_C = gradient_c;
                    
                    gradient_r_B = sum(repmat((weight .* data.labels)',1,D) .* gradient_c_B);
                    gradient_r_C = sum(weight .* data.labels .* gradient_c_C);
                    
                    momentum = min([momentum * 1.01,0.9]); % 动量倍率最大为0.9，初始值为0.5，大约迭代60步之后动量倍率达到0.9。
                    velocity_r_B = momentum * velocity_r_B + learn_rate * gradient_r_B;
                    velocity_r_C = momentum * velocity_r_C + learn_rate * gradient_r_C;
                    
                    B = B + velocity_r_B;
                    C = C + velocity_r_C;
                end
                
                r_max = weight * (data.labels .* sign(c))';
                
                if r_max >= 1
                    obj.hypothesis{1+length(obj.hypothesis)} = classifier;
                    obj.alfa = [obj.alfa 1];
                    break;
                elseif r_max <= 0
                    break;
                else
                    alfa = 0.5 * log((1+r_max)/(1-r_max));
                end
                
                obj.hypothesis{1+length(obj.hypothesis)} = classifier;
                obj.alfa = [obj.alfa alfa];
                
                weight = weight .* exp(-1 * alfa * data.labels .* sign(c));
                weight = weight ./ sum(weight);
            end
        end
        
        function y    = predict(obj,points)  % 使用经过训练的模型判断数据点的分类
            %PREDICT 判断两个点是否相似，相似为+1，不相似为-1
            %
            M = length(obj.alfa); % 弱分类器的个数
            [D,N] = size(points);  % N数据点数
            C = zeros(M,N);
            for m=1:M
                C(m,:) = obj.hypothesis{m}.do(points);
            end
            y = sign(obj.alfa * C);
        end
    end
end

