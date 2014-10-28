clear;
folders = dir('../dataOutput/');
tChannels = 0;
for i=3:size(folders,1)
    tempC = sprintf('../dataOutput/%s/channel.mat',folders(i).name);
    load(tempC);
    tChannels = sum(cLength) + tChannels;
end
