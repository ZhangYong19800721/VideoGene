classdef SCC_AdaBoostPro
    %UNTITLED AdaBoost�࣬ʵ��AdaBoost�㷨
    %   
    
    properties
        hypothesis;  % �������ɸ�����������cell����
        alfa;        % ÿ������������ͶƱȨֵ
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

