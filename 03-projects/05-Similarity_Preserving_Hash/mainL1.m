clear all;
close all;

rng(2);
M = 300;
[points,similar] = GenerateDataL1(M);
similar_percent = sum(similar(3,:)>0) / length(similar(3,:))
data.points  = points;
data.similar = similar;

sph = SimilarityPreservingHashL1();

% sph = sph.train(data,10,'supervised',0.05,1e-3,1e4);
sph = sph.train(data,30,'semisupervised',0.05,1e-3,1e4);
% sph = sph.train(data,2,'semisupervised_partial',0.05,1e-4,1e4,0.5);

save('sph.mat','sph');










