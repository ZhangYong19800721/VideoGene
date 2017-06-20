clear all;
close all;

similarity = [];
start_idx = 61448+1;
sequence = [939:13094];

for i = sequence
    filename = sprintf('D:/视频基因/02-训练数据/imagebasev3/%09d.jpg',i);
    image = imread(filename);
    [h,w,~] = size(image);
    percent = 0.12;
    new_image = image; new_image(:,[1:ceil(percent*w) floor((1-percent)*w):w],:) = 0;
    new_filename = sprintf('D:/视频基因/03-projects/03-Create_Similarity/output/%09d.jpg',start_idx);
    imwrite(new_image,new_filename);
    similarity = [similarity; [i start_idx 1]];
    start_idx = start_idx + 1;
end

csvwrite('similarity.txt',similarity);

