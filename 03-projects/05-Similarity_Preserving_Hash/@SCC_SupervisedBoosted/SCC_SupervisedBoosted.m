classdef SCC_SupervisedBoosted
    %SCC_SupervisedBoosted SCC_SupervisedBoosted��
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
        C    = hashcode(obj,points) 
    end
end

