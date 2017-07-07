classdef SimilarityPreservingHashL2
    %SimilarityPreservingHashL2 ���������Ե�Hash�㷨�����׶���ʽ��������
    %   
    
    properties
        hypothesis;  % �������ɸ�����������cell����
        alfa;        % ÿ������������ͶƱȨֵ
    end
    
    methods % ���캯��
        function obj = SimilarityPreservingHashL2()
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
            %train_semisupervised_partial ѵ��SimilarityPreservingHashģ��
            %   ���룺
            %   data��ѵ�����ݣ�data.points��ʾ���ݵ㣬data.similar����[i j
            %         s]'������i��j��ʾpoint������±꣬s��ʾ����Ԫ���Ƿ����ơ�
            %         ��ලѧϰֻʹ�ñ��Ϊ���Ƶ����ݶԡ�
            %   num_weak����ʾ���������ĸ���
            %   max_it:   ����������
            %   learn_rate_max: ���ѧϰ�ٶ�
            %   learn_rate_min: ��Сѧϰ�ٶ�  
            %   percent: �Ǳ�ǩ���ݵ�ʹ�ñ���

            %   �����
            %   obj��ѵ�����SimilarityPreservingHash����
            
            data.similar = data.similar(:,data.similar(3,:)>0); % ȥ�����Ϊ�����Ƶ����ݶԣ�ֻ�������Ϊ���Ƶ����ݶ�
            
            ob_window_size = 100;
            [D,N] = size(data.points);   % D��ʾ���ݵ�ά�ȣ�N��ʾ���ݵ����
            [~,P] = size(data.similar);  % P��ʾ�������ݶԵĸ���
            weight1 = ones(1,P)./(2*P);  % �������ݶԵ�Ȩֵ����
            weight2 = ones(1,N)./(2*N);  % �ޱ�ǩ���ݵ�Ȩֵ����
            momentum = 0.5;              % ��ʼ����������Ϊ0.5
            
            K1 = repmat(1:N,N-1,1); K2 = repmat((1:N)',1,N); K3 = diag(1:N); 
            K2 = K2 - K3; K2 = K2(K2~=0); K2 = reshape(K2,N-1,N);
            
            for m = 1:num_weak % ������ʼ
                ob = Observer('observer',2,ob_window_size,'legend'); % ��ʼ��һ���۲���
                A = randn(D);                      % ��A��ʼ��Ϊһ��ȫ0����
                B = randn(1,D);                    % ��B��ʼ��
                f_func = F_Quadratic(A,B,0);       % ��ʼ��f����
                f_value = f_func.do(data.points);  % �����е����ݵ����f������ֵ
                C = -1 * median(f_value);          % ��C��ʼ��
                f_func = F_Quadratic(A,B,C);       % ��ʼ��f����
                f_value  = f_func.do(data.points); % �����е����ݵ����f������ֵ
                max_f_value = max(f_value);        % �õ����ֵ
                min_f_value = min(f_value);        % �õ���Сֵ
                r = log((1 - 0.999) / 0.999) / min(abs(max_f_value),abs(min_f_value)); % ��ʼ��gamma��ֵ
                
                % �ҵ�һ��ʹ�ã�3.22��ʽ�е�r��󻯵���������
                velocity_Rm_A = zeros(size(A));
                velocity_Rm_B = zeros(size(B));
                velocity_Rm_C = zeros(size(C));
                learn_rate_current = learn_rate_max;                % ѧϰ�ٶȳ�ʼ��Ϊ���ѧϰ�ٶ�
                Rm_record = ones(1,ob_window_size); flag = false;   % Rm_record������¼���������е�Rmֵ
                
                for it = 0:max_it                    
                    f_func = F_Quadratic(A,B,C);       % ����f����
                    h_func = H_Func(f_func,r);         % ��gamma�������õ�h�����������h������
                    weak_c = WeakClassifier(h_func);   % ��h�������õ��������������������������
                    
                    % �����е��������ݶ�ִ��������      
                    c1 = weak_c.do(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:))); 
                    Rm1 = weight1 * c1';
                    
                    % �Բ��ֵķǱ�ǩ����ִ��������
                    Ns = floor(percent * (N-1)); c2 = zeros(Ns,N);  
                    for j = 1:N
                        sequence = randperm(N-1,Ns);
                        c2(:,j) = weak_c.do(data.points(:,K1(sequence,j)),data.points(:,K2(sequence,j)));
                    end
                    Rm2 = weight2 * (sum(c2) ./ Ns)';
                    
                    % ����Rmֵ
                    Rm = Rm1 - Rm2;
                    
                    if learn_rate_current == learn_rate_min 
                        break; % ��ѧϰ�ٶ��½�����Сѧϰ�ٶ�ʱ��ֹͣ����
                    end
                    
                    if flag == false
                        Rm_record = Rm * Rm_record;   % ���õ�һ�μ���õ���Rmֵ��ʼ��Rm_record
                        Rm_window_ave_old = Rm - 100; % ��ʼ���ɵĴ���ƽ��ֵ
                        flag = true;
                    end
                    
                    Rm_record(mod(it,ob_window_size)+1) = Rm; % ��¼��ǰ��Rmֵ��Rm_record������
                    Rm_window_ave = mean(Rm_record);          % ����Rm�Ĵ���ƽ��ֵ
                    
                    description = strcat('Iteration: ', strcat(strcat(num2str(it),'/'),num2str(max_it)));
                    description = strcat(description, strcat(' LearnRate: ',num2str(learn_rate_current)));
                    description = strcat(description, strcat(' Gama: ',num2str(r)));
                    ob = ob.showit([Rm Rm_window_ave]',description);
                    
                    if mod(it,ob_window_size) == (ob_window_size-1)            % ������ﴰ�ڵ�ĩ��
                        if Rm_window_ave - Rm_window_ave_old < 0
                            % ����ﵽ����������RmҲ�������ӳ�����ǰֵ��1/100������ѧϰ�ٶ�
                            learn_rate_current = max(0.5 * learn_rate_current,learn_rate_min);
                        end
                        Rm_window_ave_old = Rm_window_ave;
                    end
                    
                    % �����ݶ�
                    h_value       = h_func.do(data.points);         % �����������ݵ��h����ֵ
                    gradient_h_C  = h_value .* (h_value - 1) * r;   % ����h������C��ƫ����
                    
                    gradient_h_A = cell(1,N); gradient_h_B = cell(1,N);
                    for n = 1:N 
                        gradient_h_A{n} = gradient_h_C(n) * data.points(:,n) * data.points(:,n)'; % ����h������A��ƫ����
                        gradient_h_B{n} = gradient_h_C(n) * data.points(:,n)';                    % ����h������B��ƫ����
                    end
                    
                    gradient_Rm1_A = zeros(D); gradient_Rm1_B = zeros(1,D); gradient_Rm1_C = 0;
                    for p = 1:P
                        x1_idx = data.similar(1,p); x2_idx = data.similar(2,p);
                        % ����c������A��B��C��ƫ����
                        gradient_c_A = 4 * (gradient_h_A{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_A{x2_idx} * (h_value(x1_idx) - 0.5));
                        gradient_c_B = 4 * (gradient_h_B{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_B{x2_idx} * (h_value(x1_idx) - 0.5));
                        gradient_c_C = 4 * (gradient_h_C(x1_idx) * (h_value(x2_idx) - 0.5) + gradient_h_C(x2_idx) * (h_value(x1_idx) - 0.5));
                    
                        gradient_Rm1_A = gradient_Rm1_A + weight1(p) * gradient_c_A;
                        gradient_Rm1_B = gradient_Rm1_B + weight1(p) * gradient_c_B;
                        gradient_Rm1_C = gradient_Rm1_C + weight1(p) * gradient_c_C;
                    end
                    
                    gradient_Rm2_A = zeros(D); gradient_Rm2_B = zeros(1,D); gradient_Rm2_C = 0; % ��ʼ��Rm2��A��B��C���ݶ�ֵ
                    for j = 1:N
                        gradient_Q_A = zeros(D); gradient_Q_B = zeros(1,D); gradient_Q_C = 0;
                        sequence = randperm(N-1,Ns); 
                        for i = sequence
                            x1_idx = K1(i,j); x2_idx = K2(i,j);
                            gradient_c_A = 4 * (gradient_h_A{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_A{x2_idx} * (h_value(x1_idx) - 0.5)); 
                            gradient_c_B = 4 * (gradient_h_B{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_B{x2_idx} * (h_value(x1_idx) - 0.5)); 
                            gradient_c_C = 4 * (gradient_h_C(x1_idx) * (h_value(x2_idx) - 0.5) + gradient_h_C(x2_idx) * (h_value(x1_idx) - 0.5));
                            
                            gradient_Q_A = gradient_Q_A + gradient_c_A;
                            gradient_Q_B = gradient_Q_B + gradient_c_B;
                            gradient_Q_C = gradient_Q_C + gradient_c_C;
                        end
                        
                        gradient_Rm2_A = gradient_Rm2_A + weight2(j) * gradient_Q_A / Ns;
                        gradient_Rm2_B = gradient_Rm2_B + weight2(j) * gradient_Q_B / Ns;
                        gradient_Rm2_C = gradient_Rm2_C + weight2(j) * gradient_Q_C / Ns;
                    end
                    
                    gradient_Rm_A = gradient_Rm1_A - gradient_Rm2_A; 
                    gradient_Rm_B = gradient_Rm1_B - gradient_Rm2_B; 
                    gradient_Rm_C = gradient_Rm1_C - gradient_Rm2_C;
                    
                    momentum = min([momentum * 1.01,0.9]); % �����������Ϊ0.9����ʼֵΪ0.5����Լ����60��֮�������ʴﵽ0.9��
                    velocity_Rm_A = momentum * velocity_Rm_A + learn_rate_current * gradient_Rm_A;
                    velocity_Rm_B = momentum * velocity_Rm_B + learn_rate_current * gradient_Rm_B;
                    velocity_Rm_C = momentum * velocity_Rm_C + learn_rate_current * gradient_Rm_C;
                    
                    A = A + velocity_Rm_A;
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
            %train_semisupervised ѵ��SimilarityPreservingHashģ��
            %   ���룺
            %   data��ѵ�����ݣ�data.points��ʾ���ݵ㣬data.similar����[i j
            %         s]'������i��j��ʾpoint������±꣬s��ʾ����Ԫ���Ƿ����ơ�
            %         ��ලѧϰֻʹ�ñ��Ϊ���Ƶ����ݶԡ�
            %   num_weak����ʾ���������ĸ���
            %   max_it = 1e4;                % ����������
            %   learn_rate_max = 1e-1;       % ���ѧϰ�ٶ�
            %   learn_rate_min = 1e-6;       % ��Сѧϰ�ٶ�    
            %
            %   �����
            %   obj��ѵ�����SimilarityPreservingHash����
            
            data.similar = data.similar(:,data.similar(3,:)>0); % ȥ�����Ϊ�����Ƶ����ݶԣ�ֻ�������Ϊ���Ƶ����ݶ�
            
            ob_window_size = 100;
            [D,N] = size(data.points);   % D��ʾ���ݵ�ά�ȣ�N��ʾ���ݵ����
            [~,P] = size(data.similar);  % P��ʾ�������ݶԵĸ���
            weight1 = ones(1,P)./(2*P);  % �������ݶԵ�Ȩֵ����
            weight2 = ones(1,N)./(2*N);  % �ޱ�ǩ���ݵ�Ȩֵ����         
            momentum = 0.5;              % ��ʼ����������Ϊ0.5
            
            K1 = repmat(1:N,N-1,1); K2 = repmat((1:N)',1,N); K3 = diag(1:N); 
            K2 = K2 - K3; K2 = K2(K2~=0); K2 = reshape(K2,N-1,N);
            
            for m = 1:num_weak % ������ʼ
                ob = Observer('observer',2,ob_window_size,'legend'); % ��ʼ��һ���۲���
                A = randn(D);                      % ��A��ʼ��Ϊһ��ȫ0����
                B = randn(1,D);                    % ��B��ʼ��
                f_func = F_Quadratic(A,B,0);       % ��ʼ��f����
                f_value = f_func.do(data.points);  % �����е����ݵ����f������ֵ
                C = -1 * median(f_value);          % ��C��ʼ��
                f_func = F_Quadratic(A,B,C);       % ��ʼ��f����
                f_value  = f_func.do(data.points); % �����е����ݵ����f������ֵ
                max_f_value = max(f_value);        % �õ����ֵ
                min_f_value = min(f_value);        % �õ���Сֵ
                r = log((1 - 0.999) / 0.999) / min(abs(max_f_value),abs(min_f_value)); % ��ʼ��gamma��ֵ
                
                % �ҵ�һ��ʹ�ã�3.22��ʽ�е�r��󻯵���������
                velocity_Rm_A = zeros(size(A));
                velocity_Rm_B = zeros(size(B));
                velocity_Rm_C = zeros(size(C));
                learn_rate_current = learn_rate_max;                % ѧϰ�ٶȳ�ʼ��Ϊ���ѧϰ�ٶ�
                Rm_record = ones(1,ob_window_size); flag = false;   % Rm_record������¼���������е�Rmֵ
                
                for it = 0:max_it                    
                    f_func = F_Quadratic(A,B,C);       % ����f����
                    h_func = H_Func(f_func,r);         % ��gamma�������õ�h�����������h������
                    weak_c = WeakClassifier(h_func);   % ��h�������õ��������������������������
                    
                    % �����е��������ݶ�ִ��������
                    c1 = weak_c.do(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:))); 
                    Rm1 = weight1 * c1';
                    
                    % �����еķǱ�ǩ����ִ��������
                    c2 = zeros(N-1,N);
                    for j = 1:N
                        c2(:,j) = weak_c.do(data.points(:,K1(:,j)),data.points(:,K2(:,j))); 
                    end
                    Rm2 = weight2 * (sum(c2) ./ (N-1))';
                    
                    % ����Rmֵ
                    Rm = Rm1 - Rm2;
                    
                    if learn_rate_current == learn_rate_min 
                        break; % ��ѧϰ�ٶ��½�����Сѧϰ�ٶ�ʱ��ֹͣ����
                    end
                    
                    if flag == false
                        Rm_record = Rm * Rm_record;   % ���õ�һ�μ���õ���Rmֵ��ʼ��Rm_record
                        Rm_window_ave_old = Rm - 100; % ��ʼ���ɵĴ���ƽ��ֵ
                        flag = true;
                    end
                    
                    Rm_record(mod(it,ob_window_size)+1) = Rm; % ��¼��ǰ��Rmֵ��Rm_record������
                    Rm_window_ave = mean(Rm_record);          % ����Rm�Ĵ���ƽ��ֵ
                    
                    description = strcat('Iteration: ', strcat(strcat(num2str(it),'/'),num2str(max_it)));
                    description = strcat(description, strcat(' LearnRate: ',num2str(learn_rate_current)));
                    description = strcat(description, strcat(' Gama: ',num2str(r)));
                    ob = ob.showit([Rm Rm_window_ave]',description);
                    
                    if mod(it,ob_window_size) == (ob_window_size-1)  % ������ﴰ�ڵ�ĩ��
                        if Rm_window_ave - Rm_window_ave_old < 1e-4
                            % ����ﵽ����������RmҲ�������ӳ�����ǰֵ��1/100������ѧϰ�ٶ�
                            learn_rate_current = max(0.5 * learn_rate_current,learn_rate_min);
                        end
                        Rm_window_ave_old = Rm_window_ave;
                    end

                    % �����ݶ�
                    h_value       = h_func.do(data.points);         % �����������ݵ��h����ֵ
                    gradient_h_C  = h_value .* (h_value - 1) * r;   % ����h������C��ƫ����
                    
                    %parfor n = 1:N 
                    gradient_h_A = cell(1,N); gradient_h_B = cell(1,N);
                    for n = 1:N 
                        gradient_h_A{n} = gradient_h_C(n) * data.points(:,n) * data.points(:,n)'; % ����h������A��ƫ����
                        gradient_h_B{n} = gradient_h_C(n) * data.points(:,n)';                    % ����h������B��ƫ����
                    end
                    
                    gradient_Rm1_A = zeros(D); gradient_Rm1_B = zeros(1,D); gradient_Rm1_C = 0;
                    for p = 1:P
                        x1_idx = data.similar(1,p); x2_idx = data.similar(2,p);
                        % ����c������A��B��C��ƫ����
                        gradient_c_A = 4 * (gradient_h_A{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_A{x2_idx} * (h_value(x1_idx) - 0.5));
                        gradient_c_B = 4 * (gradient_h_B{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_B{x2_idx} * (h_value(x1_idx) - 0.5));
                        gradient_c_C = 4 * (gradient_h_C(x1_idx) * (h_value(x2_idx) - 0.5) + gradient_h_C(x2_idx) * (h_value(x1_idx) - 0.5));
                    
                        gradient_Rm1_A = gradient_Rm1_A + weight1(p) * gradient_c_A;
                        gradient_Rm1_B = gradient_Rm1_B + weight1(p) * gradient_c_B;
                        gradient_Rm1_C = gradient_Rm1_C + weight1(p) * gradient_c_C;
                    end
                    
                    gradient_Rm2_A = zeros(D); gradient_Rm2_B = zeros(1,D); gradient_Rm2_C = 0; % ��ʼ��Rm2��A��B��C���ݶ�ֵ
                    for j = 1:N
                        gradient_Q_A = zeros(D); gradient_Q_B = zeros(1,D); gradient_Q_C = 0;
                        for i = 1:(N-1)
                            x1_idx = K1(i,j); x2_idx = K2(i,j);
                            gradient_c_A = 4 * (gradient_h_A{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_A{x2_idx} * (h_value(x1_idx) - 0.5)); 
                            gradient_c_B = 4 * (gradient_h_B{x1_idx} * (h_value(x2_idx) - 0.5) + gradient_h_B{x2_idx} * (h_value(x1_idx) - 0.5)); 
                            gradient_c_C = 4 * (gradient_h_C(x1_idx) * (h_value(x2_idx) - 0.5) + gradient_h_C(x2_idx) * (h_value(x1_idx) - 0.5));
                            
                            gradient_Q_A = gradient_Q_A + gradient_c_A;
                            gradient_Q_B = gradient_Q_B + gradient_c_B;
                            gradient_Q_C = gradient_Q_C + gradient_c_C;
                        end
                        
                        gradient_Rm2_A = gradient_Rm2_A + weight2(j) * gradient_Q_A / (N-1);
                        gradient_Rm2_B = gradient_Rm2_B + weight2(j) * gradient_Q_B / (N-1);
                        gradient_Rm2_C = gradient_Rm2_C + weight2(j) * gradient_Q_C / (N-1);
                    end
                    
                    gradient_Rm_A = gradient_Rm1_A - gradient_Rm2_A; 
                    gradient_Rm_B = gradient_Rm1_B - gradient_Rm2_B; 
                    gradient_Rm_C = gradient_Rm1_C - gradient_Rm2_C;
                    
                    momentum = min([momentum * 1.01,0.9]); % �����������Ϊ0.9����ʼֵΪ0.5����Լ����60��֮�������ʴﵽ0.9��
                    velocity_Rm_A = momentum * velocity_Rm_A + learn_rate_current * gradient_Rm_A;
                    velocity_Rm_B = momentum * velocity_Rm_B + learn_rate_current * gradient_Rm_B;
                    velocity_Rm_C = momentum * velocity_Rm_C + learn_rate_current * gradient_Rm_C;
                    
                    A = A + velocity_Rm_A;
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
        
        function obj = train_supervised(obj,data,num_weak,learn_rate_max,learn_rate_min,max_it)
            %train_supervised ѵ��SimilarityPreservingHashģ��
            %   ���룺
            %   data��ѵ�����ݣ�data.points��ʾ���ݵ㣬data.similar����[i j
            %         s]'������i��j��ʾpoint������±꣬s��ʾ����Ԫ���Ƿ�����
            %   num_weak����ʾ���������ĸ���
            %   max_it = 1e4;                % ����������
            %   learn_rate_max = 1e-1;       % ���ѧϰ�ٶ�
            %   learn_rate_min = 1e-6;       % ��Сѧϰ�ٶ�  
            %
            %   �����
            %   obj��ѵ�����SimilarityPreservingHash����
            
            ob_window_size = 100;
            [D,N] = size(data.points);   % D��ʾ���ݵ�ά�ȣ�N��ʾ���ݵ����
            [~,P] = size(data.similar);  % P��ʾ���ݶԵĸ���
            weight = ones(1,P) ./ P;     % Ȩֵ����
            momentum = 0.5;              % ��ʼ����������Ϊ0.5
            
            for m = 1:num_weak % ������ʼ
                ob = Observer('observer',2,ob_window_size,'legend'); % ��ʼ��һ���۲���
                A = eye(D);                      % ��A��ʼ��Ϊһ��ȫ0����
                B = ones(1,D);                    % ��B��ʼ��
                f_func = F_Quadratic(A,B,0);       % ��ʼ��f����
                f_value = f_func.do(data.points);  % �����е����ݵ����f������ֵ
                C = -1 * median(f_value);          % ��C��ʼ��
                f_func = F_Quadratic(A,B,C);       % ��ʼ��f����
                f_value  = f_func.do(data.points); % �����е����ݵ����f������ֵ
                max_f_value = max(f_value);        % �õ����ֵ
                min_f_value = min(f_value);        % �õ���Сֵ
                r = log((1 - 0.999) / 0.999) / min(abs(max_f_value),abs(min_f_value)); % ��ʼ��gamma��ֵ
                
                % �ҵ�һ��ʹ�ã�3.22��ʽ�е�r��󻯵���������
                velocity_Rm_A = zeros(size(A));
                velocity_Rm_B = zeros(size(B));
                velocity_Rm_C = zeros(size(C));
                learn_rate_current = learn_rate_max;                % ѧϰ�ٶȳ�ʼ��Ϊ���ѧϰ�ٶ�
                Rm_record = ones(1,ob_window_size); flag = false;   % Rm_record������¼���������е�Rmֵ
                A_record = repmat(A,1,1,ob_window_size);
                B_record = repmat(B,1,1,ob_window_size);
                C_record = repmat(C,1,1,ob_window_size);
                Rm_window_ave_max = -inf;
                
                for it = 0:max_it                    
                    f_func = F_Quadratic(A,B,C);       % ����f����
                    h_func = H_Func(f_func,r);         % ��gamma�������õ�h�����������h������
                    weak_c = WeakClassifier(h_func);   % ��h�������õ��������������������������
                    c = weak_c.do(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
                    Rm = sum(weight .* data.similar(3,:) .* c);
                    
                    if learn_rate_current == learn_rate_min 
                        break; % ��ѧϰ�ٶ��½�����Сѧϰ�ٶ�ʱ��ֹͣ����
                    end
                    
                    if flag == false
                        Rm_record = Rm * Rm_record;   % ���õ�һ�μ���õ���Rmֵ��ʼ��Rm_record
                        Rm_window_ave_old = Rm - 100; % ��ʼ���ɵĴ���ƽ��ֵ
                        flag = true;
                    end
                    
                    Rm_record(mod(it,ob_window_size)+1) = Rm; % ��¼��ǰ��Rmֵ��Rm_record������
                    Rm_window_ave = mean(Rm_record);          % ����Rm�Ĵ���ƽ��ֵ
                    A_record(:,:,mod(it,ob_window_size)+1) = A;
                    B_record(:,:,mod(it,ob_window_size)+1) = B;
                    C_record(:,:,mod(it,ob_window_size)+1) = C;
                    
                    description = strcat('Iteration: ', strcat(strcat(num2str(it),'/'),num2str(max_it)));
                    description = strcat(description, strcat(' LearnRate: ',num2str(learn_rate_current)));
                    description = strcat(description, strcat(' Gama: ',num2str(r)));
                    ob = ob.showit([Rm Rm_window_ave]',description);
                    
                    if mod(it,ob_window_size) == (ob_window_size-1)            % ������ﴰ�ڵ�ĩ��
                        if Rm_window_ave < Rm_window_ave_old  % �������ƽ��ֵ�½��ͽ���ѧϰ�ٶ�
                            learn_rate_current = max(0.5 * learn_rate_current,learn_rate_min);
                                [best_Rm,best_idx] = max(Rm_record);
                                A = A_record(:,:,best_idx);
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
                                % ����ﵽ����������RmҲ�������ӳ�����ǰֵ��1/100������ѧϰ�ٶ�
                                learn_rate_current = max(0.5 * learn_rate_current,learn_rate_min);   
                            end
                            Rm_window_ave_old = Rm_window_ave;
                        end
                    end
                    
                    % �����ݶ�
                    h_value       = h_func.do(data.points);         % �����������ݵ��h����ֵ
                    gradient_h_C  = h_value .* (h_value - 1) * r;   % ����h������C��ƫ����
                    
                    %parfor n = 1:N 
                    for n = 1:N 
                        gradient_h_A{n} = gradient_h_C(n) * data.points(:,n) * data.points(:,n)'; % ����h������A��ƫ����
                        gradient_h_B{n} = gradient_h_C(n) * data.points(:,n)';                    % ����h������B��ƫ����
                    end
                    
                    %parfor p = 1:P
                    for p = 1:P
                        i = data.similar(1,p); j = data.similar(2,p);
                        % ����c������A��B��C��ƫ����
                        gradient_c_A{p} = 4 * (gradient_h_A{i} * (h_value(j) - 0.5) + gradient_h_A{j} * (h_value(i) - 0.5));
                        gradient_c_B{p} = 4 * (gradient_h_B{i} * (h_value(j) - 0.5) + gradient_h_B{j} * (h_value(i) - 0.5));
                        gradient_c_C{p} = 4 * (gradient_h_C(i) * (h_value(j) - 0.5) + gradient_h_C(j) * (h_value(i) - 0.5));
                    end
                    
                    gradient_Rm_A = zeros(D); gradient_Rm_B = zeros(1,D); gradient_Rm_C = 0;
                    %parfor p = 1:P
                    for p = 1:P
                        gradient_Rm_A = gradient_Rm_A + weight(p) * data.similar(3,p) * gradient_c_A{p};
                        gradient_Rm_B = gradient_Rm_B + weight(p) * data.similar(3,p) * gradient_c_B{p};
                        gradient_Rm_C = gradient_Rm_C + weight(p) * data.similar(3,p) * gradient_c_C{p};
                    end
                    
                    momentum = min([momentum * 1.01,0.9]); % �����������Ϊ0.9����ʼֵΪ0.5����Լ����60��֮�������ʴﵽ0.9��
                    velocity_Rm_A = momentum * velocity_Rm_A + learn_rate_current * gradient_Rm_A;
                    velocity_Rm_B = momentum * velocity_Rm_B + learn_rate_current * gradient_Rm_B;
                    velocity_Rm_C = momentum * velocity_Rm_C + learn_rate_current * gradient_Rm_C;
                    
                    A = A + velocity_Rm_A;
                    B = B + velocity_Rm_B;
                    C = C + velocity_Rm_C;
                end
                
                Rm_max = sum(weight .* data.similar(3,:) .* sign(c));
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

