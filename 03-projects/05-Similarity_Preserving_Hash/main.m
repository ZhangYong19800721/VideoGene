clear all;
close all;

N = 1e3;
[x1,x2,l] = GenerateData(N);
data.x1 = x1;
data.x2 = x2;
data.l  = l;
w = (1/N) * ones(1,N); 

[T,TP,FP] = ThresholdRate(data,@(x)f(x,1),w);

H = SSC(data,0.065);








