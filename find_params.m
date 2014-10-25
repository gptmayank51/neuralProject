function [params] = find_params(t,f)
    %params(i,1) -> peak frequency
    %params(i,2) -> bandwidth
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
    der = zeros(length(t)-1, size(t,2));
    dbder = zeros(length(t)-2, size(t,2));
    EPSILON = 0.01; %for maxima minima |f'(x)| < EPSILON instead of = 0
    for i=1:size(t,2) %time domain features
        for j=1:length(t)
            params(i,11) = params(i,11) + t(j,i)*t(j,i);
            if j~=(length(t))
                der(j,i) = t(j+1,i)-t(j,i);
                params(i,9) = params(i,9) + abs(der(j,i));
                params(i,12) = params(i,12) + (abs(der(j,i))<EPSILON);
                params(i,13) = params(i,13) + (t(j+1)*t(j) < 0);
                if j~=1
                    params(i,10) = params(i,10) + (t(j,i)*t(j,i) - t(j-1,i)*t(j+1,i));
                    dbder(j-1,i) = der(j,i)-der(j-1,i);
                end
            end
        end
        params(i,10) = params(i,10) / (length(t)-2);
        params(i,11) = sqrt(params(i,11) / length(t));
        params(i,14) = var(t(:,i));
        params(i,15) = std(der(:,i))/std(t(:,i));
        params(i,16) = (std(dbder(:,i))/std(der(:,i)))/(std(der(:,i))/std(t(:,i)));
        m = ar(t(1:length(t)/2,i),7);
        [~, params(i,17)] = compare(t(length(t)/2+1:end,i),m);
    end
    for i=1:size(f,2) % frequency domain features
        psd = periodogram(t(:,i),rectwin(length(t)),length(f),length(t));
        maxi = -Inf;
        for j=1:length(f)
            maxi = max(maxi,f(j,i));
        end
        params(i,1) = maxi;
    end
    for i=1:size(t,2) % entropy domain features
        xdft = fft(t(:,i));
        xdft = xdft(1:length(t(:,i))/2+1);
        psdx = (1/(length(f(:,i))*length(t(:,i)))) * abs(xdft).^2;
        psdx(2:end-1) = 2*psdx(2:end-1);
        pfx = psdx/sum(psdx);
        Nf = numel(unique(psdx));
        params(i,18) = (-1/log(Nf))*sum(pfx.*log(pfx));
        [~, phx, ~] = kde(t(:,i));
        params(i,19) = -sum(phx.*log(phx));
        params(i,20) = ApEn(20, 0.2*std(t(:,i)), t(:,i));
    end