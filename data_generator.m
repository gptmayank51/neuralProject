
if exist('../dataOutput/input.mat', 'file')==2
  delete('../dataOutput/input.mat');
end
clear;
folders = dir('../dataOutput/');
tChannels = 0;
totFiles=0;
for i=3:size(folders,1)
    tempC = sprintf('../dataOutput/%s/channel.mat',folders(i).name);
    load(tempC);
    totFiles = totFiles + length(cLength);
    tChannels = sum(cLength) + tChannels;
    clear cLength;
end
tfread = sprintf('Total no of training examples is %d', totFiles);
disp(tfread);
X = zeros(totFiles,21);
class = zeros(totFiles,1);
index = 1;
for i=3:size(folders,1)
    s = sprintf('../dataOutput/%s/',folders(i).name);
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
save('../dataOutput/input.mat','X','class');