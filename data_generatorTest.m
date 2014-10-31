clear;
folders = dir('../dataTestOutput/');
tChannels = 0;
totFiles=0;
for i=3:size(folders,1)
    tempC = sprintf('../dataTestOutput/%s/channel.mat',folders(i).name);
    load(tempC);
    totFiles = totFiles + length(cLength);
    tChannels = sum(cLength) + tChannels;
    clear cLength;
end
tfread = sprintf('Total no of testing examples is %d', totFiles);
disp(tfread);
X = zeros(totFiles,21);
class = zeros(totFiles,1);
index = 1;
for i=3:size(folders,1)
    s = sprintf('../dataTestOutput/%s/',folders(i).name);
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
save('../dataTestOutput/input.mat','X','class');