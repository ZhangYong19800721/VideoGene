classdef WeakClassifier
    %WeakClassifier 弱分类器
    %   此处显示详细说明
    
    properties
        h_func;
    end
    
    methods
        function obj = WeakClassifier(h_func)
            obj.h_func = h_func;
        end
    end
    
    methods
        function c = do(obj, points)
            c = 2 * obj.h_func.do(points) - 1;
        end
    end
end

