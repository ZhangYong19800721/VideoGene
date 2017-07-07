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
        function obj  = train(obj,data,num_weak,max_it)
            %TRAIN ѵ��adaboostģ��
            %   ���룺
            %   data��ѵ�����ݣ�data.points��ʾ���ݵ㣬data.labels����+1��-1��
            %   ����ָʾdata.points�����ݵ�ķ���
            %   num_weak����ʾ���������ĸ���
            %   max_it������������
            %
            %   �����
            %   obj��ѵ�����adaboost����
            
            [D,N] = size(data.points);  % D���ݵ�ά�ȣ�N���ݵĸ���
            weight = ones(1,N) ./ N;    % ������Ӧ��Ȩֵ����
            learn_rate = 0.01;
            
            for classifier_idx = 1:num_weak
                B = randn(1,D); % ��ʼ������B
                f_func = F_Linear(B,0); % ��ʼ��f����
                f_value = f_func.do(data.points); % �����еĵ����f������ֵ
                C = -1 * median(f_value); % ��ʼ������CΪ��ֵ
                f_func = F_Linear(B,C); % ���³�ʼ��f����
                f_value = f_func.do(data.points); % ���¼���f������ֵ
                f_value_max = max(f_value);
                f_value_min = min(f_value);
                gama = log((1 - 0.999) / 0.999) / min(abs(f_value_max),abs(f_value_min)); % ��ʼ��gamma��ֵ
                
                ob = Observer('name',1,100,'legend');
                
                for it = 0:max_it
                    f_func = F_Linear(B,C); % ����f����
                    h_func = F_Sigmoid(f_func,gama); % ����h����
                    classifier =  WeakClassifier(h_func); % ������������
                    
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
        
        function y    = predict(obj,points)  % ʹ�þ���ѵ����ģ���ж����ݵ�ķ���
            %PREDICT �ж��������Ƿ����ƣ�����Ϊ+1��������Ϊ-1
            %
            M = length(obj.alfa); % ���������ĸ���
            N = length(points);  % ���ݵ���
            C = zeros(M,N);
            for m=1:M
                C(m,:) = obj.hypothesis{m}.predict(points);
            end
            y = sign(obj.alfa * C);
            y(y<=0) = -1;
        end
    end
end

