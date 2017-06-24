function C = hashcode(obj,points) 
%HASHCODE ½«points±àÂëÎªhashÂë
%   
    [~,N] = size(points); 
    M = length(obj.alfa);
    C = zeros(M,N);
    
    for m = 1:M
        func = obj.hypothesis{m}.func_handle;
        d = obj.hypothesis{m}.dimension;
        T = obj.hypothesis{m}.threshold;
        C(m,:) = (func(points,d) <= T);
    end
end

