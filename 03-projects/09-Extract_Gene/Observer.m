classdef Observer
    %OBSERVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle;
        window;
        legend;
        index;
        list;
        num;
    end
    
    methods
        function obj = Observer(name,num,window,legend)
            obj.handle = figure('Name',name); grid on;
            obj.window = window;
            obj.legend = legend;
            obj.num = num;
            obj.list = zeros(obj.num,obj.window);
            obj.index = 0;
        end
        
        function obj = showit(obj,data,description) % ��ͼ����ʾ�¸���������
            obj.index = mod(obj.index,obj.window);
            obj.list(:,obj.index+1) = data;
            
            figure(obj.handle);
            
            switch obj.num
                case 1
                    plot(1:obj.window,obj.list(1,:));
                case 2
                    plot(1:obj.window,obj.list(1,:),1:obj.window,obj.list(2,:));
                case 3
                    plot(1:obj.window,obj.list(1,:),1:obj.window,obj.list(2,:),1:obj.window,obj.list(3,:));
                case 4
                    plot(1:obj.window,obj.list(1,:),1:obj.window,obj.list(2,:),1:obj.window,obj.list(3,:),1:obj.window,obj.list(4,:));
            end
            grid on;
            title(description);
            obj.index = obj.index + 1;
            drawnow
        end
    end
end