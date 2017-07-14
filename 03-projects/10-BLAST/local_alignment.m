function [score, match] = local_alignment(score_matrix, sequence1, sequence2, gap)
%LOCAL_ALIGNMENT �������еľֲ��ȶ�
%   ���룺
%       score_matrix: ��־���
%       sequence1��   ��1������
%       sequence2��   ��2������
%       gap:          ��λ����
%   �����
%       score:        ��������ƥ��ķ�ֵ
%       match��       ƥ�������
    
    M = length(sequence1); % ��һ�����еĳ���
    N = length(sequence2); % �ڶ������еĳ���
    C = zeros(N+1,M+1);    % �Ʒ־���
    B = zeros(N+1,M+1);    % ���ݾ���
    
    for i = 2:(N+1)
        for j = 2:(M+1)
            [C(i,j),B(i,j)] = max([C(i-1,j)+gap; C(i,j-1)+gap; C(i-1,j-1)+score_matrix(sequence2(i-1),sequence1(j-1)); 0]);
        end
    end
    
    score = C(N+1,M+1);
    match = [];
    
    pos = [N+1 M+1];
    while true
        switch B(pos(1),pos(2))
            case 0
                break;
            case 1
                if ~isempty(match)
                    match = [[0; sequence2(pos(1)-1)] match];
                end
                pos = pos - [1 0];
            case 2
                if ~isempty(match)
                    match = [[sequence1(pos(2)-1); 0] match];
                end
                pos = pos - [0 1];
            case 3
                match = [[sequence1(pos(2)-1); sequence2(pos(1)-1)] match];
                pos = pos - [1 1];
            case 4
                break;
            otherwise
                disp('error');
        end
    end      
end

