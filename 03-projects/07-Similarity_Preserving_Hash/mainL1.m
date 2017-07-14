clear all;
close all;

rng(2);
M = 200;
[points,similar] = GenerateDataL1(M);
similar_percent = sum(similar(3,:)>0) / length(similar(3,:))
data.points  = points;
data.similar = similar;

sph_L1 = SimilarityPreservingHashL1();

sph_L1 = sph_L1.train(data,10,'supervised',0.1,1e-3,1e4);
% 'semisupervised'
% 'semisupervised_partial'

save('sph_L1.mat','sph_L1');










