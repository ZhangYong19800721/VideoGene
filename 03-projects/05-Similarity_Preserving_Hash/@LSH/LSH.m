classdef LSH
    %LSH �ֲ������Թ�ϣ��Locality-Similarity Hashing 
    % �ֲ������Թ�ϣ
    
    properties
        d; % ���ݵ��ά��
        n; % ���ݼ��Ĵ�С
        p1; % ��������֮��ľ���С��r1ʱ�����ǳ�ͻ�ĸ��ʴ��ڵ���p1
        p2; % ��������֮��ľ������r2ʱ�����ǳ�ͻ�ĸ���С�ڵ���p2
        k; % LSH��ϣ�����Ĳ���λ����
        l; % Ͱ������
        C; % ����ֵ���Ͻ�
        H; % ��ϣ����������
        H_P; % ��ϣ��������λ
        H_T; % ��ϣ��������ֵ
    end
    
    methods
        function obj = LSH(data_set) % ���캯��
            [obj.d,obj.n] = size(data_set); %�õ����ݵ�ά��d���õ����ݼ��Ĵ�Сn��
            obj.C = 255;
            obj.l = 10;
            obj.k = 100;
            
            dc = obj.C * obj.d;
            obj.H = randperm(dc,obj.l * obj.k);
            obj.H = reshape(obj.H,obj.k,obj.l); % ÿһ�д���һ����ϣ�����Ĳ�������
            obj.H = sort(obj.H,1); % ���н������򣬴�С����
            obj.H_P = uint32(ceil(obj.H / obj.C));
            obj.H_T = uint32(1+mod(obj.H, obj.C));
        end
        
        function y = hash(obj,point) 
            y = (point(obj.H_P) >= obj.H_T);
        end
    end
end

