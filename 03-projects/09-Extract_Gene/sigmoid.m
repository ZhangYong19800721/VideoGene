function y = sigmoid(x)
%SIGMOID s形逻辑函数，当x小于T时逐步趋向于+1，当x大于T时逐步趋向于0，当x=T时为0.
%   
    y = 1 ./ (1 + exp(x));
end

