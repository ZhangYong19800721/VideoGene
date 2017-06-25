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
            %   num_weak：表示弱分类器的个数
            %
            %   输出：
            %   obj：训练后的SimilarityPreservingHash对象
            
            ob_window_size = 500;
            [D,N] = size(data.points);   % D表示数据的维度，N表示数据点个数
            [~,P] = size(data.similar);  % P表示数据对的个数
            weight = ones(1,P) ./ P;     % 权值向量
            max_it = 1e5;                % 最大迭代次数
            learn_rate_max = 1e-3;       % 最大学习速度
            learn_rate_min = 1e-6;       % 最小学习速度            
            momentum = 0.5; % 初始化动量倍率为0.5
            
            for m = 1:num_weak % 迭代开始
                ob = Observer('observer',2,ob_window_size,'legend'); % 初始化一个观察器
                
                XD = []; XT = [];
                for d = 1:D
                    v = f_axis_parallel(data.points,d);
                    u = unique(v); u = sort(u); Nu = length(u); %去除v中的重复数据,排序
                    delta = (u(2:Nu) - u(1:(Nu-1))) / 2; Nd = length(delta);
                    T = [u(1)-delta(1), u(1:Nd) + delta, u(Nu)+delta(Nd)]; %计算得到所有可能的threshold
                    XD = [XD d*ones(1,length(T))];
                    XT = [XT T];
                end
                K = length(XD); %XD或XT的长度代表了所有可能的选择维度和门限
                Rm = zeros(1,K); % 选择一个弱分类器使r最大
                for k = 1:K
                    weak_classifer = SCC_WeakClassifier(@f_axis_parallel,XD(k),XT(k)); % 使用f函数和threshold即可得到一个弱分类器
                    c = weak_classifer.predict(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
                    Rm(k) = weight * (data.similar(3,:) .* c)';
                end
                [~,Rm_idx] = max(Rm); d_best = XD(Rm_idx); t_best = XT(Rm_idx);
                
                A = zeros(D);                      % 将A初始化为一个全0方阵
                B = zeros(1,D); B(d_best) = 1;     % 将B初始化
                C = -1 * t_best;                   % 将C初始化为0
                f_func = @(x)f_quadratic(x,A,B,C); % 得到f函数
                f_value  = f_func(data.points);    % 对所有的数据点计算f函数的值
                max_f_value = max(f_value);        % 得到最大值
                min_f_value = min(f_value);        % 得到最小值
                r = log((1 - 0.999) / 0.999) / min(abs(max_f_value),abs(min_f_value)); % 初始化gamma的值
                
                % 找到一个使得（3.22）式中的r最大化的弱分类器
                velocity_r_A = zeros(D);
                velocity_r_B = zeros(1,D);
                velocity_r_C = 0;
                learn_rate_current = learn_rate_max; % 学习速度初始化为最大学习速度
                Rm_record = ones(1,ob_window_size); flag = false;
                
                for it = 1:max_it                    
                    f_func = @(x)f_quadratic(x,A,B,C); % 更新f函数
                    h_func = logistic(f_func,r);       % 绑定gamma参数，得到h函数（或更新h函数）
                    weak_c = weak_classifier(h_func);  % 绑定h函数，得到弱分类器（或更新弱分类器）
                    Cp = weak_c.do(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
                    Rm = sum(weight .* data.similar(3,:) .* Cp);
                    
                    if learn_rate_current == learn_rate_min 
                        break; % 当学习速度下降到最小学习速度时，停止迭代
                    end
                    
                    if flag == false
                        Rm_record = Rm * Rm_record;
                        Rm_window_ave_old = Rm - 100;
                        flag = true;
                    end
                    
                    Rm_record(mod(it,ob_window_size)+1) = Rm;
                    Rm_window_ave = mean(Rm_record);
                    
                    if mod(it,ob_window_size) == 0
                        if Rm_window_ave < Rm_window_ave_old
                            learn_rate_current = max(0.5 * learn_rate_current,learn_rate_min);   
                        elseif (Rm_window_ave - Rm_window_ave_old) < 1e-4
                            learn_rate_current = max(0.5 * learn_rate_current,learn_rate_min);   
                        end
                        Rm_window_ave_old = Rm_window_ave;
                    end
                    
                    description = strcat('Iteration: ', strcat(strcat(num2str(it),'/'),num2str(max_it)));
                    description = strcat(description, strcat(' LearnRate: ',num2str(learn_rate_current)));
                    ob = ob.showit([Rm Rm_window_ave]',description);
                    
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
                    
                    momentum = min([momentum * 1.01,0.9]); % 动量倍率最大为0.9，初始值为0.5，大约迭代60步之后动量倍率达到0.9。
                    velocity_r_A = momentum * velocity_r_A + learn_rate_current * gradient_r_A;
                    velocity_r_B = momentum * velocity_r_B + learn_rate_current * gradient_r_B;
                    velocity_r_C = momentum * velocity_r_C + learn_rate_current * gradient_r_C;
                    
                    A = A + velocity_r_A;
                    B = B + velocity_r_B;
                    C = C + velocity_r_C;
                end
                
                Rm_max = sum(weight .* data.similar(3,:) .* sign(Cp));
                if Rm_max >= 1
                    obj.hypothesis{1+length(obj.hypothesis)} = h_func;
                    obj.alfa = [obj.alfa 1];
                    break;
                elseif Rm_max <= 0
                    break;                   
                else
                    current_alfa = 0.5 * log((1+Rm_max)/(1-Rm_max));
                end
                
                obj.hypothesis{1+length(obj.hypothesis)} = h_func;
                obj.alfa = [obj.alfa current_alfa];
                
                weight = weight .* exp(-1 * current_alfa * data.similar(3,:) .* sign(Cp));
                weight = weight ./ sum(weight);
            end
        end
        
        function C = hashcode(obj,points)
            [~,N] = size(points);
            M = length(obj.alfa);
            C = false(M,N);
            for m = 1:M
                C(m,:) = (obj.hypothesis{m}.do(points) >= 0.5);
            end
        end
    end
end

