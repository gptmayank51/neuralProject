function [params] = find_params(t,f)
    %params(i,1) -> peak frequency
    %params(i,2) -> bandwidth
    params = zeros(size(t,2),21);
    for i=1:size(t,2)
        
    end
    for i=1:size(f,2)
        mini = Inf;
        maxi = -Inf;
        for j=1:length(f)
            mini = min(mini,f(j,i));
            maxi = min(maxi,f(j,i));
        end
        params(i,1) = maxi;
        params(i,2) = maxi-mini;
    end