clear all;
close all;

N = 1000; D = 2;
data = 100 * rand(D,N);

s = [];
u = [];

for n = 1:N
    for m = (n+1):N
        if norm(data(:,n) - data(:,m),2) < 20
            s = [s [n m]'];
        else
            u = [u [n m]'];
        end
    end
end


