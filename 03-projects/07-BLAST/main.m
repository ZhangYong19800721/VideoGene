clear all;
close all;

s1 = '9463156AFCDEF106431F'; s1 = symble2digital(s1);
s2 = '56AFCD6431F'; s2 = symble2digital(s2);

score_matrix = -5 * ones(16,16); 
score_matrix = diag(13*ones(1,16)) + score_matrix;

[score,match] = local_alignment(score_matrix,s2,s1,-3);

match = digital2symble(match);