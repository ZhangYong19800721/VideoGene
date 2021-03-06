classdef SimilarityPreservingHashL1
    %SimilarityPreservingHashL1 保留相似性的Hash算法（线性分类器）
    %   
    
    properties
        hypothesis;  % 包含若干个弱分类器的cell数组
        alfa;        % 每个弱分类器的投票权值
    end
    
    methods % 构造函数
        function obj = SimilarityPreservingHashL1()
            obj.hypothesis = [];
            obj.alfa = [];
        end
    end
    
    methods
        function obj = train(obj,data,num_weak,select,learn_rate_max,learn_rate_min,max_it,percent)
            if strcmp(select,'supervised')
                obj = train_supervised(obj,data,num_weak,learn_rate_max,learn_rate_min,max_it);
            elseif strcmp(select,'semisupervised')
                obj = train_semisupervised(obj,data,num_weak,learn_rate_max,learn_rate_min,max_it);
            elseif strcmp(select,'semisupervised_partial')
                obj = train_semisupervised_partial(obj,data,num_weak,learn_rate_max,learn_rate_min,max_it,percent);
            else
                disp('error! please choose correct select parameters, "supervised" or "semisupervised"');
            end
        end
        
        function obj = train_semisupervised_partial(obj,data,num_weak,learn_rate_max,learn_rate_min,max_it,percent)
            %train_semisupervised_partial 训练SimilarityPreservingHash模型
            %   输入：
            %   data：训练数据，data.points表示数据点，data.similar包含[i j
            %         s]'，其中i和j表示point数组的下标，s表示两个元素是否相似。
            %         半监督学习只使用标记为相似的数据对。
            %   num_weak：表示弱分类器的个数
            %   max_it:   最大迭代次数
            %   learn_rate_max: 最大学习速度
            %   learn_rate_min: 最小学习速度  
            %   percent: 非标签数据的使用比率

            %   输出：
            %   obj：训练后的SimilarityPreservingHash对象
            
            data.similar = data.similar(:,data.similar(3,:)>0); % 去掉标记为不相似的数据对，只保留标记为相似的数据对
            
            ob_window_size = 100;
            [D,N] = size(data.points);   % D表示数据的维度，N表示数据点个数
            [~,P] = size(data.similar);  % P表示相似数据对的个数
            weight1 = ones(1,P)./(2*P);  % 相似数据对的权值向量
            weight2 = ones(1,N)./(2*N);  % 无标签数据的权值向量
            momentum = 0.5;              % 初始化动量倍率为0.5
            
            K1 = repmat(1:N,N-1,1); K2 = repmat((1:N)',1,N); K3 = diag(1:N); 
            K2 = K2 - K3; K2 = K2(K2~=0); K2 = reshape(K2,N-1,N);
            
            for m = 1:num_weak % 迭代开始
                ob = Observer('observer',2,ob_window_size,'legend'); % 初始化一个观察器
                B = randn(1,D);                    % 将B初始化
                f_func = F_Linear(B,0);            % 初始化f函数
                f_value = f_func.do(data.points);  % 对所有的数据点计算f函数的值
                C = -1 * median(f_value);          % 将C初始化
                f_func = F_Linear(B,C);            % 初始化f函数
                f_value  = f_func.do(data.points); % 对所有的数据点计算f函数的值
                max_f_value = max(f_value);        % 得到最大值
                min_f_value = min(f_value);        % 得到最小值
                r = log((1 - 0.999) / 0.999) / min(abs(max_f_value),abs(min_f_value)); % 初始化gamma的值
                
                % 找到一个使得（3.22）式中的r最大化的弱分类器
                velocity_Rm_B = zeros(size(B));
                velocity_Rm_C = zeros(size(C));
                learn_rate_current = learn_rate_max;                % 学习速度初始化为最大学习速度
                Rm_record = ones(1,ob_window_size); flag = false;   % Rm_record用来记录迭代过程中的Rm值
                
                B_record = repmat(B,1,1,ob_window_size);
                C_record = repmat(C,1,1,ob_window_size);
                Rm_window_ave_max = -inf;
                
                for it = 0:max_it                    
                    f_func = F_Linear(B,C);            % 更新f函数
                    h_func = H_Func(f_func,r);         % 绑定gamma参数，得到h函数（或更新h函数）
                    weak_c = WeakClassifier(h_func);   % 绑定h函数，得到弱分类器（或更新弱分类器）
                    
                    % 对所有的相似数据对执行弱分类      
                    c1 = weak_c.do(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:))); 
                    Rm1 = weight1 * c1';
                    
                    % 对部分的非标签数据执行弱分类
                    Ns = floor(percent * (N-1)); c2 = zeros(Ns,N);  
                    for j = 1:N
                        sequence = randperm(N-1,Ns);
                        c2(:,j) = weak_c.do(data.points(:,K1(sequence,j)),data.points(:,K2(sequence,j)));
                    end
                    Rm2 = weight2 * (sum(c2) ./ Ns)';
                    
                    % 计算Rm值
                    Rm = Rm1 - Rm2;
                    
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
                    
                    B_record(:,:,mod(it,ob_window_size)+1) = B;
                    C_record(:,:,mod(it,ob_window_size)+1) = C;
                    
                    description = strcat('Iteration: ', strcat(strcat(num2str(it),'/'),num2str(max_it)));
                    description = strcat(description, strcat(' LearnRate: ',num2str(learn_rate_current)));
                    description = strcat(description, strcat(' Gama: ',num2str(r)));
                    ob = ob.showit([Rm Rm_window_ave]',description);
                    
                    if mod(it,ob_window_size) == (ob_window_size-1)            % 如果到达窗口的末端
                        if Rm_window_ave < Rm_window_ave_old  % 如果窗口平均值下降(出现震荡)就降低学习速度
                            learn_rate_current = max(0.5 * learn_rate_current,learn_rate_min);
                            [best_Rm,best_idx] = max(Rm_record);
                            B = B_record(:,:,best_idx);
                            C = C_record(:,:,best_idx);
                            Rm_window_ave_old = Rm_window_ave;
                            continue;
                        else
                            if Rm_window_ave > Rm_window_ave_max
                                r = 1.1 * r;
                                Rm_window_ave_max = Rm_window_ave;
                            end
                            
                            if Rm_window_ave - Rm_window_ave_old < 1e-4
                                % 如果达到最大迭代次数Rm也不会增加超过当前值的1/100就缩减学习速度
                                learn_rate_current = max(0.5 * learn_rate_current,learn_rate_min);
                            end
                            Rm_window_ave_old = Rm_window_ave;
                        end
                    end
                    
                    % 计算梯度
                    h_value       = h_func.do(data.points);         % 计算所有数据点的h函数值
                    gradient_h_C  = h_value .* (h_value - 1) * r;   % 计算h函数对C的偏导数
                    
                    gradient_h_B = cell(1,N);
                    for n = 1:N 
                        gradient_h_B{n} = gradient_h_C(n) * data.points(:,n)';                    % 计算h函数对B的偏导数
                    end
                    
                    gradient_Rm1_B = zeros(1,D); gradient_Rm1_C = 0;
                    for p = 1:P
                        x1_idx = data.similar(1,p); x2_idx = data.similar(2,p);
                        % 计算c函数对B、C的偏导数
                        gradient_c_B = 4 * (gradient_h_B{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_B{x2_idx} * (h_value(x1_idx) - 0.5));
                        gradient_c_C = 4 * (gradient_h_C(x1_idx) * (h_value(x2_idx) - 0.5) + gradient_h_C(x2_idx) * (h_value(x1_idx) - 0.5));
                    
                        gradient_Rm1_B = gradient_Rm1_B + weight1(p) * gradient_c_B;
                        gradient_Rm1_C = gradient_Rm1_C + weight1(p) * gradient_c_C;
                    end
                    
                    gradient_Rm2_B = zeros(1,D); gradient_Rm2_C = 0; % 初始化Rm2对B、C的梯度值
                    for j = 1:N
                        gradient_Q_B = zeros(1,D); gradient_Q_C = 0;
                        sequence = randperm(N-1,Ns); 
                        for i = sequence
                            x1_idx = K1(i,j); x2_idx = K2(i,j);
                            gradient_c_B = 4 * (gradient_h_B{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_B{x2_idx} * (h_value(x1_idx) - 0.5)); 
                            gradient_c_C = 4 * (gradient_h_C(x1_idx) * (h_value(x2_idx) - 0.5) + gradient_h_C(x2_idx) * (h_value(x1_idx) - 0.5));
                            
                            gradient_Q_B = gradient_Q_B + gradient_c_B;
                            gradient_Q_C = gradient_Q_C + gradient_c_C;
                        end
                        
                        gradient_Rm2_B = gradient_Rm2_B + weight2(j) * gradient_Q_B / Ns;
                        gradient_Rm2_C = gradient_Rm2_C + weight2(j) * gradient_Q_C / Ns;
                    end
                    
                    gradient_Rm_B = gradient_Rm1_B - gradient_Rm2_B; 
                    gradient_Rm_C = gradient_Rm1_C - gradient_Rm2_C;
                    
                    momentum = min([momentum * 1.01,0.9]); % 动量倍率最大为0.9，初始值为0.5，大约迭代60步之后动量倍率达到0.9。
                    velocity_Rm_B = momentum * velocity_Rm_B + learn_rate_current * gradient_Rm_B;
                    velocity_Rm_C = momentum * velocity_Rm_C + learn_rate_current * gradient_Rm_C;
                    
                    B = B + velocity_Rm_B;
                    C = C + velocity_Rm_C;
                end
                
                Rm_max = weight1 * sign(c1)' - weight2 * (sum(sign(c2)) ./ Ns)';
                if Rm_max >= 1
                    obj.hypothesis{1+length(obj.hypothesis)} = h_func;
                    obj.alfa = [obj.alfa 1];
                    break;
                elseif Rm_max <= 0
                    break;                   
                else
                    current_alfa = 0.5 * log((1+Rm_max)/(1-Rm_max));
                    % current_alfa = 1;
                end
                
                obj.hypothesis{1+length(obj.hypothesis)} = h_func;
                obj.alfa = [obj.alfa current_alfa];
                
                weight1 = weight1 .* exp(-1 * current_alfa * sign(c1));
                weight1 = weight1 ./ (2 * sum(weight1));
                
                weight2 = weight2 .* exp(current_alfa * sum(sign(c2)) ./ Ns);
                weight2 = weight2 ./ (2 * sum(weight2));
            end
        end
        
        function obj = train_semisupervised(obj,data,num_weak,learn_rate_max,learn_rate_min,max_it)
            %train_semisupervised 训练SimilarityPreservingHash模型
            %   输入：
            %   data：训练数据，data.points表示数据点，data.similar包含[i j
            %         s]'，其中i和j表示point数组的下标，s表示两个元素是否相似。
            %         半监督学习只使用标记为相似的数据对。
            %   num_weak：表示弱分类器的个数
            %   max_it = 1e4;                % 最大迭代次数
            %   learn_rate_max = 1e-1;       % 最大学习速度
            %   learn_rate_min = 1e-6;       % 最小学习速度    
            %
            %   输出：
            %   obj：训练后的SimilarityPreservingHash对象
            
            data.similar = data.similar(:,data.similar(3,:)>0); % 去掉标记为不相似的数据对，只保留标记为相似的数据对
            
            ob_window_size = 100;
            [D,N] = size(data.points);   % D表示数据的维度，N表示数据点个数
            [~,P] = size(data.similar);  % P表示相似数据对的个数
            weight1 = ones(1,P)./(2*P);  % 相似数据对的权值向量
            weight2 = ones(1,N)./(2*N);  % 无标签数据的权值向量         
            momentum = 0.5;              % 初始化动量倍率为0.5
            
            for m = 1:num_weak % 迭代开始
                ob = Observer('observer',2,ob_window_size,'legend'); % 初始化一个观察器
                B = randn(1,D);                    % 将B初始化
                f_func = F_Linear(B,0);            % 初始化f函数
                f_value = f_func.do(data.points);  % 对所有的数据点计算f函数的值
                C = -1 * median(f_value);          % 将C初始化
                f_func = F_Linear(B,C);            % 初始化f函数
                f_value  = f_func.do(data.points); % 对所有的数据点计算f函数的值
                max_f_value = max(f_value);        % 得到最大值
                min_f_value = min(f_value);        % 得到最小值
                r = log((1 - 0.999) / 0.999) / min(abs(max_f_value),abs(min_f_value)); % 初始化gamma的值
                
                % 找到一个使得（3.22）式中的r最大化的弱分类器
                velocity_Rm_B = zeros(size(B));
                velocity_Rm_C = zeros(size(C));
                learn_rate_current = learn_rate_max;                % 学习速度初始化为最大学习速度
                Rm_record = ones(1,ob_window_size); flag = false;   % Rm_record用来记录迭代过程中的Rm值
                
                B_record = repmat(B,1,1,ob_window_size);
                C_record = repmat(C,1,1,ob_window_size);
                Rm_window_ave_max = -inf;
                
                for it = 0:max_it                    
                    f_func = F_Linear(B,C);            % 更新f函数
                    h_func = H_Func(f_func,r);         % 绑定gamma参数，得到h函数（或更新h函数）
                    weak_c = WeakClassifier(h_func);   % 绑定h函数，得到弱分类器（或更新弱分类器）
                    
                    % 对所有的相似数据对执行弱分类
                    c1 = weak_c.do(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:))); 
                    Rm1 = weight1 * c1';
                    
                    % 对所有的非标签数据执行弱分类
                    c2 = zeros(N-1,N);
                    for j = 1:N
                        sequence = [1:(j-1) (j+1):N];
                        c2(:,j) = weak_c.do(data.points(:,j*ones(1,N-1)),data.points(:,sequence)); 
                    end
                    Rm2 = weight2 * (sum(c2) ./ (N-1))';
                    
                    % 计算Rm值
                    Rm = Rm1 - Rm2;
                    
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
                    
                    B_record(:,:,mod(it,ob_window_size)+1) = B;
                    C_record(:,:,mod(it,ob_window_size)+1) = C;
                    
                    description = strcat('Iteration: ', strcat(strcat(num2str(it),'/'),num2str(max_it)));
                    description = strcat(description, strcat(' LearnRate: ',num2str(learn_rate_current)));
                    description = strcat(description, strcat(' Gama: ',num2str(r)));
                    ob = ob.showit([Rm Rm_window_ave]',description);
                    
                    if mod(it,ob_window_size) == (ob_window_size-1)  % 如果到达窗口的末端
                        if Rm_window_ave < Rm_window_ave_old % 如果窗口平均值下降(出现震荡)就降低学习速度
                            learn_rate_current = max(0.5 * learn_rate_current,learn_rate_min);
                            [best_Rm,best_idx] = max(Rm_record);
                            B = B_record(:,:,best_idx);
                            C = C_record(:,:,best_idx);
                            Rm_window_ave_old = Rm_window_ave;
                            continue;
                        else
                            if Rm_window_ave > Rm_window_ave_max
                                r = 1.1 * r;
                                Rm_window_ave_max = Rm_window_ave;
                            end
                            
                            if Rm_window_ave - Rm_window_ave_old < 1e-4
                                % 如果达到最大迭代次数Rm也不会增加超过当前值的1/100就缩减学习速度
                                learn_rate_current = max(0.5 * learn_rate_current,learn_rate_min);
                            end
                            Rm_window_ave_old = Rm_window_ave;
                        end
                    end

                    % 计算梯度
                    h_value       = h_func.do(data.points);         % 计算所有数据点的h函数值
                    gradient_h_C  = h_value .* (h_value - 1) * r;   % 计算h函数对C的偏导数
                    
                    %parfor n = 1:N 
                    gradient_h_B = cell(1,N);
                    for n = 1:N 
                        gradient_h_B{n} = gradient_h_C(n) * data.points(:,n)';                    % 计算h函数对B的偏导数
                    end
                    
                    gradient_Rm1_B = zeros(1,D); gradient_Rm1_C = 0;
                    for p = 1:P
                        i = data.similar(1,p); j = data.similar(2,p);
                        % 计算c函数对B、C的偏导数
                        gradient_c_B = 4 * (gradient_h_B{i} * (h_value(j) - 0.5) + gradient_h_B{j} * (h_value(i) - 0.5));
                        gradient_c_C = 4 * (gradient_h_C(i) * (h_value(j) - 0.5) + gradient_h_C(j) * (h_value(i) - 0.5));
                    
                        gradient_Rm1_B = gradient_Rm1_B + weight1(p) * gradient_c_B;
                        gradient_Rm1_C = gradient_Rm1_C + weight1(p) * gradient_c_C;
                    end
                    
                    gradient_Rm2_B = zeros(1,D); gradient_Rm2_C = 0; % 初始化Rm2对B、C的梯度值
                    for j = 1:N
                        gradient_Q_B = zeros(1,D); gradient_Q_C = 0;
                        sequence = [1:(j-1) (j+1):N];
                        for i = sequence
                            gradient_c_B = 4 * (gradient_h_B{j} * (h_value(i) - 0.5) + gradient_h_B{i} * (h_value(j) - 0.5)); 
                            gradient_c_C = 4 * (gradient_h_C(j) * (h_value(i) - 0.5) + gradient_h_C(i) * (h_value(j) - 0.5));
                            
                            gradient_Q_B = gradient_Q_B + gradient_c_B;
                            gradient_Q_C = gradient_Q_C + gradient_c_C;
                        end
                        
                        gradient_Rm2_B = gradient_Rm2_B + weight2(j) * gradient_Q_B / (N-1);
                        gradient_Rm2_C = gradient_Rm2_C + weight2(j) * gradient_Q_C / (N-1);
                    end
                    
                    gradient_Rm_B = gradient_Rm1_B - gradient_Rm2_B; 
                    gradient_Rm_C = gradient_Rm1_C - gradient_Rm2_C;
                    
                    momentum = min([momentum * 1.01,0.9]); % 动量倍率最大为0.9，初始值为0.5，大约迭代60步之后动量倍率达到0.9。
                    velocity_Rm_B = momentum * velocity_Rm_B + learn_rate_current * gradient_Rm_B;
                    velocity_Rm_C = momentum * velocity_Rm_C + learn_rate_current * gradient_Rm_C;
                    
                    B = B + velocity_Rm_B;
                    C = C + velocity_Rm_C;
                end
                
                Rm_max = weight1 * sign(c1)' - weight2 * (sum(sign(c2)) ./ (N-1))';
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
                
                weight1 = weight1 .* exp(-1 * current_alfa * sign(c1));
                weight1 = weight1 ./ (2 * sum(weight1));
                
                weight2 = weight2 .* exp(current_alfa * sum(sign(c2)) / (N-1));
                weight2 = weight2 ./ (2 * sum(weight2));
            end
        end
        
        function obj = train_supervised(obj,data,num_classifier,learn_rate_max,learn_rate_min,max_it)
            %train_supervised 训练SimilarityPreservingHash模型
            %   输入：
            %   data：训练数据，data.points表示数据点，data.similar包含[i j
            %         s]'，其中i和j表示point数组的下标，s表示两个元素是否相似
            %   num_weak：表示弱分类器的个数
            %   max_it = 1e4;                % 最大迭代次数
            %   learn_rate_max = 1e-1;       % 最大学习速度
            %   learn_rate_min = 1e-6;       % 最小学习速度  
            %
            %   输出：
            %   obj：训练后的SimilarityPreservingHash对象
            
            ob_window_size = 100;
            [D,N] = size(data.points);   % D表示数据的维度，N表示数据点个数
            [~,P] = size(data.similar);  % P表示数据对的个数
            weight = ones(1,P) ./ P;     % 权值向量
            momentum = 0.5;              % 初始化动量倍率为0.5
            
            for classifier_idx = 1:num_classifier % 迭代开始
                ob = Observer('R_Value',2,ob_window_size,'legend'); % 初始化一个观察器
                B = randn(1,D);                    % 将B初始化
                f_func = F_Linear(B,0);            % 初始化f函数
                f_value = f_func.do(data.points);  % 对所有的数据点计算f函数的值
                C = -1 * median(f_value);          % 将C初始化
                f_func = F_Linear(B,C);            % 初始化f函数
                f_value  = f_func.do(data.points); % 对所有的数据点计算f函数的值
                max_f_value = max(f_value);        % 得到最大值
                min_f_value = min(f_value);        % 得到最小值
                %gama = log((1 - 0.999) / 0.999) / min(abs(max_f_value),abs(min_f_value)); % 初始化gama的值
                gama = 0.1;
                
                % 找到一个使得（3.22）式中的r最大化的弱分类器
                velocity_r_B = zeros(size(B));
                velocity_r_C = zeros(size(C));
                learn_rate = learn_rate_max;                % 学习速度初始化为最大学习速度
                flag = false;                               % r_list用来记录迭代过程中的r值
                
                B_record = repmat(B,1,1,ob_window_size);
                C_record = repmat(C,1,1,ob_window_size);
                r_ave_max = -inf;
 
                for it = 0:max_it                    
                    f_func = F_Linear(B,C);                  % 更新f函数
                    h_func = F_Sigmoid(f_func,gama);         % 绑定gama参数，得到h函数（或更新h函数）
                    weak_c = WeakClassifier(h_func);         % 绑定h函数，得到弱分类器（或更新弱分类器）
                    c = weak_c.do(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
                    r = weight * (data.similar(3,:) .* c)';
                    
                    if learn_rate == learn_rate_min 
                        break; % 当学习速度下降到最小学习速度时，停止迭代
                    end
                    
                    if flag == false
                        r_list = r * ones(1,ob_window_size);   % 利用第一次计算得到的r值初始化r_list
                        r_ave_old = r - 100;                   % 初始化旧的窗口平均值
                        flag = true;
                    end
                    
                    r_list(mod(it,ob_window_size)+1) = r; % 记录当前的r值到r_list中
                    r_ave_new = mean(r_list);          % 计算r的平均值
                    
                    B_record(:,:,mod(it,ob_window_size)+1) = B;
                    C_record(:,:,mod(it,ob_window_size)+1) = C;
                    
                    description = strcat('迭代次数: ', strcat(strcat(num2str(it),'/'),num2str(max_it)));
                    description = strcat(description, strcat(' 学习速率: ',num2str(learn_rate)));
                    description = strcat(description, strcat(' 目标函数: ',num2str(r)));
                    description = strcat(description, strcat(' Gama: ',num2str(gama)));
                    ob = ob.showit([r r_ave_new]',description);
                    
                    if mod(it,ob_window_size) == (ob_window_size-1)  % 如果到达窗口的末端
                        if r_ave_new < r_ave_old  % 如果窗口平均值下降(出现震荡)就降低学习速度
                            learn_rate = max(0.5 * learn_rate,learn_rate_min);
                            [best_r,best_i] = max(r_list);
                            B = B_record(:,:,best_i);
                            C = C_record(:,:,best_i);
                            r_ave_old = r_ave_new;
                            continue;
                        else
%                             if r_ave_new > r_ave_max
%                                 gama = 1.1 * gama;
%                                 r_ave_max = r_ave_new;
%                             end
                            
                            if r_ave_new - r_ave_old < 1e-4
                                % 如果达到最大迭代次数Rm也不会增加超过当前值的1/100就缩减学习速度
                                learn_rate = max(0.5 * learn_rate,learn_rate_min);
                            end
                            r_ave_old = r_ave_new;
                        end
                    end
                    
                    % 计算梯度
                    h_value = h_func.do(data.points); % 计算所有数据点的h函数值
                    gradient_h = h_value .* (h_value - 1) .* gama; % 准备计算h函数的偏导数
                    
                    gradient_h_B = repmat(gradient_h',1,D) .* data.points'; % 计算h函数对B的偏导数
                    gradient_h_C = gradient_h'; % 计算h函数对C的偏导数
                    
                    gradient_c_B = 4 * (gradient_h_B(data.similar(1,:),:) .* repmat((h_value(data.similar(2,:)) - 0.5)',1,D) + ...
                                        gradient_h_B(data.similar(2,:),:) .* repmat((h_value(data.similar(1,:)) - 0.5)',1,D));
                    gradient_c_C = 4 * (gradient_h_C(data.similar(1,:)) .* (h_value(data.similar(2,:)) - 0.5)' + ...
                                        gradient_h_C(data.similar(2,:)) .* (h_value(data.similar(1,:)) - 0.5)');
                    
                    gradient_r_B = sum(repmat((weight .* data.similar(3,:))',1,D) .* gradient_c_B); 
                    gradient_r_C = (weight .* data.similar(3,:)) * gradient_c_C;
                    
                    momentum = min([momentum * 1.01,0.9]); % 动量倍率最大为0.9，初始值为0.5，大约迭代60步之后动量倍率达到0.9。
                    velocity_r_B = momentum * velocity_r_B + learn_rate * gradient_r_B;
                    velocity_r_C = momentum * velocity_r_C + learn_rate * gradient_r_C;
                    
                    B = B + velocity_r_B;
                    C = C + velocity_r_C;
                end
                
                r_max = sum(weight .* data.similar(3,:) .* sign(c));
                if r_max >= 1
                    obj.hypothesis{1+length(obj.hypothesis)} = h_func;
                    obj.alfa = [obj.alfa 1];
                    break;
                elseif r_max <= 0
                    break;                   
                else
                    alfa = 0.5 * log((1+r_max)/(1-r_max));
                end
                
                obj.hypothesis{1+length(obj.hypothesis)} = h_func;
                obj.alfa = [obj.alfa alfa];
                
                weight = weight .* exp(-1 * alfa * data.similar(3,:) .* sign(c));
                weight = weight ./ sum(weight);
            end
        end
        
        function obj = sort(obj)
            M = length(obj.alfa);
            [obj.alfa,idx] = sort(obj.alfa,'descend');
            [obj.hypothesis{1:M}] = obj.hypothesis{idx};
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

