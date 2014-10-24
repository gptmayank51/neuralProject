function [params] = find_params(t,f)
    %params(i,1) -> peak frequency
    %params(i,2) -> bandwidth
    %params(i,3) -> line length
    %params(i,4) -> mean non linear energy
    %params(i,5) -> RMS amplitude
    %params(i,6) -> number of maxima and minima
    params = zeros(size(t,2),21);
    EPSILON = 0.01;
    for i=1:size(t,2) %time domain features
        for j=1:length(t)
            params(i,5) = params(i,5) + t(i,j)*t(i,j);
            if j~=length(t)-1
                params(i,3) = params(i,3) + abs(t(i,j+1)-t(i,j));
                params(i,6) = params(i,6) + (abs(t(i,j+1)-t(i,j))<EPSILON);
                if j~=1
                    params(i,4) = params(i,4) + (t(i,j)*t(i,j) - t(i,j-1)*t(i,j+1));
                end
            end
        end
        params(i,4) = params(i,4) / (length(t)-2);
        params(i,5) = sqrt(params(i,5) / length(t));
    end
    for i=1:size(f,2) % frequency domain features
        psd = periodogram(t(:,i),rectwin(length(t)),length(t),length(t));
        mini = Inf;
        maxi = -Inf;
        for j=1:length(f)
            mini = min(mini,f(j,i));
            maxi = min(maxi,f(j,i));
        end
        params(i,1) = maxi;
        params(i,2) = maxi-mini;
    end