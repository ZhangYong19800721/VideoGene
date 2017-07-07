clear all
close all

rng('shuffle')

load('adaboost_model.mat');

[points,labels] = GenerateData2(5000);

y = adaboost_model.predict(points);

group1 = points(:,y==+1);
group2 = points(:,y==-1);

figure(1); hold;
plot(group1(1,:),group1(2,:),'go');
plot(group2(1,:),group2(2,:),'bx');

error = sum(y~=labels) ./ length(y)

for n=1:length(adaboost_model.hypothesis)
    B = adaboost_model.hypothesis{n}.h_func.f_func.B;
    C = adaboost_model.hypothesis{n}.h_func.f_func.C;
    ezplot(@(x,y)func_linear_2D(x,y,B,C),[-15 15 -10 10]);
end

grid on;