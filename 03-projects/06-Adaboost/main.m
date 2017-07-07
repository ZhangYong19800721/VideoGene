clear all
close all

rng(1)
[points,labels] = GenerateData(500);
group1 = points(:,labels==+1);
group2 = points(:,labels==-1);

plot(group1(1,:),group1(2,:),'go');
hold;
plot(group2(1,:),group2(2,:),'bx');
grid on;

data.points = points;
data.labels = labels;

adaboost_model = AdaBoost();
adaboost_model = adaboost_model.train(data,2,1e4);

