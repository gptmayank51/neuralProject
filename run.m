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
X = (X - (ones(length(X),1)*mean(X)))./(ones(length(X),1)*std(X)); %normalised features
%coarse grained search for c and gamma
addpath('C:\libsvm\matlab');
maxac = 0;
gammamax = 0;
cmax = 0;
for i=-5:15
    c = 2^i;
    for j = -15:3
        gamma = 2^j;
        options = sprintf('-s 0 -t 2 -c %f -g %f', c, gamma);
        gaus = svmtrain(class,X,options);
        [~,acc,~] = svmpredict(class,X,gaus);
        if acc > maxac
            maxac = acc;
            gammamax = j;
            cmax = i;
        end
    end 
end
%fine grained search
crange = cmax-0.5:0.01:cmax+0.5;
gammarange = gammamax-0.5:0.01:gammamax+0.5;
maxac = 0;
gammamax = 0;
cmax = 0;
for i=1:length(crange)
    c = 2^crange(i);
    for j = 1:length(gammarange)
        gamma = 2^gammarange(j);
        options = sprintf('-s 0 -t 2 -c %f -g %f', c, gamma);
        gaus = svmtrain(class,X,options);
        [~,acc,~] = svmpredict(class,X,gaus);
        if acc > maxac
            maxac = acc;
            gammamax = gamma;
            cmax = c;
        end
    end 
end

options = sprintf('-s 0 -t 2 -c %f -g %f', cmax, gammamax);
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

