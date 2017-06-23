classdef WeakClassifier
    %WEAKCLASSIFIER 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        project_function_handle; % 映射函数的句柄
        dimension;               % 维度选择
        threshold;               % 门限设定
        direction;               % 方向设定
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

