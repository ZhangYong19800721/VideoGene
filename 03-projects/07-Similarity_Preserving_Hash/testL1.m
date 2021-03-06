clear all;
close all;

rng('shuffle')
load sph_L1.mat;

M = 1e4;
points = 200 * rand(2,M);
points = points - repmat([100 100]',1,M);
code = sph_L1.hashcode(points);

query = 200 * rand(2,1) - [100 100]';
%query = [0;-1];
query_code = sph_L1.hashcode(query);
query_code = repmat(query_code,1,M);
match_idx = (sph_L1.alfa * xor(query_code,code)) <= 0.1;

figure(1); hold;
plot(points(1,:),points(2,:),'yo')
plot(points(1,match_idx),points(2,match_idx),'bx')
plot(query(1,:),query(2,:),'r*')
axis([-100 100 -100 100]); 

%sph_L1 = sph_L1.sort();

for n=1:length(sph_L1.hypothesis)
    B = sph_L1.hypothesis{n}.f_func.B;
    C = sph_L1.hypothesis{n}.f_func.C;
    ezplot(@(x,y)func_linear_2D(x,y,B,C),[-100 100 -100 100]);
end

grid on;
