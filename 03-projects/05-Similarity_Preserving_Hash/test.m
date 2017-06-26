clear all;
close all;

rng(1);

load sph.mat;

N = 2000;
points = floor(200 * rand(2,N));
points = points - repmat([100 100]',1,N);
code = sph.hashcode(points);

query = floor(200 * rand(2,1)) - [100 100]';
query_code = sph.hashcode(query);
query_code = repmat(query_code,1,N);
match_idx = (sph.alfa * xor(query_code,code)) <= 0.1;

figure;
plot(points(1,:),points(2,:),'go');
hold;
plot(query(1,:),query(2,:),'r*');
plot(points(1,match_idx),points(2,match_idx),'bx');
grid on;