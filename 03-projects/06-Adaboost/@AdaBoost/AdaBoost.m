classdef AdaBoost
    %UNTITLED AdaBoost�࣬ʵ��AdaBoost�㷨
    %   
    
    properties
        hypothesis;  % �������ɸ�����������cell����
        alfa;        % ÿ������������ͶƱȨֵ
    end
    
    methods
        function obj = AdaBoost()
            hypothesis = [];
            alfa = [];
        end
    end
    
    methods
        obj  = train(obj,data,weight,num_weak) % ѵ��adaboost
        y    = predict(obj,points)  % ʹ�þ���ѵ����ģ���ж����ݵ�ķ���
        c    = hashcode(obj,points) % �������ݵ��hashcode����ϣ�룩
    end
end

