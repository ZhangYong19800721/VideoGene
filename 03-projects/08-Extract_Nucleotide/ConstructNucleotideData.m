function nucleotide = ConstructNucleotideData(image_base_dir,file_type)
%CONSTRUCTSURFDATA �Ӹ�����Ŀ¼�ж�ȡ����ָ������ͼƬ��SURF����
%   SURF��������
    message = 'constructing nucleotide data ....'; disp(message);
    files = dir(fullfile(image_base_dir,file_type)); % �õ�����ͼƬ���ļ���
    N = length(files); % ͼƬ�ļ��ĸ���
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

