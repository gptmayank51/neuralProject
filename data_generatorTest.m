% This script picks the clip wise feature vectors and combines them into a single 2D matrix of size M*(feature vector length) for each patient.
% M is no of examples

if (isequal(exist('../MatFiles','dir'),7))
    rmdir('../MatFiles','s');
end
% Final Mat Files are stroed in the Mat Files folder
mkdir('../MatFiles');
clear;
folders = dir('../dataTestOutput/');
% Iterate over all the patient folders
for i=3:size(folders,1)
    % load the channel info mat file contianing info about the no of channels in each clip
    tempC = sprintf('../dataTestOutput/%s/channel.mat',folders(i).name);
    load(tempC);
    totFiles = length(cLength);
    clear cLength;
    tfread = sprintf('Total no of training examples in folder %s is %d',folders(i).name, totFiles);
    disp(tfread);
    % Feature vector of size M*(feature vector length)
    X = zeros(totFiles,21);
    % Class vector of size M
    class = zeros(totFiles,1);
    index = 1;
    s = sprintf('../dataTestOutput/%s/',folders(i).name);
    files = dir(s);
    % Iterate over all the clips of each patients
    for j=3:size(files,1)
       if (~strcmpi(files(j).name,'channel.mat'))
           % Load output file of each clip and append its feature vector into the combined feature matrix
           optFile = sprintf('%s/%s',s,files(j).name); 
           load(optFile);
           X(index,:) = features;
           class(index) = Y;
           clear features Y;
           index = index+1;
       end
    end
    % Save the Feature matrix and class vector in the Matfiles folder
    optFile = sprintf('../MatFiles/%s.mat',folders(i).name);
    save(optFile,'X','class');
end