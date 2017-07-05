clear all;
close all;

rng(3);
M = 500;
[points,similar] = GenerateData(M);
data.points  = points;
data.similar = similar;

sph = SimilarityPreservingHashLinear();
sph = sph.train(data,10,'semisupervised_partial');

save('sph.mat','sph');










