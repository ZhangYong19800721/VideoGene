function new_image = add_logo(image, logo, p)
%add_logo ��̨����ӵ�ͼƬ��ָ��λ��
%
    [~,w1,~] = size(image);
    [~,w2,~] = size(logo);
    logo = imresize(logo,0.11 * w1 / w2); % ��̨��ŵ�����С���ʺϵĳߴ�
    [h3,w3,~] = size(logo);
    partial_image = image(p(1):(p(1)+h3-1),p(2):(p(2)+w3-1),1:3);
    logo_yuv = rgb2ycbcr(logo);
    partial = logo_yuv(:,:,1) >= 60;
    partial = repmat(partial,1,1,3);
    partial_image(partial) = logo(partial);
    
    new_image = image;
    new_image(p(1):(p(1)+h3-1),p(2):(p(2)+w3-1),1:3) = partial_image;
end

