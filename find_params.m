function [params] = find_params(t)
    %params(i,1) -> peak frequency
    %params(i,2) -> bandwidth
    %params(i,3) -> peak power
    %params(i,4) -> spectral edge frequency
    %params(i,5) -> total spectral power
    %params(i,6) -> intensity weighted mean frequency
    %params(i,7) -> intensity weighted bandwidth
    %params(i,8) -> wavelet energy
    %params(i,9) -> line length
    %params(i,10) -> mean non linear energy
    %params(i,11) -> RMS amplitude
    %params(i,12) -> number of maxima and minima
    %params(i,13) -> number of zero crossings
    %params(i,14) -> activity
    %params(i,15) -> mobility
    %params(i,16) -> complexity
    %params(i,17) -> AR model fit
    %params(i,18) -> spectral entropy
    %params(i,19) -> Shannon entropy
    %params(i,20) -> approximate entropy
    %params(i,21) -> SVD entropy

    params = zeros(size(t,2),21);
    sfrequency = length(t);
    der = zeros(length(t)-1, size(t,2));
    dbder = zeros(length(t)-2, size(t,2));
    EPSILON = 1; %for maxima minima |f'(x)| < EPSILON instead of = 0
    DE = 20; %embedded Dimension
    for i=1:size(t,2)
        %time domain features
        for j=1:length(t)
            params(i,11) = params(i,11) + t(j,i)*t(j,i);
            if j~=(length(t))
                der(j,i) = t(j+1,i)-t(j,i); %first derivative of the time domain signal
                params(i,9) = params(i,9) + abs(der(j,i));
                params(i,12) = params(i,12) + (abs(der(j,i))<EPSILON);
                params(i,13) = params(i,13) + (t(j+1,i)*t(j,i) < 0);
                if j~=1
                    params(i,10) = params(i,10) + (t(j,i)*t(j,i) - t(j-1,i)*t(j+1,i));
                    dbder(j-1,i) = der(j,i)-der(j-1,i); %second derivative of the time domain signal
                end
            end
        end
        params(i,10) = params(i,10) / (length(t)-2);
        params(i,11) = sqrt(params(i,11) / length(t));
        params(i,14) = var(t(:,i));
        params(i,15) = std(der(:,i))/std(t(:,i));
        params(i,16) = (std(dbder(:,i))/std(der(:,i)))/(std(der(:,i))/std(t(:,i)));
        m = ar(t(1:length(t)/2,i),7); %Auto regressive model fit of the EEG signal
        [~, params(i,17)] = compare(t(length(t)/2+1:end,i),m);
        
        %frequency domain features
        %hold on;
        [pxx,~] = periodogram(t(:,i),[],length(t(:,i)),sfrequency); %512 point fft LINK - http://www.mathworks.in/help/signal/ref/periodogram.html#btt5utg
        % pxx is  periodogram power spectral density (PSD) estimate
        %plot(10*log10(pxx));
        [maxVal, index] = max(pxx);
        temp = abs(pxx - (maxVal/2));
        [~,Ind]= sort(temp);
        params(i,1) = index;
        params(i,3) = maxVal;
        params(i,2) = abs(Ind(1) - Ind(2));
        % Spectral Edge Frequency - For range 2-20Hz.
        tp = sum(pxx(3:20));
        params(i,5) = tp;
        idx = 19;
        while (sum(pxx(3:idx)) > 0.9*tp)
            idx = idx-1;
        end
        params(i,4) = idx;
        % pband = bandpower(pxx,F,[2 20],'psd');  %LINK  - http://www.mathworks.in/help/signal/ref/bandpower.html#btrddkn-4
        % params(i,5) = pband;
        no_of_bins = length(pxx);
        df = sfrequency/no_of_bins;
        ivector = ones(no_of_bins/2-1,1);
        for j=1:length(ivector)
            ivector(j) = j*ivector(j);
        end
        psubi = pxx(1:no_of_bins/2-1);
        iwmf = sum(psubi.*ivector*df)/sum(psubi);
        params(i,6) = iwmf;
        iwbw = sqrt(sum(psubi.*((iwmf - ivector*df)'*(iwmf - ivector*df)))/sum(psubi));
        params(i,7) = iwbw;
        [C,L] = wavedec(t(:,i), 8, 'db4');
        [params(i,8), ~] = wenergy(C, L);
        
        %entropy domain features
        pfx = pxx(1:30)/sum(pxx(1:30)); %probability density function calculation
        params(i,18) = (-1/log(30))*sum(pfx.*log(pfx)); 
        [~, phx, ~] = kde(t(:,i)); %histogram estimate of probability density function
        reqd = find(phx>0);
        params(i,19) = -sum(phx(reqd).*log(phx(reqd)));
        params(i,20) = ApEn(DE, 0.2*std(t(:,i)), t(:,i));
        X = zeros(ceil(length(t)/DE),DE); %embedded matrix evaluation
        for j=1:length(X)
            for k=1:DE
                X(j,k) = t(j+k,i);
            end
        end
        Si = svd(X);
        Sjbar = Si/sum(Si);
        params(i,21) = sum(Sjbar.*log(Sjbar));
    end