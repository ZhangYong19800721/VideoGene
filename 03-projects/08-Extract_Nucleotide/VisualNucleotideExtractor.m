classdef VisualNucleotideExtractor
    %VISUALNUCLEOTIDEEXTRACTOR 从图片中抽取视频基因序列（8868维向量）
    %   
    
    properties
        vvl;
        vvc; 
    end
    
    methods
        function obj = VisualNucleotideExtractor(vvl,vvc)
            obj.vvl = vvl;
            obj.vvc = vvc;
        end
    end
    
    methods
        function nucleotide = Extract(obj,image)
            [~     ,width,~] = size(image);        % 获取图像的大小         
            image = imresize(image,320/width);     % 将图像缩减到宽度为320个像素
            [height,width,~] = size(image);        % 重新获取图像的大小
            alfa = 0.55;
            image_quadrant{1} = image(1:floor(alfa*height), 1:floor(alfa*width),:); 
            image_quadrant{2} = image(floor((1-alfa)*height):height, 1:floor(alfa*width),:);
            image_quadrant{3} = image(1:floor(alfa*height),floor((1-alfa)*width):width,:);
            image_quadrant{4} = image(floor((1-alfa)*height):height,floor((1-alfa)*width):width,:);
            
            [~,NY] = size(obj.vvl); [~,NU] = size(obj.vvc); [~,NV] = size(obj.vvc);
            
            nucleotide = [];
            for n = 1:4
                points = detectSURFFeatures(image_quadrant{n}(:,:,1));
                [features,~] = extractFeatures(image_quadrant{n}(:,:,1),points.selectStrongest(450));
                features = features'; [~,KY] = size(features); 
                
                quantized_Y = inf(NY,KY);
                for k = 1:KY
                    X = repmat(features(:,k),1,NY) - obj.vvl;      % 按每一列求这个矩阵的范数
                    quantized_Y(:,k) = sqrt(sum(X.^2))';           % 选择范数最小的那个作为量化结果
                end
                [~,quantized_Y] = min(quantized_Y);
                
                points = detectSURFFeatures(image_quadrant{n}(:,:,2));
                [features,~] = extractFeatures(image_quadrant{n}(:,:,2),points.selectStrongest(450));
                features = features'; [~,KU] = size(features); 
                
                quantized_U = inf(NU,KU);
                for k = 1:KU
                    X = repmat(features(:,k),1,NU) - obj.vvc;      % 按每一列求这个矩阵的范数
                    quantized_U(:,k) = sqrt(sum(X.^2))';           % 选择范数最小的那个作为量化结果
                end
                [~,quantized_U] = min(quantized_U);
                quantized_U = quantized_U + NY;
                
                points = detectSURFFeatures(image_quadrant{n}(:,:,3));
                [features,~] = extractFeatures(image_quadrant{n}(:,:,3),points.selectStrongest(450));
                features = features'; [~,KV] = size(features); 
                
                quantized_V = inf(NV,KV);
                for k = 1:KV
                    X = repmat(features(:,k),1,NV) - obj.vvc;      % 按每一列求这个矩阵的范数
                    quantized_V(:,k) = sqrt(sum(X.^2))';           % 选择范数最小的那个作为量化结果
                end
                [~,quantized_V] = min(quantized_V);
                quantized_V = quantized_V + NY;
                
                nucleotide = [nucleotide hist([quantized_Y quantized_U quantized_V],1:(NY+NU))];
            end
        end
    end
end

