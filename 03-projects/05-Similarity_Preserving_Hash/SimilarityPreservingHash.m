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
            
            ob_window_size = 100;
            [D,N] = size(data.points);   % D表示数据的维度，N表示数据点个数
            [~,P] = size(data.similar);  % P表示数据对的个数
            weight = ones(1,P) ./ P;     % 权值向量
            max_it = 1e4;                % 最大迭代次数
            learn_rate_max = 1e-1;       % 最大学习速度
            learn_rate_min = 1e-6;       % 最小学习速度            
            momentum = 0.5;              % 初始化动量倍率为0.5
            
            for m = 1:num_weak % 迭代开始
                ob = Observer('observer',2,ob_window_size,'legend'); % 初始化一个观察器
                
%                 XD = []; XT = [];
%                 for d = 1:D
%                     v = axis(data.points,d,0);
%                     u = unique(v); u = sort(u); Nu = length(u); %去除v中的重复数据,排序
%                     delta = (u(2:Nu) - u(1:(Nu-1))) / 2; Nd = length(delta);
%                     T = [u(1)-delta(1), u(1:Nd) + delta, u(Nu)+delta(Nd)]; %计算得到所有可能的threshold
%                     XD = [XD d*ones(1,length(T))];
%                     XT = [XT T];
%                 end
%                 K = length(XD); % XD或XT的长度代表了所有可能的选择维度和门限
%                 Rm = zeros(1,K); % 选择一个弱分类器使Rm最大
%                 % parfor k = 1:K
%                 for k = 1:K
%                     f_func = F_Axis(XD(k),-1 * XT(k)); 
%                     h_func = H_Func(f_func,1.0); 
%                     weak_classifer = WeakClassifier(h_func); % 得到一个弱分类器
%                     c = weak_classifer.do(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
%                     Rm(k) = weight * (data.similar(3,:) .* sign(c))';
%                 end
%                 [Rm_max,Rm_max_idx] = max(Rm); d_best = XD(Rm_max_idx); t_best = XT(Rm_max_idx);
                
                A = randn(D);                       % 将A初始化为一个全0方阵
                B = randn(1,D);                     % 将B初始化
                f_func = F_Quadratic(A,B,0);       % 初始化f函数
                f_value = f_func.do(data.points);  % 对所有的数据点计算f函数的值
                C = -1 * median(f_value);          % 将C初始化
                f_func = F_Quadratic(A,B,C);       % 初始化f函数
                f_value  = f_func.do(data.points); % 对所有的数据点计算f函数的值
                max_f_value = max(f_value);        % 得到最大值
                min_f_value = min(f_value);        % 得到最小值
                r = log((1 - 0.999) / 0.999) / min(abs(max_f_value),abs(min_f_value)); % 初始化gamma的值
                
                % 找到一个使得（3.22）式中的r最大化的弱分类器
                velocity_Rm_A = zeros(size(A));
                velocity_Rm_B = zeros(size(B));
                velocity_Rm_C = zeros(size(C));
                learn_rate_current = learn_rate_max;                % 学习速度初始化为最大学习速度
                Rm_record = ones(1,ob_window_size); flag = false;   % Rm_record用来记录迭代过程中的Rm值
                
                for it = 1:max_it                    
                    f_func = F_Quadratic(A,B,C);       % 更新f函数
                    h_func = H_Func(f_func,r);         % 绑定gamma参数，得到h函数（或更新h函数）
                    weak_c = WeakClassifier(h_func);   % 绑定h函数，得到弱分类器（或更新弱分类器）
                    c = weak_c.do(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
                    Rm = sum(weight .* data.similar(3,:) .* c);
                    
                    if learn_rate_current == learn_rate_min 
                        break; % 当学习速度下降到最小学习速度时，停止迭代
                    end
                    
                    if flag == false
                        Rm_record = Rm * Rm_record;   % 利用第一次计算得到的Rm值初始化Rm_record
                        Rm_window_ave_old = Rm - 100; % 初始化旧的窗口平均值
                        flag = true;
                    end
                    
                    Rm_record(mod(it,ob_window_size)+1) = Rm; % 记录当前的Rm值到Rm_record数组中
                    Rm_window_ave = mean(Rm_record);          % 计算Rm的窗口平均值
                    
                    if mod(it,ob_window_size) == 0            % 如果到达窗口的末端
                        if Rm_window_ave < Rm_window_ave_old  % 如果窗口平均值下降就降低学习速度
                            learn_rate_current = max(0.5 * learn_rate_current,learn_rate_min);   
                        elseif Rm_window_ave - Rm_window_ave_old < 1e-5
                            % 如果达到最大迭代次数Rm也不会增加超过当前值的1/100就缩减学习速度
                            learn_rate_current = max(0.5 * learn_rate_current,learn_rate_min);   
                            if Rm_window_ave - Rm_window_ave_old < 1e-6
                                % 如果达到最大迭代次数Rm也不会增加超过当前值的1/1000就停止
                                learn_rate_current = learn_rate_min;   
                            end
                        end
                        Rm_window_ave_old = Rm_window_ave;
                    end
                    
                    description = strcat('Iteration: ', strcat(strcat(num2str(it),'/'),num2str(max_it)));
                    description = strcat(description, strcat(' LearnRate: ',num2str(learn_rate_current)));
                    ob = ob.showit([Rm Rm_window_ave]',description);
                    
                    % 计算梯度
                    h_value       = h_func.do(data.points);         % 计算所有数据点的h函数值
                    gradient_h_C  = h_value .* (h_value - 1) * r;   % 计算h函数对C的偏导数
                    
                    %parfor n = 1:N 
                    for n = 1:N 
                        gradient_h_A{n} = gradient_h_C(n) * data.points(:,n) * data.points(:,n)'; % 计算h函数对A的偏导数
                        gradient_h_B{n} = gradient_h_C(n) * data.points(:,n)';                    % 计算h函数对B的偏导数
                    end
                    
                    %parfor p = 1:P
                    for p = 1:P
                        x1_idx = data.similar(1,p); x2_idx = data.similar(2,p);
                        % 计算c函数对A、B、C的偏导数
                        gradient_c_A{p} = 4 * (gradient_h_A{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_A{x2_idx} * (h_value(x1_idx) - 0.5));
                        gradient_c_B{p} = 4 * (gradient_h_B{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_B{x2_idx} * (h_value(x1_idx) - 0.5));
                        gradient_c_C{p} = 4 * (gradient_h_C(x1_idx) * (h_value(x2_idx) - 0.5) + gradient_h_C(x2_idx) * (h_value(x1_idx) - 0.5));
                    end
                    
                    gradient_Rm_A = zeros(D); gradient_Rm_B = zeros(1,D); gradient_Rm_C = 0;
                    %parfor p = 1:P
                    for p = 1:P
                        gradient_Rm_A = gradient_Rm_A + weight(p) * data.similar(3,p) * gradient_c_A{p};
                        gradient_Rm_B = gradient_Rm_B + weight(p) * data.similar(3,p) * gradient_c_B{p};
                        gradient_Rm_C = gradient_Rm_C + weight(p) * data.similar(3,p) * gradient_c_C{p};
                    end
                    
                    momentum = min([momentum * 1.01,0.9]); % 动量倍率最大为0.9，初始值为0.5，大约迭代60步之后动量倍率达到0.9。
                    velocity_Rm_A = momentum * velocity_Rm_A + learn_rate_current * gradient_Rm_A;
                    velocity_Rm_B = momentum * velocity_Rm_B + learn_rate_current * gradient_Rm_B;
                    velocity_Rm_C = momentum * velocity_Rm_C + learn_rate_current * gradient_Rm_C;
                    
                    A = A + velocity_Rm_A;
                    B = B + velocity_Rm_B;
                    C = C + velocity_Rm_C;
                end
                
                %Rm_max = sum(weight .* data.similar(3,:) .* sign(c));
                Rm_max = Rm;
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
                
                weight = weight .* exp(-1 * current_alfa * data.similar(3,:) .* sign(c));
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

