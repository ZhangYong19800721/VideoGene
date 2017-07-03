clear all;
close all;

image_base_dir = 'D:\VideoGene\02-TrainData\imagebasev3\';
file_type = '*.jpg';

nucleotide = ConstructNucleotideData(image_base_dir,file_type);

save('nucleotide.mat','nucleotide');

