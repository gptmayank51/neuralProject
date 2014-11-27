% disp('=====================================');
% disp('TRAINING');
% disp('=====================================');
% script
% disp('=====================================');
% disp('=====================================');
% disp('Validating');
% disp('=====================================');
% scriptVal
% disp('Generating X and Y Matrices for 5 fold testing');
% disp('=====================================');
% data_generator
% disp('Training matrices written to mat files');
% 
% data_generatorVal
% load('../dataValOutput/input.mat');
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
delete('myTextLog.txt');
diary('myTextLog.txt');
disp('=====================================');
disp('=====================================');
fprintf('New session started');
disp('=====================================');
disp('=====================================');
testSet = -1;
valSet = -1;
countP = 8;
acc = zeros(1:countP);
counts = zeros(countP,4);
for opt = 1:countP
    valSet = mod(opt+5,countP)+1;
    testSet = mod(opt+6,countP)+1;
    disp('=====================================');
    fprintf('Generating X and Y Matrices for Training, Iteration no %d\n',opt);
    disp('=====================================');
    trainX = [];
    trainClass = [];
    for i=1:countP        
        if (i ~= valSet && i ~= testSet)
           file = sprintf('../MatFiles/Patient_%dOutput.mat',i);
           load(file);
           trainX =  [trainX ; X];
           trainClass = [trainClass ; class];
           clear X class
        end
    end

    disp('=====================================');
    disp('Searching For gamma');
    disp('=====================================');

    %%%%%%%%%%%%%%%%%%%%%%%%%% VALIDATION %%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear X class
    valMat = sprintf('../MatFiles/Patient_%dOutput.mat',valSet);
    load(valMat);

    % X contains feature vectors
    % class contains its classes
    X = (X - (ones(size(X,1),1)*mean(X)))./(ones(size(X,1),1)*std(X)); %normalised features
    %coarse grained search for c and gamma
    addpath('C:\Users\seizure-detection\Desktop\nn\libsvm-3.20\libsvm-3.20\matlab');
    maxac = 0;
    gammamax = 0;
    cmax = 0;
    for i=-5:10
        c = 2^i;
        for j = -15:3
            gamma = 2^j;
            options = sprintf('-q -s 0 -t 2 -c %f -g %f', c, gamma);
            gaus = svmtrain(trainClass,trainX,options);
            [~,acc,~] = svmpredict(class,X,gaus);
            if acc(1) > maxac(1)
                maxac = acc;
                gammamax = j;
                cmax = i;
            end
        end
        disp('=====================================');
        fprintf('Coarse grained search for gamma - Iteration over %d\n',i);
        disp('=====================================');
    end
    disp('=====================================');
    disp('Fine grained search for gamma');
    disp('=====================================');
    %fine grained search
    crange = cmax-0.5:0.2:cmax+0.5;
    gammarange = gammamax-0.5:0.2:gammamax+0.5;
    maxac = 0;
    gammamax = 0;
    cmax = 0;
    for i=1:length(crange)
        c = 2^crange(i);
        for j = 1:length(gammarange)
            gamma = 2^gammarange(j);
            options = sprintf('-q -s 0 -t 2 -c %f -g %f', c, gamma);
            gaus = svmtrain(trainClass,trainX,options);
            [~,acc,~] = svmpredict(class,X,gaus);
            if acc(1) > maxac(1)
                maxac = acc;
                gammamax = gamma;
                cmax = c;
            end
        end
        disp('=====================================');
        fprintf('Fine grained search for gamma - Iteration over %d\n',i);
        disp('=====================================');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%% TRAINING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp('=====================================');
    fprintf('Optimal Gamma is %d, C is %d, Training Starting now!!\n',gammamax,cmax);
    disp('=====================================');
    options = sprintf('-s 0 -t 2 -c %f -g %f', cmax, gammamax);
    %linear = svmtrain(class,X,'-s 0 -t 0 -c 1');
    gaus = svmtrain([trainClass; class],[trainX; X],options);
    save ('model.mat','gaus');

    %%%%%%%%%%%%%%%%%%%%%%%%%%% TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear X class
    testMat = sprintf('../MatFiles/Patient_%dOutput.mat',testSet);

    load('model.mat');
    disp('=====================================');
    disp('Starting Testing');
    disp('=====================================');
    
    load(testMat);
    % X contains feature vectors
    % class contains its classes
    [prediction, accuracy, ~] = svmpredict(class,X,gaus);
    acc(opt) = accuracy(1);
    for i=1:length(class)
       if class(i)==1 && prediction(i)==1 %TP
           counts(opt,1) = counts(opt,1) + 1;
       elseif class(i)==1 && prediction(i)==-1 %FN
           counts(opt,2) = counts(opt,2) + 1;
       elseif class(i)==-1 && prediction(i)==1 %FP
           counts(opt,3) = counts(opt,3) + 1;
       elseif class(i)==-1 && prediction(i)==-1 %TN
           counts(opt,4) = counts(opt,4) + 1;
       end
    end
    fprintf('Accuracy reported is %d\n',acc(opt));
    disp('Count is');
    disp(counts);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Average accruacy reported is %d\n',mean(acc));
diary('off');