% This is for the case when we are taking equal no of ictal and interictal examples in "../dataTest"
% Here the input patient wise files need to be in "../MatFilesEqual" folder
% So you will have to manually update the data_generator scipt to write its output to ../MatFilesEqual instead of ../MatFiles
% Script to run LibSVM by dividing the patient set into train, validation and test set
% Outputs the Accuracy, F measure, Precison & Recall
clear;
if exist('myTextLogEqual.txt', 'file')==2
    delete('myTextLogEqual.txt');
end
% Log the output of matlab into a file
diary('myTextLogEqual.txt');
disp('=====================================');
disp('=====================================');
fprintf('New session started\n');
disp('=====================================');
disp('=====================================');
testSet = -1;
valSet = -1;
countP = 8;
% Variable to store results like accuracy, F measure, recall, precision etc.
accu = zeros(countP,1);
precision = zeros(countP,1);
fmeasure = zeros(countP,1);
recall = zeros(countP,1);
% Iterate over entire data taking one patient as test set (given by testSet), one as validation set (given by valSet)
% and the remaining as training set
for opt = 1:countP
    valSet = mod(opt+5,countP)+1;
    testSet = mod(opt+6,countP)+1;
    disp('=====================================');
    fprintf('Generating X and Y Matrices for Training, Iteration no %d\n',opt);
    disp('=====================================');
    % Populate the training set
    trainX = [];
    trainClass = [];
    for i=1:countP        
        if (i ~= valSet && i ~= testSet)
           file = sprintf('../MatFilesEqual/Patient_%dOutput.mat',i);
           load(file);
           trainX =  [trainX ; X];
           trainClass = [trainClass ; class];
           clear X class
        end
    end
    % Normailze the data
    trainX = (trainX-ones(length(trainX),1)*mean(trainX))./(ones(length(trainX),1)*std(trainX));

    disp('=====================================');
    disp('Searching For gamma');
    disp('=====================================');

    %%%%%%%%%%%%%%%%%%%%%%%%%% VALIDATION %%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear X class
    valMat = sprintf('../MatFilesEqual/Patient_%dOutput.mat',valSet);
    % Load the patient data that will be used for validation
    load(valMat);

    % X contains feature vectors
    % class contains its classes
    X = (X - (ones(size(X,1),1)*mean(X)))./(ones(size(X,1),1)*std(X)); %normalised features
    %coarse grained search for c and gamma
    % Iterate over c & gamma and find out the one which gives the best result
    addpath('C:\Users\seizure-detection\Desktop\nn\libsvm-3.20\libsvm-3.20\matlab');
    maxac = 0;
    gammamax = 0;
    cmax = 0;
    for i=-10:15
        c = 2^i;
        for j = -25:10
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
    % Using the best value of c & gamma obtained in the previous one, use the range of +- 0.5 from the true value
    % and do a fine grained search to find the best value of c and gammma
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
    % Using the best value of c &  gamma, generate a model to be used on the training set
    disp('=====================================');
    fprintf('Optimal Gamma is %d, C is %d, Training Starting now!!\n',gammamax,cmax);
    disp('=====================================');
    options = sprintf('-s 0 -t 2 -c %f -g %f', cmax, gammamax);
    %linear = svmtrain(class,X,'-s 0 -t 0 -c 1');
    gaus = svmtrain([trainClass; class],[trainX; X],options);
    save ('model.mat','gaus');

    %%%%%%%%%%%%%%%%%%%%%%%%%%% TESTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear X class
    testMat = sprintf('../MatFilesEqual/Patient_%dOutput.mat',testSet);

    load('model.mat');
    disp('=====================================');
    disp('Starting Testing');
    disp('=====================================');
    
    load(testMat);
    X = (X - (ones(size(X,1),1)*mean(X)))./(ones(size(X,1),1)*std(X)); %normalised features

    % X contains feature vectors
    % class contains its classes
    % Calculate accuracy and other measures
    [prediction, accuracy, ~] = svmpredict(class,X,gaus);
    accu(opt) = accuracy(1);
    counts = zeros(4,1);
    for i=1:length(class)
       if class(i)==1 && prediction(i)==1 %TP
           counts(1) = counts(1) + 1;
       elseif class(i)==1 && prediction(i)==-1 %FN
           counts(2) = counts(2) + 1;
       elseif class(i)==-1 && prediction(i)==1 %FP
           counts(3) = counts(3) + 1;
       elseif class(i)==-1 && prediction(i)==-1 %TN
           counts(4) = counts(4) + 1;
       end
    end
    precision(opt) = counts(1)/(counts(1)+counts(3));
    recall(opt) = counts(1)/(counts(1)+counts(2));
    fmeasure(opt) = harmmean([recall(opt), precision(opt)]);
    fprintf('Accuracy reported is %d\n',accu(opt));
    fprintf('Precision reported is %d\n',precision(opt));
    fprintf('Recall reported is %d\n',recall(opt));
    fprintf('F-measure reported is %d\n',fmeasure(opt));
    disp('Count is');
    disp(counts);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Average accuracy reported is %d\n',mean(accu));
fprintf('Average precision reported is %d\n',mean(precision));
fprintf('Average recall reported is %d\n',mean(recall));
fprintf('Average f-measure reported is %d\n',mean(fmeasure));
diary('off');
