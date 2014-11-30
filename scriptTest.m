clear;
folders = dir('../dataTest/');
if (isequal(exist('../dataTestOutput','dir'),7))
        rmdir('../dataTestOutput','s');
end
% Create directory for outputfiles
mkdir('../dataTestOutput');
for i=3:size(folders,1)
    % Iterate over all the patient folders
    s = sprintf('../dataTest/%s', folders(i).name);
    files = dir(s);
    % channel vector - vector containing info about no of channels in each clip
    cLength = [];
    % create individual folder for outputs of each patient
    optFolder = sprintf('../dataTestOutput/%sOutput', folders(i).name);
    if (isequal(exist(optFolder,'dir'),7))
        rmdir(optFolder,'s');
    end
    mkdir(optFolder);
    for j=3:size(files,1)
        t = sprintf('../dataTest/%s/%s', folders(i).name, files(j).name);
        % optfile is the output file for a particular patient's particular clip
        optFile = sprintf('%s/%s.mat',optFolder,files(j).name);
        temp = textscan(files(j).name,'%s','delimiter','_');
        % Read the clip file and store its class based on its file name as ictal or interictal
        if (strcmp(temp{1}{3},'ictal') || strcmp(temp{1}{3},'interictal'))
            name = sprintf('Folder %s, file %s',folders(i).name,files(j).name);
            disp(name);
            if strcmp(temp{1}{3},'ictal')
                Y = 1;
            else
                Y = -1;
            end
            load(t);
            % store its channel length in the channel array
            cLength= [cLength ; size(data,1)];
            down = downsample(data',ceil(freq/256)); % downsampled to 250Hz
            input = zeros(size(down));
            filtered = zeros(size(down));

            % ############## LOW PASS FILTER ################
            % [b,a] = cheby2(6,40,13/(length(down)/2));   125 is half of sampling frequency
            % fvtool(b,a); %Visualize filter
            % legend(fvt,'lowpass','designfilt')

            % ############## CHEBY2 BAND PASS FILTER ################
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
            % Generate feature vectors. find_params returns 21*channels matrix containing 21 feature for each channel
            parameters = find_params(filtered);
            % Use the mean of the features across all the channels
            features = mean(parameters,1); 
            % For general case do this - 
            % X = (parameters(:))';
            % save the feature vector and class vetor in a mat file
            save(optFile,'features','Y');
        end
    end
    % save all the channel info in a mat file
    channelMat = sprintf('%s/channel.mat',optFolder);
    save(channelMat,'cLength');
end