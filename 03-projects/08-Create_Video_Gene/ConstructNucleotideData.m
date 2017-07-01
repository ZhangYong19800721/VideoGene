function nucleotide = ConstructNucleotideData(image_base_dir,file_type)
%CONSTRUCTSURFDATA 从给定的目录中读取所有指定类型图片的SURF特征
%   SURF特征集合
    message = 'constructing nucleotide data ....'; disp(message);
    files = dir(fullfile(image_base_dir,file_type)); % 得到所有图片的文件名
    N = length(files); % 图片文件的个数
    nucleotide = zeros(8688,N);
    
    load VisualVocabulary_UV.mat;
    load VisualVocabulary_Y.mat;

    extractor = VisualNucleotideExtractor(VisualVocabulary_Y,VisualVocabulary_UV);
    
    for n = 1:N
        read_image_file_number = n
        image_rgb = imread(strcat(image_base_dir,files(n).name));
        image_yuv = rgb2ycbcr(image_rgb);
        nucleotide(:,n) = extractor.Extract(image_yuv)';
    end
end

