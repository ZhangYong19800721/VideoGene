classdef SCC_SupervisedBoosted
    %UNTITLED SCC_SupervisedBoosted�࣬ʵ��SCC_SupervisedBoosted�㷨
    %   
    
    properties
        hypothesis;  % �������ɸ�����������cell����
        alfa;        % ÿ������������ͶƱȨֵ
    end
    
    methods
        function obj = SCC_SupervisedBoosted()
            obj.hypothesis = [];
            obj.alfa = [];
        end
    end
    
    methods
        obj  = train(obj,data,weight,num_weak)
        y    = predict(obj,points1,points2)
        C    = hashcode(obj,points) 
    end
end

