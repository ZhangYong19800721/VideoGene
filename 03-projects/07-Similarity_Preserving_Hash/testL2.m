clear all;
close all;

rng('shuffle')
load sph_L2.mat;

M = 1e4;
points = 200 * rand(2,M);
points = points - repmat([100 100]',1,M);
code = sph_L2.hashcode(points);

query = 200 * rand(2,1) - [100 100]';
% query = [0;-25];
query_code = sph_L2.hashcode(query);
query_code = repmat(query_code,1,M);
match_idx = (sph_L2.alfa * xor(query_code,code)) <= 0;

figure(1); hold;
plot(points(1,:),points(2,:),'yo')
plot(points(1,match_idx),points(2,match_idx),'bx')
plot(query(1,:),query(2,:),'r*')
axis([-100 100 -100 100]); 

for n=1:length(sph_L2.hypothesis)
    A = sph_L2.hypothesis{n}.f_func.A;
    B = sph_L2.hypothesis{n}.f_func.B;
    C = sph_L2.hypothesis{n}.f_func.C;
    ezplot(@(x,y)func_quadratic_2D(x,y,A,B,C),[-100 100 -100 100]);
end

grid on;
