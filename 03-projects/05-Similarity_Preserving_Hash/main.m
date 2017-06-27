clear all;
close all;

rng(5);
M = 500;
[points,similar] = GenerateData(M);
data.points  = points;
data.similar = similar;

sph = SimilarityPreservingHash();
sph = sph.train(data,10,'semisupervised');

save('sph.mat','sph');










