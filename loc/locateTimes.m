
% This script runs Steve Mitchell's locator, using a given array
% and the arrival times of sounds at the phones in this array.
% Upon entry, you need these variables defined:
%
%    arr        D x n	phone positions, meters
%    arrivals   1 x n	arrival times of the sound at each phone, seconds
%    p          1 x k	(optional) which phones (from arr and arrivals) to use
%    c          scalar	speed of sound, m/s
%    limits		limits of grid for initial guess and for plotting
%		1 x 4	(for 2-D) [xmin xmax ymin ymax]
%		1 x 6	(for 3-D) [xmin xmax ymin ymax zmin zmax]
%    resolution scalar	(optional) grid size for finding best-fit loc, meters
%    tolerance  scalar	(optional) time-of-arrival error allowed, seconds (used
%			in plotting)
%
% This routine displays the phones, plots the hyperbolas, calculates the
% best location, and prints and plots it.  It also sets these variables:
%
%    xopt       optimal X-Y position (m)
%    actual     actual arrival-time differences
%    calc       arrival-time differences for optimal position
%    err        difference between actual and calc
%    m          squared error
%    sigma      mean error


if (~exist('limits',     'var')), limits     = []; end
if (~exist('tolerance',  'var')), tolerance  = []; end
if (~exist('resolution', 'var')), resolution = []; end
if (~exist('p',          'var')), p          = []; end

if (~isempty(p)), p1 = p;
else p1 = 1 : size(arr,2); 
end

nDims = size(arr,1);
nPhones = size(arr,2);

% Make array centered at the origin.
meanPos = mean(arr.').';
newArr = arr - meanPos * ones(1, nPhones);
newLims = limits - meanPos(floor(1.1 : 0.5 : nDims+1)).';

[m1,m2,d] = timesToDelays(p1, arrivals);
if (size(newArr,1) == 2)
  plotPhones(newArr(:,p1), limits);                   % turns hold on
  [useful,physLims] = PlotHyperbolas(d, tolerance, newArr, m1, m2, c, newLims);
  if (sum(useful) < nDims)
    printf
    printf('The arrival times you specified are not within the range of')
    printf('physically possible values for your phone array. Here, each value')
    printf('of ''Delays'' (which is the delay time between arrivals at one')
    printf('pair of phones) should be smaller than the corresponding value of')
    printf('''Limits'', and it isn''t:')
    printf('Delays: %s', sprintf('%10.3f  ', abs(d)));
    printf('Limits: %s', sprintf('%10.3f  ', physLims));
    error('There are not enough valid time delays.')
  end
else
  useful = 1 : length(m1);
end

disp('Finding loc...');
if (exist('xInit', 'var'))
  [xopt,actual,calc,err,m] = bestFit(m1(useful), m2(useful), ...
      d(useful), newArr, newLims, resolution, c, xInit);
else
  [xopt,actual,calc,err,m] = bestFit(m1(useful), m2(useful), ...
      d(useful), newArr, newLims, resolution, c);
end
sigma = showResults(xopt, m1(useful), m2(useful), actual, calc, err, m, c);

set(gca, 'ButtonDownFcn', [
    'if (strcmp(get(gcf, ''SelectionType''), ''alt'')),' ...
    'q=get(gca,''CurrentPoint'');xInit=q(1,1:2);locateTimes;clear xInit;'...
    'end']);
