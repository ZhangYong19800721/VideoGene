clear all;
close all;

similarity = [];
start_idx = 46064+1;
sequence = [2638:2689 2861:3007 3705:4082 4304:4507 9042:13094];

subtitle_file_name = './subtitle/subtitle_english.txt';
fid = fopen(subtitle_file_name,'r+','n','utf-8');
subtitle_all = textscan(fid,'%s','delimiter',sprintf('\n'));

templete = [1 1 1; 1 -8 1; 1 1 1];

for i = sequence
    filename = sprintf('D:/视频基因/02-训练数据/imagebasev3/%09d.jpg',i);
    image = imread(filename); [~,w] = size(image(:,:,1));
    image = imresize(image,1920/w); [h,w] = size(image(:,:,1));
    black_ground = uint8(zeros(size(image)));
    while true
        subtitle = subtitle_all{1}{randi(5000)};
        subtitle = strtrim(subtitle);
        if ~isempty(subtitle)
            break;
        end
    end
    
    if length(subtitle) >= 50
        subtitle = subtitle(1:randi(50));
    end
    
    len_sub = length(subtitle);
    posx = (1920/2)-(1920/50)*(len_sub/2);
    posy = h - h * 0.1;
    
    %方法1：使用TextInserter方法，中文变乱码。
    %ti=vision.TextInserter(subtitle, 'Location', [posx posy], 'FontSize', 50, 'Color', [255 255 255]);
    %new_image = step(ti,image);

    % 方法2：使用insertText方法。
    new_image_subtitle = insertText(black_ground,[posx posy],subtitle, 'BoxOpacity', 0, 'FontSize', 50, 'TextColor', 'white', 'Font', 'Microsoft YaHei Bold');
    new_image = insertText(image,[posx posy],subtitle, 'BoxOpacity', 0, 'FontSize', 50, 'TextColor', 'white', 'Font', 'Microsoft YaHei Bold');
    frontia = conv2(double(new_image_subtitle(:,:,1)>0),templete,'same');
    frontia = frontia < 0; 
    frontia = repmat(frontia,1,1,3);
    new_image(frontia) = 0; 
    
    new_filename = sprintf('D:/视频基因/03-projects/03-Create_Similarity/output/%09d.jpg',start_idx);
    imwrite(new_image,new_filename);
    similarity = [similarity; [i start_idx 1]];
    start_idx = start_idx + 1;
end

csvwrite('similarity.txt',similarity);

