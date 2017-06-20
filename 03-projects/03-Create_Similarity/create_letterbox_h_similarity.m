clear all;
close all;

similarity = [];
start_idx = 50898+1;
sequence = [939:2625 2688:3416 3556:3921 4074:4508 4679:5025 5222:5667 5983:6245 6449:7097 7135:7287 7364:7438 7520:7590 7632:8520 8655:13094];

for i = sequence
    filename = sprintf('D:/视频基因/02-训练数据/imagebasev3/%09d.jpg',i);
    image = imread(filename);
    [h,w,~] = size(image);
    percent = 0.10;
    new_image = image; new_image([1:ceil(percent*h) floor((1-percent)*h):h],:,:) = 0;
    new_filename = sprintf('D:/视频基因/03-projects/03-Create_Similarity/output/%09d.jpg',start_idx);
    imwrite(new_image,new_filename);
    similarity = [similarity; [i start_idx 1]];
    start_idx = start_idx + 1;
end

csvwrite('similarity.txt',similarity);

