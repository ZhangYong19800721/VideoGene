clear all;
close all;

rng(3);
M = 500;
[points,similar] = GenerateData(M);
data.points  = points;
data.similar = similar;
N = length(data.similar);

sph = SimilarityPreservingHash();
sph = sph.train(data,10);

save('sph.mat','sph');










