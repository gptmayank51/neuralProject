clear;
folders = dir('../dataVal/');
if (isequal(exist('../dataValOutput','dir'),7))
        rmdir('../dataValOutput','s');
end
mkdir('../dataValOutput');
for i=3:size(folders,1)
    s = sprintf('../dataVal/%s', folders(i).name);
    files = dir(s);
    cLength = [];
    optFolder = sprintf('../dataValOutput/%sOutput', folders(i).name);
    if (isequal(exist(optFolder,'dir'),7))
        rmdir(optFolder,'s');
    end
    mkdir(optFolder);
    for j=3:size(files,1)
        t = sprintf('../dataVal/%s/%s', folders(i).name, files(j).name);
        optFile = sprintf('%s/%s.mat',optFolder,files(j).name);
        temp = textscan(files(j).name,'%s','delimiter','_');
        if (strcmp(temp{1}{3},'ictal') || strcmp(temp{1}{3},'interictal'))
            name = sprintf('Folder %s, file %s',folders(i).name,files(j).name);
            disp(name);
            if strcmp(temp{1}{3},'ictal')
                Y = 1;
            else
                Y = -1;
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
               % [pxx,f] = periodogram(filtered(:,k),[],[],length(down)); % plot of power with filter
               % plot(f,10*log10(pxx))
               % [pxx1,f1] = periodogram(down(:,k),[],[],length(down));
               % figure;
               % plot(f1,10*log10(pxx1)); %plot of power without filter
            end

            clearvars -except filtered optFile Y folders files i optFolder cLength; % all further analysis will take place wrt filtered data
            parameters = find_params(filtered);
            features = mean(parameters,1); % For now taking only data of first channel for classification
            % For general case do this - 
            % X = (parameters(:))';
            save(optFile,'features','Y');
        end
    end
    channelMat = sprintf('%s/channel.mat',optFolder);
    save(channelMat,'cLength');
end