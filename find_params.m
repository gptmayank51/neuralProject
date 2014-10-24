function [params] = find_params(t,f)
    %params(i,1) -> peak frequency
    %params(i,2) -> bandwidth
    %params(i,3) -> line length
    params = zeros(size(t,2),21);
    for i=1:size(t,2) %time domain features
        for j=1:length(t)-1
            params(i,3) = params(i,3) + abs(t(j+1)-t(j));
        end
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