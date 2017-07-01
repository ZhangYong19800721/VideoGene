clear all;
close all;

image = imread('000073602.jpg');
image = rgb2ycbcr(image);

load VisualVocabulary_UV.mat;
load VisualVocabulary_Y.mat;

extractor = VisualNucleotideExtractor(VisualVocabulary_Y,VisualVocabulary_UV);

nucleotide = extractor.Extract(image);