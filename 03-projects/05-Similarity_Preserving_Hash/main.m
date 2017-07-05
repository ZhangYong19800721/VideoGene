clear all;
close all;

rng(3);
M = 500;
[points,similar] = GenerateData(M);
data.points  = points;
data.similar = similar;

sph = SimilarityPreservingHashL1();

% sph = sph.train(data,10,'supervised');
% sph = sph.train(data,10,'semisupervised',0.05,1e-4,1e4);
sph = sph.train(data,10,'semisupervised_partial',0.05,1e-4,1e4,0.5);

save('sph.mat','sph');










