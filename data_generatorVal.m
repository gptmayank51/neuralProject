if exist('../dataValOutput/input.mat', 'file')==2
  delete('../dataValOutput/input.mat');
end
clear;
folders = dir('../dataValOutput/');
tChannels = 0;
totFiles=0;
for i=3:size(folders,1)
    tempC = sprintf('../dataValOutput/%s/channel.mat',folders(i).name);
    load(tempC);
    totFiles = totFiles + length(cLength);
    tChannels = sum(cLength) + tChannels;
    clear cLength;
end
tfread = sprintf('Total no of Validating examples is %d', totFiles);
disp(tfread);
X = zeros(totFiles,21);
class = zeros(totFiles,1);
index = 1;
for i=3:size(folders,1)
    s = sprintf('../dataValOutput/%s/',folders(i).name);
    files = dir(s);
    for j=3:size(files,1)
       if (~strcmpi(files(j).name,'channel.mat'))
           optFile = sprintf('%s/%s',s,files(j).name); 
           load(optFile);
           X(index,:) = features;
           class(index) = Y;
           clear features Y;
           index = index+1;
       end
    end
end
save('../dataValOutput/input.mat','X','class');