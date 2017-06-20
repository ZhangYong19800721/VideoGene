clear all;
close all;

N = 1e4;
[x1,x2,similar] = GenerateData(N);
data.x1 = x1;
data.x2 = x2;
data.similar  = similar;

H = SupervisedBoostedSSC(data,8);








