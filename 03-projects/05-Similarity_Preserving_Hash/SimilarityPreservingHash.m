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
            %   weight����ʼ��Ȩֵ��Ҫ��Ǹ�����sum(weight)=1��
            %   num_weak����ʾ���������ĸ���
            %
            %   �����
            %   obj��ѵ�����SimilarityPreservingHash����
            
            [D,N] = size(data.points);   % D��ʾ���ݵ�ά�ȣ�N��ʾ���ݵ����
            [~,P] = size(data.similar);  % P��ʾ���ݶԵĸ���
            weight = ones(1,P) ./ P;     % Ȩֵ����
            max_it = 1e5;                % ����������
            learn_rate = 0.0001;         % ѧϰ�ٶ�
            
            A = zeros(D);                      % ��A��ʼ��Ϊһ��ȫ0����
            B = sign(randn(1,D));              % ��B��ʼ��Ϊһ���������1����
            C = 0;                             % ��C��ʼ��Ϊ0
            f_func = @(x)f_quadratic(x,A,B,C); % �õ�f����
            f_value  = f_func(data.points);    % �����е����ݵ����f������ֵ
            C = -1 * median(f_value);          % ��C�趨Ϊf����ֵ���е���λ��
            f_func = @(x)f_quadratic(x,A,B,C); % ���³�ʼ��f����
            f_value  = f_func(data.points);    % ���¼����������ݵ��f����ֵ
            max_f_value = max(f_value);        % �õ����ֵ
            min_f_value = min(f_value);        % �õ���Сֵ
            r = log((1 - 0.999) / 0.999) / min(abs(max_f_value),abs(min_f_value)); % ��ʼ��gamma��ֵ
            
            for m = 1:num_weak % ������ʼ
                % �ҵ�һ��ʹ�ã�3.22��ʽ�е�r��󻯵���������
                for it = 1:max_it
                    h_func = logistic(f_func,r);       % ��gamma�������õ�h�����������h������
                    weak_c = weak_classifier(h_func);  % ��h�������õ��������������������������
                    Cp = weak_c.do(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
                    Rm = sum(weight .* data.similar(3,:) .* Cp)
                    
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
                    
                    A = A + learn_rate * gradient_r_A;
                    B = B + learn_rate * gradient_r_B;
                    C = C + learn_rate * gradient_r_C;
                    f_func = @(x)f_quadratic(x,A,B,C); % ����f����
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

