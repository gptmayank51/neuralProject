disp('=====================================');
disp('TRAINING');
disp('=====================================');
script
disp('=====================================');
disp('Generating X and Y Matrices for Training');
disp('=====================================');
data_generator
load('../dataOutput/input.mat');
addpath('C:\libsvm\matlab');
disp('=====================================');
disp('Training using SVM');
disp('=====================================');
linear = svmtrain(class,X,'-s 0 -t 0 -c 1');
%options = sprintf('-s 0 -t 2 -c 1 -g %f', gam);
save ('model.mat','linear');
disp('=====================================');
disp('TESTING');
disp('=====================================');
scriptTest
disp('=====================================');
disp('Generating X and Y Matrices for Testing');
disp('=====================================');
data_generatorTest
load('../dataTestOutput/input.mat');
disp('=====================================');
disp('Testing on samples');
disp('=====================================');
load('model.mat');
svmpredict(class,X,linear);