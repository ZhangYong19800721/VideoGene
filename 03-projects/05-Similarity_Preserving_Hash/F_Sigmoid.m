classdef F_Sigmoid
    %LOGISTIC �߼���������ɹ�ʽ��3.20���Ĺ���
    %   
    
    properties
        f_func;
        gama;
    end
    
    methods
        function obj = F_Sigmoid(f_func,gama)
            obj.f_func = f_func;
            obj.gama = gama;
        end
    end
    
    methods
        function y = do(obj,points)
            y = func_sigmoid(obj.gama * obj.f_func.do(points));
        end
    end
    
end

