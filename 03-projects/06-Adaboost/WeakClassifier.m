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
        function c = do(obj, points)
            c = 2 * obj.h_func.do(points) - 1;
        end
    end
end

