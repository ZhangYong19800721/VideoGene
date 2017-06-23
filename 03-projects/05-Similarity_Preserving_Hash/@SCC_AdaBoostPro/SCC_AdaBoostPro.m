classdef SCC_AdaBoostPro
    %UNTITLED AdaBoost类，实现AdaBoost算法
    %   
    
    properties
        hypothesis;  % 包含若干个弱分类器的cell数组
        alfa;        % 每个弱分类器的投票权值
    end
    
    methods
        function obj = SCC_AdaBoostPro()
            hypothesis = [];
            alfa = [];
        end
    end
    
    methods
        obj  = train(obj,data,weight,num_weak)
        y    = predict(obj,points1,points2)
        c    = hashcode(obj,points) 
    end
end

