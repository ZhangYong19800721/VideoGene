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

code = sph.hashcode(points);

query = floor(200 * rand(2,1)) - [100 100]';
query_code = sph.hashcode(query);
query_code = repmat(query_code,1,M);
match_idx = (sph.alfa * xor(query_code,code)) <= 0;

figure;
plot(points(1,:),points(2,:),'go');
hold;
plot(query(1,:),query(2,:),'r*');
plot(points(1,match_idx),points(2,match_idx),'bx');
grid on;










