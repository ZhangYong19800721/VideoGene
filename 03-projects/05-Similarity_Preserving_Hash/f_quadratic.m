function y = f_quadratic(points, A, B, C)
    [~,N] = size(points); % N��ʾ���ݵ������
    y = sum((points' * A) .* points',2)' + B * points + repmat(C,1,N);
end

