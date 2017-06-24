function obj = train(obj,data,weight,num_weak)
%TRAIN 训练SCC_SupervisedBoosted模型
%   输入：
%   data：训练数据，data.points表示数据点，data.similar包含[i j
%         s]'，其中i和j表示point数组的下标，s表示两个元素是否相似
%         +1表示相似，-1表示不相似
%   weight：初始的权值，要求非负，且sum(weight)=1。
%   num_weak：表示弱分类器的个数
%
%   输出：
%   obj：训练后的SCC_SupervisedBoosted对象   

    [D,~] = size(data.points);  % D数据的维度，N数据的个数
    
    XD = []; XT = [];
    for d = 1:D
        v = any_function(data.points,d);
        u = unique(v); u = sort(u); Nu = length(u); %去除v中的重复数据,排序
        delta = (u(2:Nu) - u(1:(Nu-1))) / 2; Nd = length(delta);
        T = [u(1)-delta(1), u(1:Nd) + delta, u(Nu)+delta(Nd)]; %计算得到所有可能的threshold
        XD = [XD d*ones(1,length(T))];
        XT = [XT T];
    end
 
    K = length(XD); %XD或XT的长度代表了所有可能的选择维度和门限

    for m = 1:num_weak % 迭代开始
        r = zeros(1,K); % 选择一个弱分类器使r最大
        
        for k = 1:K
            weak_classifer = SCC_WeakClassifier(@any_function,XD(k),XT(k)); % 使用f函数和threshold即可得到一个弱分类器
            c = weak_classifer.predict(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
            r(k) = weight * (data.similar(3,:) .* c)';
        end
        
        [r_max,r_idx] = max(r); d_best = XD(r_idx); t_best = XT(r_idx);
        if r_max >= 1 % 代表当前的弱分类器恰好能对所有的训练样例正确分类
            weak_classifer_best = SCC_WeakClassifier(@any_function,d_best,t_best);
            obj.hypothesis{1+length(obj.hypothesis)} = weak_classifer_best;
            obj.alfa = [obj.alfa 1];
            break;
        elseif r_max <= 0 % 代表在弱分类器空间中已经找不到任何有价值的弱分类器【猜错的比猜对的还多】
            break;
        else
            alfa = 0.5 * log((1+r_max)/(1-r_max)); 
        end
        
        weak_classifer_best = SCC_WeakClassifier(@any_function,d_best,t_best);
        obj.hypothesis{1+length(obj.hypothesis)} = weak_classifer_best;
        obj.alfa = [obj.alfa alfa];
 
        c = weak_classifer_best.predict(data.points(:,data.similar(1,:)),data.points(:,data.similar(2,:)));
        weight = weight .* exp(-1 * alfa * data.similar(3,:) .* c);
        weight = weight ./ sum(weight);
    end 
end

