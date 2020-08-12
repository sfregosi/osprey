function [useful,timeLims] = PlotHyperbolas(d, tolerance, arr, m1, m2, c, limits)
% useful = plotHyperbolas(d, tolerance, arr, m1, m2, c, limits)
% Plot one or more hyperbolas on the current plot.  Leaves hold on.
%
% Inputs:
%    d		time delay, seconds, between pairs of phones
%    tolerance	error in time delay; if [], a default is guessed at
%    arr	phone positions, meters (indexed by m1, m2)
%    m1		phone 1 number (indices are same as d's)
%    m2		phone 2 number (indices are same as d's)
%    c		speed of sound, m/s
%    limits	(optional) x- and y-limits of plot, [xMin xMax yMin yMax]
% Output:
%    useful	says whether each time delay is useful (is less than max delay)

global phColorNum		% next color to plot in

if (nargin < 7), limits = []; end

if (~exist('phColorNum', 'var'))
  phColorNum = [];
end
if (isempty(phColorNum))
  phColorNum = 1;
end
colors = 'brcmrgk';

if (isempty(tolerance))
  tolerance = defaultTolerance(d);
end
if (isempty(limits))
  limits = defaultLimits(arr);
end

phone1xy = arr(:,m1);
phone2xy = arr(:,m2);

clf
hold on

plot(arr(1,:), arr(2,:), '*')

timeLims = [];
for i = 1:length(d)
  maxDelay = sqrt(sum((phone1xy(:,i) - phone2xy(:,i)) .^ 2)) / c;
  timeLims(i) = maxDelay;					    %#ok<AGROW>

  % Plot two hyperbolas, one on either side, using the tolerance.
  useful(i) = (abs(d(i)) < maxDelay);                               %#ok<AGROW>
  d1 = d(i) - tolerance;
  d2 = d(i) + tolerance;
  if (abs(d1) < maxDelay)
    [~,obj] = PlotHyp(...
	phone1xy(1,i), phone1xy(2,i), phone2xy(1,i), phone2xy(2,i), d1*c/2,...
	limits(1), limits(2), limits(3), limits(4), colors(phColorNum));
    set(obj, 'UserData', [m1(i) m2(i) d1 maxDelay], ...
	'ButtonDownFcn', 'disp(get(gco, ''UserData''))');
  end
  if (tolerance > 0 && abs(d2) < maxDelay)
    [~,obj] = PlotHyp(...
	phone1xy(1,i), phone1xy(2,i), phone2xy(1,i), phone2xy(2,i), d2*c/2,...
	limits(1), limits(2), limits(3), limits(4), colors(phColorNum));
    set(obj, 'UserData', [m1(i) m2(i) d2 maxDelay], ...
	'ButtonDownFcn', 'disp(get(gco, ''UserData''))');
  end
  phColorNum = rem(phColorNum, length(colors)) + 1;
end

hold off
drawnow
