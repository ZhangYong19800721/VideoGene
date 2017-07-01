function nucleotide = ConstructSurfData(image_base_dir,file_type)
%CONSTRUCTSURFDATA �Ӹ�����Ŀ¼�ж�ȡ����ָ������ͼƬ��SURF����
%   SURF��������
    message = 'constructing surf data ....'; disp(message);
    files = dir(fullfile(image_base_dir,file_type)); % �õ�����ͼƬ���ļ���
    N = length(files); % ͼƬ�ļ��ĸ���
    SURF = [];
    
    for n = 1:N
        read_image_file_number = n
        image_rgb = imread(strcat(image_base_dir,files(n).name));
        image_yuv = rgb2ycbcr(image_rgb);
        [~,width] = size(image_yuv(:,:,1));
        image_scale_down = imresize(image_yuv(:,:,1),320/width);
        points = detectSURFFeatures(image_scale_down);
        [features,~] = extractFeatures(image_scale_down,points.selectStrongest(450));
        SURF = [SURF features'];
    end
end

