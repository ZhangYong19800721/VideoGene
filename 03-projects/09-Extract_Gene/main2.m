clear all;
close all;

load('nucleotides.mat');

[D,N] = size(nucleotide);

similar01 = csvread('similarity_part01.txt');
similar02 = csvread('similarity_part02.txt');
similar03 = csvread('similarity_part03.txt');
similar04 = csvread('similarity_part04.txt');
similar05 = csvread('similarity_part05.txt');
similar06 = csvread('similarity_part06.txt');
similar07 = csvread('similarity_part07.txt');
similar08 = csvread('similarity_part08.txt');

positive_pairs = [similar01;
                  similar02;
                  similar03;
                  similar04;
                  similar05;
                  similar06;
                  similar07;
                  similar08];

positive_pairs = positive_pairs';

negative_pairs = [1:N;randperm(N)];

P = nucleotide(:,positive_pairs(1,:)) - nucleotide(:,positive_pairs(2,:)); P = P';
N = nucleotide(:,negative_pairs(1,:)) - nucleotide(:,negative_pairs(2,:)); N = N';

Cp = cov(P); 
Cn = cov(N); 

sqrt_Cp = sqrtm(Cp);
sqrt_Cp = real(sqrt_Cp);
sqrt_Cn = sqrtm(Cn);

[V,S] = eigs(sqrt_Cn,sqrt_Cp,10);

