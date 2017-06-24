clear all
close all

rng(1)
[points,labels] = GenerateData3(300);
% group1 = points(:,labels==+1);
% group2 = points(:,labels==-1);
% 
% plot(group1(1,:),group1(2,:),'go');
% hold;
% plot(group2(1,:),group2(2,:),'bx');
% grid on;

data.points = points;
data.labels = labels;
N = length(data.labels);
w = ones(1,N) ./ N;

for n = 1:20
    n
    adaboost_model = AdaBoost();
    adaboost_model = adaboost_model.train(data,w,n);
    predict = adaboost_model.predict(points);
    train_error(n) = sum(predict~=labels) / N
end

% C = adaboost_model.hashcode(points);

% [points_test,labels_test] = GenerateData(1e3);
% predict_test = adaboost_model.predict(points_test);
% test_error = sum(predict_test~=labels_test) / N

