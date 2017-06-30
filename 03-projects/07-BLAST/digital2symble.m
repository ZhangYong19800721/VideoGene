function symble = digital2symble(digital)
%DIGITAL2SYMBLE 将数字转换为符号
%   
    symble = char(digital);
    idx_part1 =  1 <= digital & digital <= 10;
    idx_part2 = 11 <= digital & digital <= 16;
    idx_part3 =  0 == digital;
    symble(idx_part1) = char(digital(idx_part1) + 47); %  1~10转换为'0'~'9'
    symble(idx_part2) = char(digital(idx_part2) + 54); % 11~16转换为'A'~'F'
    symble(idx_part3) = char(digital(idx_part3) + 45); % 0转换为'-'符号
end

