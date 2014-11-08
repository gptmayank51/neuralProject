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
perm = randperm(size(X,1));
X = X(perm,:);
class = class(perm);
acc = zeros(1:5);
for j=1:5
    
   %Add code to randomize X
   
   testLower = (j-1)*size(X,1)/5 +1;
   testUpper = (j)*size(X,1)/5;
   
   trainX = zeros(size(X,1) - size(X,1)/5,size(X,2));
   trainClass = zeros(size(X,1) - size(X,1)/5,1);
   trainX(1:testLower - 1,:) = X(1:testLower -1,:);
   trainX(testLower:end,:) = X(testUpper+1:end,:);
   trainClass(1:testLower - 1) = class(1:testLower -1);
   trainClass(testLower:end) = class(testUpper+1:end);
   
   testX = X(testLower:testUpper,:);
   testClass = class(testLower:testUpper);
   svmpredict(testClass,textX,gaus);
   acc(j) = accuracy;
end

%svmpredict(class,X,linear);
%svmpredict(class,X,gaus);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

