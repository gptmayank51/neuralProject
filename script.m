clear;
folders = ls('../data/');
for i=3:size(folders,1)
    s = sprintf('../data/%s', folders(i,:));
    files = ls(s);
    for j=3:size(files,1)
        t = sprintf('../data/%s/%s', folders(i,:), files(j,:));
        load(t);
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

        clearvars -except filtered; %all further analysis will take place wrt filtered data
        parameters = find_params(filtered);
    end
end