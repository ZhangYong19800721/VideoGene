function symble = digital2symble(digital)
%DIGITAL2SYMBLE ������ת��Ϊ����
%   
    symble = char(digital);
    idx_part1 =  1 <= digital & digital <= 10;
    idx_part2 = 11 <= digital & digital <= 16;
    idx_part3 =  0 == digital;
    symble(idx_part1) = char(digital(idx_part1) + 47); %  1~10ת��Ϊ'0'~'9'
    symble(idx_part2) = char(digital(idx_part2) + 54); % 11~16ת��Ϊ'A'~'F'
    symble(idx_part3) = char(digital(idx_part3) + 45); % 0ת��Ϊ'-'����
end

