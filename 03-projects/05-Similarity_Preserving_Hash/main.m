clear all;
close all;

rng(3)

[points,similar] = GenerateData(200);
% »­Í¼
% group1 = [points(similar(1,similar(3,:)==+1)); points(similar(2,similar(3,:)==+1))];
% group2 = [points(similar(1,similar(3,:)==-1)); points(similar(2,similar(3,:)==-1))];
% figure(1);
% plot(group1(1,:),group1(2,:),'go');
% hold;
% plot(group2(1,:),group2(2,:),'bx');

data.points  = points;
data.similar = similar;
N = length(data.similar);
w = ones(1,N) ./ N;

scc_supervised_boosted_model = SCC_SupervisedBoosted();
scc_supervised_boosted_model = scc_supervised_boosted_model.train(data,w,10);
code = scc_supervised_boosted_model.hashcode(points);

% y = scc_supervised_boosted_model.predict(points(:,similar(1,:)),points(:,similar(2,:)));
% error = sum(y~=similar(3,:)) / length(y);

query = [70 90]';
query_code = scc_supervised_boosted_model.hashcode(query);
query_code = repmat(query_code,1,200);
match_idx = (scc_supervised_boosted_model.alfa * xor(query_code,code)) <= 0.2;

plot(points(1,:),points(2,:),'go');
hold;
plot(query(1,:),query(2,:),'r*');
plot(points(1,match_idx),points(2,match_idx),'bx');
grid on;










