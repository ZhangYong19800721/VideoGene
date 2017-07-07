classdef F_Sigmoid
    %LOGISTIC Âß¼­º¯Êý
    %   
    
    properties
        f_func;
        r;
    end
    
    methods
        function obj = F_Sigmoid(f_func,r)
            obj.f_func = f_func;
            obj.r = r;
        end
    end
    
    methods
        function y = do(obj,points)
            y = func_sigmoid(obj.r * obj.f_func.do(points));
        end
    end
    
end

