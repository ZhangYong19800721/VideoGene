clear all;
close all;

rng(16);
M = 1000;
[points,similar] = GenerateData(M);
data.points  = points;
data.similar = similar;

sph = SimilarityPreservingHashLinear();
sph = sph.train(data,10,'semisupervised_partial');

save('sph.mat','sph');










