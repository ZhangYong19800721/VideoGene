classdef LSH
    %LSH 局部相似性哈希，Locality-Similarity Hashing 
    % 局部相似性哈希
    
    properties
        d; % 数据点的维度
        n; % 数据集的大小
        p1; % 当两个点之间的距离小于r1时，它们冲突的概率大于等于p1
        p2; % 当两个点之间的距离大于r2时，它们冲突的概率小于等于p2
        k; % LSH哈希函数的采样位个数
        l; % 桶的数量
        C; % 数据值的上界
        H; % 哈希函数采样点
        H_P; % 哈希函数采样位
        H_T; % 哈希函数门限值
    end
    
    methods
        function obj = LSH(data_set) % 构造函数
            [obj.d,obj.n] = size(data_set); %得到数据的维度d，得到数据集的大小n。
            obj.C = 255;
            obj.l = 10;
            obj.k = 100;
            
            dc = obj.C * obj.d;
            obj.H = randperm(dc,obj.l * obj.k);
            obj.H = reshape(obj.H,obj.k,obj.l); % 每一列代表一个哈希函数的参数序列
            obj.H = sort(obj.H,1); % 对列进行排序，从小到大
            obj.H_P = uint32(ceil(obj.H / obj.C));
            obj.H_T = uint32(1+mod(obj.H, obj.C));
        end
        
        function y = hash(obj,point) 
            y = (point(obj.H_P) >= obj.H_T);
        end
    end
end

