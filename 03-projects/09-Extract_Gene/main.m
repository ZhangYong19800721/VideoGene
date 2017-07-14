clear all;
close all;

[points,similar] = GenerateDataL1(1e3);

positive_pair = similar(:,similar(3,:)==+1);
negative_pair = similar(:,similar(3,:)==-1);

P = points(:,positive_pair(1,:)) - points(:,positive_pair(2,:)); P = P';
N = points(:,negative_pair(1,:)) - points(:,negative_pair(2,:)); N = N';
 
Cp = cov(P); 
Cn = cov(N); 

sqrt_Cp = sqrtm(Cp);
sqrt_Cn = sqrtm(Cn);

A = inv(sqrt_Cp) * sqrt_Cn;
[V,D] = eig(A);
 
 













