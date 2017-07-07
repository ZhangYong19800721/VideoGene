classdef WeakClassifier
    %WeakClassifier ��������
    %   �˴���ʾ��ϸ˵��
    
    properties
        h_func;
    end
    
    methods
        function obj = WeakClassifier(h_func)
            obj.h_func = h_func;
        end
    end
    
    methods
        function c = do(obj, points1, points2)
            c = 4 .* (obj.h_func.do(points1) - 0.5) .* (obj.h_func.do(points2) - 0.5);
        end
    end
end

