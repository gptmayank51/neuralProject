function [params] = find_params(t,f)
    %params(i,1) -> peak frequency
    %params(i,2) -> bandwidth
    %params(i,9) -> line length
    %params(i,10) -> mean non linear energy
    %params(i,11) -> RMS amplitude
    %params(i,12) -> number of maxima and minima
    params = zeros(size(t,2),21);
    EPSILON = 0.01;
    for i=1:size(t,2) %time domain features
        for j=1:length(t)
            params(i,11) = params(i,11) + t(i,j)*t(i,j);
            if j~=length(t)-1
                params(i,9) = params(i,9) + abs(t(i,j+1)-t(i,j));
                params(i,12) = params(i,12) + (abs(t(i,j+1)-t(i,j))<EPSILON);
                if j~=1
                    params(i,10) = params(i,10) + (t(i,j)*t(i,j) - t(i,j-1)*t(i,j+1));
                end
            end
        end
        params(i,10) = params(i,10) / (length(t)-2);
        params(i,11) = sqrt(params(i,11) / length(t));
    end
    for i=1:size(f,2) % frequency domain features
        psd = periodogram(t(:,i),rectwin(length(t)),length(t),length(t));
        maxi = -Inf;
        for j=1:length(f)
            maxi = min(maxi,f(j,i));
        end
        params(i,1) = maxi;
    end