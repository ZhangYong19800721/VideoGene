clear all;
close all;

rng('shuffle')
load sph.mat;

M = 1e4;
points = 200 * rand(2,M);
points = points - repmat([100 100]',1,M);
code = sph.hashcode(points);

query = 200 * rand(2,1) - [100 100]';
%query = [0;-20];
query_code = sph.hashcode(query);
query_code = repmat(query_code,1,M);
match_idx = (sph.alfa * xor(query_code,code)) <= 0.1;

figure(1); hold;
plot(points(1,:),points(2,:),'go')
plot(points(1,match_idx),points(2,match_idx),'bx')
plot(query(1,:),query(2,:),'r*')
axis([-100 100 -100 100]); 

for n=1:length(sph.hypothesis)
    a = sph.hypothesis{n}.f_func.B(1);
    b = sph.hypothesis{n}.f_func.B(2);
    c = sph.hypothesis{n}.f_func.C;
    x = -100:0.01:100;
    plot(x,-a * x / b - c/b,'M');
end

grid on;
