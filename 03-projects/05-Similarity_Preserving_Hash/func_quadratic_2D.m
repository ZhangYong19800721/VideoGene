function y = func_quadratic_2D(x, y, A, B, C)
    y = sum(([x;y]' * A) .* [x;y]',2)' + B * [x;y] + C;
end

