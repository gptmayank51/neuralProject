clear;
load('Patient_8_ictal_segment_1.mat');
datat = data';
down = downsample(datat,20); % downsampled to 250Hz
input = zeros(size(down));
filtered = zeros(size(down));

% ############## LOW PASS FILTER ################
% [b,a] = cheby2(6,40,13/125);   125 is half of sampling frequency
% fvtool(b,a); %Visualize filter
% legend(fvt,'lowpass','designfilt')

% ############## BAND PASS FILTER ################
[A,B,C,D] = cheby2(10,40,[0.5 13]/125); % 125 is half of sampling frequency
sos = ss2sos(A,B,C,D);
% fvt = fvtool(sos,d,'Fs',1500); %Visualize filter
% legend(fvt,'cheby2','designfilt')

for i=1:size(datat,2)
   % filtered = filter(b,a,down(:,i)); %lowpass
   filtered(:,i) = sosfilt(sos,down(:,i)); %bandpass
   % %Visualizing the power spectra
   % figure;
   % [pxx,f] = periodogram(filtered(:,i),[],[],250); %plot of power with filter
   % plot(f,10*log10(pxx))
   % [pxx1,f1] = periodogram(down(:,i),[],[],250);
   % figure;
   % plot(f1,10*log10(pxx1)); %plot of power without filter
end

clearvars -except down filtered; %all further analysis will take place wrt filtered or downsampled data (freq and time domain respectively)
parameters = find_param(down, filtered);