classdef weak_classifier
    %WEAK_CLASSIFIER �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        logistic_func;
    end
    
    methods
        function obj = weak_classifier(logistic_func)
            obj.logistic_func = logistic_func;
        end
    end
    
    methods
        function c = do(points1,points2)
            c = 4 * (obj.logistic_func(points1) - 0.5) .* (obj.logistic_func(points2) - 0.5);
        end
    end
end
