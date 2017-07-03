clear all;
close all;

rng(16);
M = 500;
[points,similar] = GenerateData(M);
data.points  = points;
data.similar = similar;

sph = SimilarityPreservingHash();
sph = sph.train(data,10,'semisupervised_partial');

save('sph.mat','sph');










