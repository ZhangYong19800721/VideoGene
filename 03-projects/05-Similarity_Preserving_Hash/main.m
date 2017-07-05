clear all;
close all;

rng(3);
M = 200;
[points,similar] = GenerateData(M);
data.points  = points;
data.similar = similar;

sph = SimilarityPreservingHash();

sph = sph.train(data,10,'supervised');
% sph = sph.train(data,10,'semisupervised');
% sph = sph.train(data,10,'semisupervised_partial');

save('sph.mat','sph');










