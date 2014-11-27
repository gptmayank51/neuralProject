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

testSet = -1;
valSet = -1;
countP = 8;
accu = zeros(1:countP);
precision = zeros(1:countP);
recall = zeros(1:countP);
for opt = 1:countP
    valSet = mod(i+5,countP)+1;
    testSet = mod(i+6,countP)+1;
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
    acc = zeros(21,29);
    for i=-5:15
        c = 2^i;
        for j = -25:3
            gamma = 2^j;
            options = sprintf('-q -s 0 -t 2 -c %f -g %f', c, gamma);
            gaus = svmtrain(class,X,options);
            [~,acc(i+6,j+26),~] = svmpredict(class,X,gaus);
        end 
    end
    temp = find(acc == max(max(acc)));
    median = temp(floor(length(temp)/2));
    [gammamax,cmax] = quorem(median,sym(21));
    cmax = cmax - 6;
    gammamax = gammamax - 26;
    disp('=====================================');
    disp('Fine grained search for gamma');
    disp('=====================================');
    %fine grained search
    crange = cmax-0.5:0.1:cmax+0.5;
    gammarange = gammamax-0.5:0.1:gammamax+0.5;
    acc = zeros(11,11);
    for i=1:length(crange)
        c = 2^crange(i);
        for j = 1:length(gammarange)
            gamma = 2^gammarange(j);
            options = sprintf('-q -s 0 -t 2 -c %f -g %f', c, gamma);
            gaus = svmtrain(class,X,options);
            [~,acc(i,j),~] = svmpredict(class,X,gaus);
        end 
    end
    temp = find(acc == max(max(acc)));
    median = temp(floor(length(temp)/2));
    [gammamax,cmax] = quorem(median,sym(11));
    gamma = 2^gammarange(gammamax);
    c = 2^crange(cmax);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%% TRAINING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    options = sprintf('-s 0 -t 2 -c %f -g %f', c, gamma);
    gaus = svmtrain(trainClass,trainX,options);
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
    accu(opt) = accuracy(1);
    counts = zeros(4,1);
    for i=1:length(testClass)
       if testClass(i)==1 && prediction(i)==1 %TP
           counts(1) = counts(1) + 1;
       elseif testClass(i)==1 && prediction(i)==0 %FN
           counts(2) = counts(2) + 1;
       elseif testClass(i)==0 && prediction(i)==1 %FP
           counts(3) = counts(3) + 1;
       elseif testClass(i)==0 && prediction(i)==0 %TN
           counts(4) = counts(4) + 1;
       end
    end
    precision(opt) = counts(1)/(counts(1)+counts(3));
    recall(opt) = counts(1)/(counts(1)+counts(2));
    fprintf('Accuracy reported is %d\n',accu(opt));
    fprintf('Precision reported is %d\n',precision(opt));
    fprintf('Recall reported is %d\n',recall(opt));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Average accuracy reported is %d\n',mean(acc));
fprintf('Average precision reported is %d\n',mean(precision));
fprintf('Average recall reported is %d\n',mean(recall));