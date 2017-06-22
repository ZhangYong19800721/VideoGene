clear all;
close all;

rng(1)
N = 1e3;
[points,similar] = GenerateData_SemiSupervised(N);
data.points = points;
data.similar = similar;
[~,Np] = size(similar); 
w = (1/Np) * ones(1,Np); 
s = (1/N) * ones(1,N); 

H = SSC_SemiSupervisedBoosted(data,8);








