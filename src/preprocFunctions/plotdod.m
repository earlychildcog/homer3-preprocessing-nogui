function f = plotdod(dod, index)
% plot dod object
chanN = size(dod.dataTimeSeries,2);
if nargin == 1 || isempty(index)
    index = 1:chanN/2;
end

nIndex = length(index);
    
f = figure;
ax = axes;
hold on
plot(dod.time, dod.dataTimeSeries(:,index));
legend(string(index));

ax.ColorOrder = cool(nIndex);

hold off
end

