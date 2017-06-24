classdef logistic
    %LOGISTIC �߼���������ɹ�ʽ��3.20���Ĺ���
    %   
    
    properties
        f_func;
        r;
    end
    
    methods
        function obj = logistic(f_func,r)
            obj.f_func = f_func;
            obj.r = r;
        end
    end
    
    methods
        function y = do(obj,points)
            y = sigmoid(obj.r * obj.f_func(points));
        end
    end
    
end

