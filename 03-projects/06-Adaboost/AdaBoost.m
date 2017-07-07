classdef AdaBoost
    %UNTITLED AdaBoost�࣬ʵ��AdaBoost�㷨
    %   
    
    properties
        hypothesis;  % �������ɸ�����������cell����
        alfa;        % ÿ������������ͶƱȨֵ
    end
    
    methods
        function obj = AdaBoost()
            hypothesis = [];
            alfa = [];
        end
    end
    
    methods
        function obj  = train(obj,data,num_classifier,learn_rate_max,learn_rate_min,max_it)
            %TRAIN ѵ��adaboostģ��
            %   ���룺
            %   data��ѵ�����ݣ�data.points��ʾ���ݵ㣬data.labels����+1��-1��
            %   ����ָʾdata.points�����ݵ�ķ���
            %   num_classifier����ʾ���������ĸ���
            %   max_it������������
            %   learn_rate��ѧϰ�ٶ�
            % 
            %   �����
            %   obj��ѵ�����adaboost����
            
            ob_window_size = 100;
            [D,N] = size(data.points);  % D���ݵ�ά�ȣ�N���ݵĸ���
            weight = ones(1,N) ./ N;    % ������Ӧ��Ȩֵ����
            momentum = 0.5;             % ��ʼ����������Ϊ0.5
            
            for classifier_idx = 1:num_classifier
                ob = Observer('R-Value',2,ob_window_size,'xxx'); % ��ʼ��һ���۲���
                
                B = randn(1,D); % ��ʼ������B
                f_func = F_Linear(B,0); % ��ʼ��f����
                f_value = f_func.do(data.points); % �����еĵ����f������ֵ
                C = -1 * median(f_value); % ��ʼ������CΪ��ֵ
                f_func = F_Linear(B,C); % ���³�ʼ��f����
                f_value = f_func.do(data.points); % ���¼���f������ֵ
                f_value_max = max(f_value);
                f_value_min = min(f_value);
                gama = log((1 - 0.999) / 0.999) / min(abs(f_value_max),abs(f_value_min)); % ��ʼ��gamma��ֵ
                
                velocity_r_B = zeros(size(B));
                velocity_r_C = zeros(size(C));
                
                learn_rate = learn_rate_max;
                
                flag = false;
                r_ave_max = -inf;
                
                for it = 0:max_it
                    f_func = F_Linear(B,C); % ����f����
                    h_func = F_Sigmoid(f_func,gama); % ����h����
                    classifier =  WeakClassifier(h_func); % ������������
                    
                    c = classifier.do(data.points);
                    r = weight * (data.labels .* c)';
                    
                    if learn_rate == learn_rate_min 
                        break; % ��ѧϰ�ٶ��½�����Сѧϰ�ٶ�ʱ��ֹͣ����
                    end
                    
                    if flag == false
                        r_list = r * ones(1,ob_window_size);   % ���õ�һ�μ���õ���Rmֵ��ʼ��Rm_record
                        r_ave_old = r - 100; % ��ʼ���ɵĴ���ƽ��ֵ
                        flag = true;
                    end
                    
                    r_list(mod(it,ob_window_size)+1) = r;     % ��¼��ǰ��Rmֵ��Rm_record������
                    r_ave_new = mean(r_list);          % ����Rm�Ĵ���ƽ��ֵ
                    
                    description = strcat('��������: ', strcat(strcat(num2str(it),'/'),num2str(max_it)));
                    description = strcat(description, strcat(' ѧϰ����: ',num2str(learn_rate)));
                    description = strcat(description, strcat(' Ŀ�꺯��: ',num2str(r)));
                    description = strcat(description, strcat(' Gama: ',num2str(gama)));
                    ob = ob.showit([r r_ave_new]',description);
                    
                    if mod(it,ob_window_size) == (ob_window_size-1)  % ������ﴰ�ڵ�ĩ��
                        if r_ave_new < r_ave_old % �������ƽ��ֵ�½�(������)�ͽ���ѧϰ�ٶ�
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
                                % ����ﵽ����������RmҲ�������ӳ�����ǰֵ��1/100������ѧϰ�ٶ�
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
                    
                    momentum = min([momentum * 1.01,0.9]); % �����������Ϊ0.9����ʼֵΪ0.5����Լ����60��֮�������ʴﵽ0.9��
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
        
        function y    = predict(obj,points)  % ʹ�þ���ѵ����ģ���ж����ݵ�ķ���
            %PREDICT �ж��������Ƿ����ƣ�����Ϊ+1��������Ϊ-1
            %
            M = length(obj.alfa); % ���������ĸ���
            [D,N] = size(points);  % N���ݵ���
            C = zeros(M,N);
            for m=1:M
                C(m,:) = obj.hypothesis{m}.do(points);
            end
            y = sign(obj.alfa * C);
        end
    end
end

