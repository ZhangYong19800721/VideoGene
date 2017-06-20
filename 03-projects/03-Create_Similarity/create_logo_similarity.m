clear all;
close all;

similarity = [];
start_idx = 34196+1;
%logo_idx = 6;
sequence = [2500:2535 2554:2625 2688:3276 3703:4223 4378:5221 5668:5982 6447:7050 9042:13094];

for i = sequence
    filename = sprintf('D:/视频基因/02-训练数据/imagebasev3/%09d.jpg',i);
    image = imread(filename);
    logo_idx = randi([3,46]);
    logoname = sprintf('./logos/logo%04d.png',logo_idx);
    logo = imread(logoname);
    new_image = add_logo(image,logo,[40,40]);
    new_filename = sprintf('D:/视频基因/03-projects/03-Create_Similarity/output/%09d.jpg',start_idx);
    imwrite(new_image,new_filename);
    similarity = [similarity; [i start_idx 1]];
    start_idx = start_idx + 1;
end

csvwrite('similarity.txt',similarity);

