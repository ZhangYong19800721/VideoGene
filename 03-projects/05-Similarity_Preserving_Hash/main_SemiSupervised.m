clear all;
close all;

N = 1e3;
[data,similar_pairs] = GenerateData_SemiSupervised(N);
[~,Np] = size(similar_pairs); 
w = (1/Np) * ones(1,Np); 
s = (1/N) * ones(1,N); 


[T,TP,FP] = ThresholdRate_SemiSupervised(data,similar_pairs,@(x)f(x,1),w,s);

H = SSC(data,0.065);








