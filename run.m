disp('=====================================');
disp('TRAINING');
disp('=====================================');
script
disp('=====================================');
disp('Generating X and Y Matrices for 5 fold testing');
disp('=====================================');
data_generator
disp('Training matrices written to mat files');
disp('=====================================');
disp('Validating');
disp('=====================================');
scriptVal
disp('=====================================');
disp('Generating X and Y Matrices for Validating');
disp('=====================================');
data_generatorVal
load('../dataValOutput/input.mat');
disp('=====================================');
disp('Searching For gamma');
disp('=====================================');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Enter Your code here bhale!

% X contains feature vectors
% class contains its classes
gamma =  0.000001;
addpath('C:\libsvm\matlab');


options = sprintf('-s 0 -t 2 -c 1 -g %f', gamma);
%linear = svmtrain(class,X,'-s 0 -t 0 -c 1');
gaus = svmtrain(class,X,options);
save ('model.mat','gaus');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load('model.mat');
disp('=====================================');
disp('Starting 5 Fold Testing');
load('../dataOutput/input.mat');
disp('=====================================');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Yahan mera code aayega!


%svmpredict(class,X,linear);
%svmpredict(class,X,gaus);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

