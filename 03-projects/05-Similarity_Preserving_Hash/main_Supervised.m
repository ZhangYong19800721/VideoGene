clear all;
close all;

rng(2)
N = 1e3;
[points,similar] = GenerateData_Supervised(N);
data.points  = points;
data.similar = similar;

H = SSC_SupervisedBoosted(data,8);

Q = 2;
query = points(:,Q);
match = [];
for n = 1:N
    if n ~= Q
        if 1 == Ensemble_Classifier(H,query,points(:,n))
            match = [match points(:,n)];
        end
    end
end

plot(points(1,:),points(2,:),'go');
hold;
plot(query(1,:),query(2,:),'r*');
plot(match(1,:),match(2,:),'bx');










