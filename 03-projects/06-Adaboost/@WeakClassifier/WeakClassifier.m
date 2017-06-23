classdef WeakClassifier
    %WEAKCLASSIFIER �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        project_function_handle; % ӳ�亯���ľ��
        dimension;               % ά��ѡ��
        threshold;               % �����趨
        direction;               % �����趨
    end
    
    methods
        function obj = WeakClassifier(project_function_handle, dimension, threshold, direction)
            obj.project_function_handle = project_function_handle;
            obj.dimension = dimension;
            obj.threshold = threshold;
            obj.direction = direction;
        end
    end
    
    methods
        function y = predict(obj,points)
            y = -1 * obj.direction * ones(1,length(points));
            v = obj.project_function_handle(points,obj.dimension);
            y(v > obj.threshold) = obj.direction;
        end
    end
end

