clear all;
close all;

rng(3)

[points,similar] = GenerateData(200);
data.points  = points;
data.similar = similar;
N = length(data.similar);
w = ones(1,N) ./ N;

scc_adaboost_model = SCC_AdaBoost();
scc_adaboost_model = scc_adaboost_model.train(data,w,30);
y = scc_adaboost_model.predict(points(:,similar(1,:)),points(:,similar(2,:)));
error = sum(y~=similar(3,:)) / length(y);

query = points(:,3); query = repmat(query,1,length(points));
match = scc_adaboost_model.predict(query,points); match = (match>0);

plot(points(1,:),points(2,:),'go');
hold;
plot(query(1,:),query(2,:),'r*');
plot(points(1,match),points(2,match),'bx');
grid on;










