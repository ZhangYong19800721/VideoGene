function y = linear(points,B,C)
    [~,N] = size(points);
    y = B * points + repmat(C,1,N);
end

