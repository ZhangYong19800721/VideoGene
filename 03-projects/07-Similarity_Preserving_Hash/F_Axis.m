classdef F_Axis
    %F_Axis 此处显示有关此类的摘要
    %   此处显示详细说明
    
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

