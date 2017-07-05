clear all;
close all;

rng('shuffle')
load sph.mat;

M = 1e4;
points = 200 * rand(2,M);
points = points - repmat([100 100]',1,M);
code = sph.hashcode(points);

query = 200 * rand(2,1) - [100 100]';
query = [0;-20];
query_code = sph.hashcode(query);
query_code = repmat(query_code,1,M);
match_idx = (sph.alfa * xor(query_code,code)) <= 0;

figure;
plot(points(1,:),points(2,:),'go');
hold;
plot(points(1,match_idx),points(2,match_idx),'bx');
plot(query(1,:),query(2,:),'r*');
grid on;