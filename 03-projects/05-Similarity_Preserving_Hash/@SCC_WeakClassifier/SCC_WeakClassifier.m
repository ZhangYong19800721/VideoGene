classdef SCC_WeakClassifier
    %WEAKCLASSIFIER 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        project_function_handle; % 映射函数的句柄
        threshold;               % 门限设定
    end
    
    methods
        function obj = SCC_WeakClassifier(project_function_handle, threshold)
            obj.project_function_handle = project_function_handle;
            obj.threshold = threshold;
        end
    end
    
    methods
        function y = predict(obj,points1,points2)
            y  = -1 * ones(1,length(points1));
            v1 = obj.project_function_handle(points1);
            v2 = obj.project_function_handle(points2);
            y((v1 <= obj.threshold & v2 <= obj.threshold) | ...
              (v1 >  obj.threshold & v2 >  obj.threshold)) = +1;
        end
    end
end

