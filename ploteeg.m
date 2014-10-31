function [] = ploteeg(file)
    load(file);
    figure;
    hold on;
    for i=1:size(data,1) %#ok<NODEF>
        plot(1:1:size(data,2),data(i,:)+200*i);
    end
    hold off;