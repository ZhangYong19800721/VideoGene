function y = axis(points,D,T)
    [~,N] = size(points);
    y = points(D,:) + repmat(T,1,N);
end

