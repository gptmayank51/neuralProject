load('../dataOutput/input.mat');
addpath('C:\libsvm\matlab');
linear = svmtrain(class,X,'-s 0 -t 0 -c 1');
