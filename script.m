load('Patient_8_ictal_segment_1.mat');
datat = data';
down = downsample(datat,20); % downsampled to 250Hz
input = down(:,1) %applying band pass filter on electrode 1 values
% ############## LOW PASS FILTER ################
% [b,a] = cheby2(6,40,13/125);   125 is half of sampling frequency
% fvtool(b,a); Visualize filter
% dataOut = filter(b,a,input);
% figure;
% [pxx,f] = periodogram(dataOut,[],[],250); %plot of pwoer without filter
% plot(f,10*log10(pxx))
% [pxx1,f1] = periodogram(input,[],[],250);
% figure;
% plot(f1,10*log10(pxx1)); %plot of pwoer without filter


% ############## BAND PASS FILTER ################
[A,B,C,D] = cheby2(10,40,[0.5 13]/125); % 125 is half of sampling frequency
sos = ss2sos(A,B,C,D);
% % Visualize filter
% fvt = fvtool(sos,d,'Fs',1500);
% legend(fvt,'cheby2','designfilt')

banddata = sosfilt(sos,input);
figure;
[pxx,f] = periodogram(banddata,[],[],250); %plot of pwoer without filter
plot(f,10*log10(pxx))
[pxx1,f1] = periodogram(input,[],[],250);
figure;
plot(f1,10*log10(pxx1)); %plot of pwoer without filter

