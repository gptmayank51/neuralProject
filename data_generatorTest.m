if (isequal(exist('../MatFiles','dir'),7))
    rmdir('../MatFiles','s');
end
mkdir('../MatFiles');
clear;
folders = dir('../dataTestOutput/');
for i=3:size(folders,1)
    tempC = sprintf('../dataTestOutput/%s/channel.mat',folders(i).name);
    load(tempC);
    totFiles = length(cLength);
    clear cLength;
    tfread = sprintf('Total no of training examples in folder %s is %d',folders(i).name, totFiles);
    disp(tfread);
    X = zeros(totFiles,21);
    class = zeros(totFiles,1);
    index = 1;
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
    optFile = sprintf('../MatFiles/%s.mat',folders(i).name);
    save(optFile,'X','class');
end