classdef SCC_WeakClassifier
    %WEAKCLASSIFIER �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        func_handle;   % ӳ�亯���ľ��
        dimension;     % ѡ��ά��
        threshold;     % �����趨
    end
    
    methods
        function obj = SCC_WeakClassifier(func_handle, dimension, threshold)
            obj.func_handle = func_handle;
            obj.dimension = dimension;
            obj.threshold = threshold;
        end
    end
    
    methods
        function y = predict(obj,points1,points2)
            y  = -1 * ones(1,length(points1));
            v1 = obj.func_handle(points1,obj.dimension);
            v2 = obj.func_handle(points2,obj.dimension);
            y((v1 <= obj.threshold & v2 <= obj.threshold) | ...
              (v1 >  obj.threshold & v2 >  obj.threshold)) = +1;
        end
    end
end

