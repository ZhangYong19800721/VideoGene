clear all
close all

rng(1)
[points,labels] = GenerateData2(5000);
group1 = points(:,labels==+1);
group2 = points(:,labels==-1);

plot(group1(1,:),group1(2,:),'go');
hold;
plot(group2(1,:),group2(2,:),'bx');
grid on;

data.points = points;
data.labels = labels;

adaboost_model = AdaBoost();
adaboost_model = adaboost_model.train(data,10,1e-1,1e-3,1e4);

save('adaboost_model.mat','adaboost_model');
