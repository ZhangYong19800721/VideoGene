classdef F_Axis
    %F_Axis �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        D;
        T;
    end
    
    methods
        function obj = F_Axis(D,T)
            obj.D = D;
            obj.T = T;
        end
    end
    
    methods
        function y = do(obj,points)
            y = axis(points,obj.D,obj.T);
        end
    end
end

