classdef H_Func
    %LOGISTIC �߼���������ɹ�ʽ��3.20���Ĺ���
    %   
    
    properties
        f_func;
        r;
    end
    
    methods
        function obj = H_Func(f_func,r)
            obj.f_func = f_func;
            obj.r = r;
        end
    end
    
    methods
        function y = do(obj,points)
            y = sigmoid(obj.r * obj.f_func.do(points));
        end
    end
    
end

