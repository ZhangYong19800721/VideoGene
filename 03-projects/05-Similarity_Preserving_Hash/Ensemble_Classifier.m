function is_similar = Ensemble_Classifier(H,x,y)
%ENSEMBLE_CLASSIFIER 此处显示有关此函数的摘要
%   此处显示详细说明
    [M,~] = size(H);
    C = -1 * ones(1,M);
    A = H(:,3);
    
    for m = 1:M
        d = H(m,1); T = H(m,2); 
        func = @(x)project_function(x,d);
        vx = func(x); vy = func(y);
        if (vx <= T && vy <= T) || (vx > T && vy > T)
            C(m) = 1;
        end
    end
    
    is_similar = sign(A'*C');
end

