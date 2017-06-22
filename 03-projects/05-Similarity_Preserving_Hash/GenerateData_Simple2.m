function [points,similar] = GenerateData_Simple2()
%GENERATEDATA 产生一些测试数据
%   
    
    x1 = [ 2, 4, 9,11,16, 1, 3, 8,10,17];
    x2 = [ 5, 7,14,19,18, 6,13,12,15,20];
    l  = [ 1, 1, 1, 1, 1,-1,-1,-1,-1,-1];
    points = [x1 x2];
    similar = [1:10;11:20;l];
end

