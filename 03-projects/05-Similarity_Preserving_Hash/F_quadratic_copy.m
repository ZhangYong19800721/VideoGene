classdef F_Quadratic
    %F_FUNC �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        A;
        B;
        C
    end
    
    methods
        function obj = F_Quadratic(A,B,C)
            obj.A = A;
            obj.B = B;
            obj.C = C;
        end
    end
    
    methods
        function y = do(obj,points)
            y = quadratic(points,obj.A,obj.B,obj.C);
        end
    end
end

