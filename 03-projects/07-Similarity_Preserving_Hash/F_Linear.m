classdef F_Linear
    %F_LINEAR �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        B;
        C;
    end
    
    methods
        function obj = F_Linear(B,C)
            obj.B = B;
            obj.C = C;
        end
    end
    
    methods
        function y = do(obj,points)
            y = func_linear(points,obj.B,obj.C);
        end
    end
    
end

