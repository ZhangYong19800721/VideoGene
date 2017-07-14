classdef F_Linear
    %F_LINEAR 此处显示有关此类的摘要
    %   此处显示详细说明
    
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

