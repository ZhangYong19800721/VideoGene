classdef AdaBoost
    %UNTITLED AdaBoost类，实现AdaBoost算法
    %   
    
    properties
        hypothesis;  % 包含若干个弱分类器的cell数组
        alfa;        % 每个弱分类器的投票权值
    end
    
    methods
        function obj = AdaBoost()
            hypothesis = [];
            alfa = [];
        end
    end
    
    methods
        obj  = train(obj,data,weight,num_weak) % 训练adaboost
        y    = predict(obj,points)  % 使用经过训练的模型判断数据点的分类
        c    = hashcode(obj,points) % 计算数据点的hashcode（哈希码）
    end
end

