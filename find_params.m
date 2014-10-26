function [params] = find_params(t,f)
    %params(i,1) -> peak frequency
    %params(i,4) -> peak power
    %params(i,2) -> bandwidth
    %params(i,3) -> line length
    %params(i,5) -> Total Power
    params = zeros(size(t,2),21);
    for i=1:size(t,2) %time domain features
        for j=1:length(t)-1
            params(i,3) = params(i,3) + abs(t(j+1)-t(j));
        end
    end
    for i=1:size(f,2) % frequency domain features
        %hold on;
        pxx = periodogram(t(:,i),[],512); %512 point fft LINK - http://www.mathworks.in/help/signal/ref/periodogram.html#btt5utg
        % pxx is  periodogram power spectral density (PSD) estimate
        %plot(10*log10(psd));
        [maxVal, index] = max(pxx);
        temp = abs(pxx - (maxVal/2));
        [Val,Ind]= sort(temp);
        params(i,1) = index;
        params(i,4) = maxVal;
        params(i,2) = abs(Ind(1) - Ind(2));
        % Spectral Edge Frequency - For range 2-20Hz.
        pband = bandpower(pxx,F,[2 20],'psd');  %LINK  - http://www.mathworks.in/help/signal/ref/bandpower.html#btrddkn-4
        params(i,5) = pband;
        
%         mini = Inf;
%         maxi = -Inf;
%         for j=1:length(f)
%             mini = min(mini,f(j,i));
%             maxi = min(maxi,f(j,i));
%         end
        %params(i,1) = maxi;
        %params(i,2) = maxi-mini;
    end
    