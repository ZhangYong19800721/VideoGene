clear all;
close all;

similarity_part01 = csvread('similarity_part01.txt'); 
similarity_part02 = csvread('similarity_part02.txt'); 
similarity_part03 = csvread('similarity_part03.txt'); 
similarity_part04 = csvread('similarity_part04.txt'); 
similarity_part05 = csvread('similarity_part05.txt'); 
similarity_part06 = csvread('similarity_part06.txt'); 
similarity_part07 = csvread('similarity_part07.txt'); 
similarity_part08 = csvread('similarity_part08.txt');

similarity = [similarity_part01;
              similarity_part02;
              similarity_part03;
              similarity_part04;
              similarity_part05;
              similarity_part06;
              similarity_part07;
              similarity_part08];
          
similarity = similarity';

load('nucleotides.mat');

data.points = nucleotide;
data.similar = similarity;

SPH = SimilarityPreservingHashL1();

SPH = SPH.train(data,64,'semisupervised_partial',0.05,1e-4,1e4,2.72e-5);

save('SPH.mat','SPH');










