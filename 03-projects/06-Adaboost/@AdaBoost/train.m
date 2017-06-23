function obj = train(obj,data,weight,num_weak)
%TRAIN ѵ��adaboostģ��
%   ���룺
%   data��ѵ�����ݣ�data.points��ʾ���ݵ㣬data.similar����[i j
%   s]'������i��j��ʾpoint������±꣬s��ʾ����Ԫ���Ƿ�����
%   weight����ʼ��Ȩֵ��Ҫ��Ǹ�����sum(weight)=1��
%   num_weak����ʾ���������ĸ���
%
%   �����
%   obj��ѵ�����adaboost����   
    
    [D,~] = size(data.points); % D���ݵ�ά�ȣ�N���ݵĸ���
    
    XD = []; XT = []; 
    for d = 1:D
        v = project_function(data.points,d);
        u = unique(v); u = sort(u); Nu = length(u); %ȥ��v�е��ظ�����,����
        delta = (u(2:Nu) - u(1:(Nu-1))) / 2; Nd = length(delta);
        T = [u(1)-delta(1), u(1:Nd) + delta, u(Nu)+delta(Nd)]; %����õ����п��ܵ�threshold
        XD = [XD d*ones(1,length(T))];
        XT = [XT T];
    end
    
    XF = [ones(1,length(XD)) -1*ones(1,length(XD))];
    XD = [XD XD];
    XT = [XT XT];
    K = length(XD); %XD��XT�ĳ��ȴ��������п��ܵ�ѡ��ά�Ⱥ�����
    
    for m = 1:num_weak
        r = zeros(1,K);
        
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

