function digital = symble2digital(symble)
%SYMBLE2DIGITAL 此处显示有关此函数的摘要
%   此处显示详细说明
    idx_part1 =  '0' <= symble & symble <= '9';
    idx_part2 =  'A' <= symble & symble <= 'F';
    digital(idx_part1) = uint8(symble(idx_part1) - 47);
    digital(idx_part2) = uint8(symble(idx_part2) - 54);
end

