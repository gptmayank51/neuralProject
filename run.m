disp('=====================================');
disp('TRAINING');
disp('=====================================');
script
disp('=====================================');
disp('=====================================');
disp('Validating');
disp('=====================================');
scriptVal
disp('Generating X and Y Matrices for 5 fold testing');
disp('=====================================');
data_generator
disp('Training matrices written to mat files');
disp('=====================================');
disp('Generating X and Y Matrices for Validating');
disp('=====================================');
data_generatorVal
load('../dataValOutput/input.mat');
disp('=====================================');
disp('Searching For gamma');
disp('=====================================');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for opt=1:8
    valSet = mod(opt+5,8)+1;
    testSet = mod(opt+6,8)+1;
    valMat = sprintf('../MatFiles/Patient_%dOutput',valSet);
    testMat = sprintf('../MatFiles/Patient_%dOutput',testSet);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% VALIDATION %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    load(valMat);
    % X contains feature vectors
    % class contains its classes
    X = (X - (ones(size(X,1),1)*mean(X)))./(ones(size(X,1),1)*std(X)); %normalised features
    %coarse grained search for c and gamma
    addpath('C:\Users\seizure-detection\Desktop\nn\libsvm-3.20\libsvm-3.20\matlab');
    maxac = 0;
    gammamax = 0;
    cmax = 0;
    for i=-5:15
        c = 2^i;
        for j = -25:3
            gamma = 2^j;
            options = sprintf('-q -s 0 -t 2 -c %f -g %f', c, gamma);
            gaus = svmtrain(class,X,options);
            [~,acc,~] = svmpredict(class,X,gaus);
            if acc(1) > maxac(1)
                maxac = acc;
                gammamax = j;
                cmax = i;
            end
        end 
    end
    disp('=====================================');
    disp('Fine grained search for gamma');
    disp('=====================================');
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
            options = sprintf('-q -s 0 -t 2 -c %f -g %f', c, gamma);
            gaus = svmtrain(class,X,options);
            [~,acc,~] = svmpredict(class,X,gaus);
            if acc(1) > maxac(1)
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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%% Testing %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load('model.mat');
disp('=====================================');
disp('Starting 5 Fold Testing');
load('../dataOutput/input.mat');
disp('=====================================');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
perm = randperm(size(X,1));
X = X(perm,:);
class = class(perm);
acc = zeros(1:5);
counts = zeros(5,4);
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
   [prediction, accuracy, ~] = svmpredict(testClass,testX,gaus);
   acc(j) = accuracy(1);
   for i=1:length(testClass)
       if testClass(i)==1 && prediction(i)==1 %TP
           counts(j,1) = counts(j,1) + 1;
       elseif testClass(i)==1 && prediction(i)==0 %FN
           counts(j,2) = counts(j,2) + 1;
       elseif testClass(i)==0 && prediction(i)==1 %FP
           counts(j,3) = counts(j,3) + 1;
       elseif testClass(i)==0 && prediction(i)==0 %TN
           counts(j,4) = counts(j,4) + 1;
       end
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%