function [score, match] = global_alignment(score_matrix, sequence1, sequence2, gap)
%GLOBAL_ALIGNMENT 两个序列的全局比对
%   输入：
%       score_matrix: 打分矩阵
%       sequence1：   第1个序列
%       sequence2：   第2个序列
%       gap:          空位罚分
%   输出：
%       score:        两个序列匹配的分值
%       match：       匹配的序列
    
    M = length(sequence1); % 第一个序列的长度
    N = length(sequence2); % 第二个序列的长度
    C = zeros(N+1,M+1);    % 计分矩阵
    B = zeros(N+1,M+1);    % 回溯矩阵
    
    C(1,:) = linspace(0,gap*M,M+1);
    C(:,1) = linspace(0,gap*N,N+1);
    
    for i = 2:(N+1)
        for j = 2:(M+1)
            [C(i,j),B(i,j)] = max([C(i-1,j-1)+score_matrix(sequence2(i-1),sequence1(j-1)); C(i-1,j)+gap; C(i,j-1)+gap]);
        end
    end
    
    score = C(N+1,M+1);
    match = [];
    
    pos = [N+1 M+1];
    while true
        switch B(pos(1),pos(2))
            case 1
                match = [[sequence1(pos(2)-1); sequence2(pos(1)-1)] match];
                pos = pos - [1 1];
            case 2
                match = [[0; sequence2(pos(1)-1)] match];
                pos = pos - [1 0];
            case 3
                match = [[sequence1(pos(2)-1); 0] match];
                pos = pos - [0 1];
            case 0
                if pos(1) > 1
                    match = [[0; sequence2(pos(1)-1)] match];
                    pos = pos - [1 0];
                elseif pos(2) > 1
                    match = [[sequence1(pos(2)-1); 0] match];
                    pos = pos - [0 1];
                elseif pos(1) == 1 && pos(2) == 1
                    break;
                end
            otherwise
                disp('error');
        end
    end  
end

