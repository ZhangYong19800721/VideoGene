clear all;
close all;

[points,similar] = GenerateDataL1(1e3);

positive_pair = similar(:,similar(3,:)==+1);
negative_pair = similar(:,similar(3,:)==-1);

P = [points(:,positive_pair(1,:))' points(:,positive_pair(2,:))'; ...
     points(:,positive_pair(2,:))' points(:,positive_pair(1,:))'];
 
N = [points(:,negative_pair(1,:))' points(:,negative_pair(2,:))'; ...
     points(:,negative_pair(2,:))' points(:,negative_pair(1,:))'];
 
Cp = cov(P); Cp = Cp(1:2,3:4);
Cn = cov(N); Cn = Cn(1:2,3:4);

sqrt_Cp = sqrtm(Cp);
sqrt_Cn = sqrtm(Cn);

A = inv(sqrt_Cp) * sqrt_Cn;
[V,D] = eig(A);
 
 













