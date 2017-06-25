classdef SimilarityPreservingHash
    %SimilarityPreservingHash Similarity Preserving Hash��
    %   
    
    properties
        hypothesis;  % �������ɸ�����������cell����
        alfa;        % ÿ������������ͶƱȨֵ
    end
    
    methods % ���캯��
        function obj = SimilarityPreservingHash()
            obj.hypothesis = [];
            obj.alfa = [];
        end
    end
    
    methods
        function obj  = train(obj,data,num_weak)
            %TRAIN ѵ��SimilarityPreservingHashģ��
            %   ���룺
            %   data��ѵ�����ݣ�data.points��ʾ���ݵ㣬data.similar����[i j
            %         s]'������i��j��ʾpoint������±꣬s��ʾ����Ԫ���Ƿ�����
            %   num_weak����ʾ���������ĸ���
            %
            %   �����
            %   obj��ѵ�����SimilarityPreservingHash����
            
            ob_window_size = 500;
            [D,N] = size(data.points);   % D��ʾ���ݵ�ά�ȣ�N��ʾ���ݵ����
            [~,P] = size(data.similar);  % P��ʾ���ݶԵĸ���
            weight = ones(1,P) ./ P;     % Ȩֵ����
            max_it = 1e5;                % ����������
            learn_rate_max = 1e-3;       % ���ѧϰ�ٶ�
            learn_rate_min = 1e-6;       % ��Сѧϰ�ٶ�            
            momentum = 0.5; % ��ʼ����������Ϊ0.5
            
            for m = 1:num_weak % ������ʼ
                ob = Observer('observer',2,ob_window_size,'legend'); % ��ʼ��һ���۲���
                
                XD = []; XT = [];
                for d = 1:D
                    v = f_axis_parallel(data.points,d);
                    u = unique(v); u = sort(u); Nu = length(u); %ȥ��v�е��ظ�����,����
                    delta = (u(2:Nu) - u(1:(Nu-1))) / 2; Nd = length(delta);
                    T = [u(1)-delta(1), u(1:Nd) + delta, u(Nu)+delta(Nd)]; %����õ����п��ܵ�threshold
                    XD = [XD d*ones(1,length(T))];
                    XT = [XT T];
                end
                K = length(XD); %XD��XT�ĳ��ȴ��������п��ܵ�ѡ��ά�Ⱥ�����
                Rm = zeros(1,K); % ѡ��һ����������ʹr���
                for k = 1:K
                    weak_classifer = SCC_WeakClassifier(@f_axis_parallel,XD(k),XT(k)); % ʹ��f������threshold���ɵõ�һ����������
                    c = weak_classifer.predict(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
                    Rm(k) = weight * (data.similar(3,:) .* c)';
                end
                [~,Rm_idx] = max(Rm); d_best = XD(Rm_idx); t_best = XT(Rm_idx);
                
                A = zeros(D);                      % ��A��ʼ��Ϊһ��ȫ0����
                B = zeros(1,D); B(d_best) = 1;     % ��B��ʼ��
                C = -1 * t_best;                   % ��C��ʼ��Ϊ0
                f_func = @(x)f_quadratic(x,A,B,C); % �õ�f����
                f_value  = f_func(data.points);    % �����е����ݵ����f������ֵ
                max_f_value = max(f_value);        % �õ����ֵ
                min_f_value = min(f_value);        % �õ���Сֵ
                r = log((1 - 0.999) / 0.999) / min(abs(max_f_value),abs(min_f_value)); % ��ʼ��gamma��ֵ
                
                % �ҵ�һ��ʹ�ã�3.22��ʽ�е�r��󻯵���������
                velocity_r_A = zeros(D);
                velocity_r_B = zeros(1,D);
                velocity_r_C = 0;
                learn_rate_current = learn_rate_max; % ѧϰ�ٶȳ�ʼ��Ϊ���ѧϰ�ٶ�
                Rm_record = ones(1,ob_window_size); flag = false;
                
                for it = 1:max_it                    
                    f_func = @(x)f_quadratic(x,A,B,C); % ����f����
                    h_func = logistic(f_func,r);       % ��gamma�������õ�h�����������h������
                    weak_c = weak_classifier(h_func);  % ��h�������õ��������������������������
                    Cp = weak_c.do(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
                    Rm = sum(weight .* data.similar(3,:) .* Cp);
                    
                    if learn_rate_current == learn_rate_min 
                        break; % ��ѧϰ�ٶ��½�����Сѧϰ�ٶ�ʱ��ֹͣ����
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
                    
                    % �����ݶ�
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
                    
                    momentum = min([momentum * 1.01,0.9]); % �����������Ϊ0.9����ʼֵΪ0.5����Լ����60��֮�������ʴﵽ0.9��
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

