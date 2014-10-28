clear;
folders = dir('../data/');
if (isequal(exist('../dataOutput','dir'),7))
        rmdir('../dataOutput','s');
end
mkdir('../dataOutput');
for i=3:size(folders,1)
    s = sprintf('../data/%s', folders(i).name);
    files = dir(s);
    cLength = [];
    optFolder = sprintf('../dataOutput/%sOutput', folders(i).name);
    if (isequal(exist(optFolder,'dir'),7))
        rmdir(optFolder,'s');
    end
    mkdir(optFolder);
    i
    for j=3:size(files,1)
        j
        t = sprintf('../data/%s/%s', folders(i).name, files(j).name);
        optFile = sprintf('%s/%s.mat',optFolder,files(j).name);
        temp = textscan(files(j).name,'%s','delimiter','_');
        if (strcmp(temp{1}{3},'ictal') || strcmp(temp{1}{3},'interictal'))
            if strcmp(temp{1}{3},'ictal')
                Y = 1;
            else
                Y = 0;
            end
            load(t);
            cLength= [cLength ; size(data,1)];
            down = downsample(data',ceil(freq/256)); % downsampled to 250Hz
            input = zeros(size(down));
            filtered = zeros(size(down));

            % ############## LOW PASS FILTER ################
            % [b,a] = cheby2(6,40,13/(length(down)/2));   125 is half of sampling frequency
            % fvtool(b,a); %Visualize filter
            % legend(fvt,'lowpass','designfilt')

            % ############## BAND PASS FILTER ################
            [A,B,C,D] = cheby2(10,40,[0.5 34]/(length(down)/2)); % 125 is half of sampling frequency
            sos = ss2sos(A,B,C,D);
            % fvt = fvtool(sos,d,'Fs',1500); %Visualize filter
            % legend(fvt,'cheby2','designfilt')

            for k=1:size(data,1)
               % filtered = filter(b,a,down(:,k)); %lowpass
               filtered(:,k) = sosfilt(sos,down(:,k)); %bandpass
               % %Visualizing the power spectra
               % figure;
               % [pxx,f] = periodogram(filtered(:,k),[],[],length(down)); %plot of power with filter
               % plot(f,10*log10(pxx))
               % [pxx1,f1] = periodogram(down(:,k),[],[],length(down));
               % figure;
               % plot(f1,10*log10(pxx1)); %plot of power without filter
            end

            clearvars -except filtered optFile Y folders files i optFolder cLength; %all further analysis will take place wrt filtered data
            parameters = find_params(filtered);
            
            save(optFile,'parameters','Y');
        end
    end
    channelMat = sprintf('%s/channel.mat',optFolder);
    save(channelMat,'cLength');
end