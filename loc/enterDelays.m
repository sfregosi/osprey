function [m1,m2,d,useful] = enterDelays(arr, c, tolerance, limits)
%enterDelays	Enter a set of inter-phone delays for use in localization.
%
% [m1,m2,d,useful] = enterDelays(arr, c, tolerance, limits)
%    Have the user enter a set of inter-phone delays from the keyboard.  As 
%    each is entered, display its hyperbola.  The values can be either seconds 
%    or milliseconds; the program guesses about which it might be, and gives 
%    the user a chance to correct the guess.
%
%    Locations can be done in 2 or 3 dimensions.  Plotting is not done
%    in 3 dimensions.
%
% Required input arguments:
%    arr	D x n	phone positions in x, y, and optionally z, in meters
%    c		scalar	speed of sound, m/s (~343 in air, ~1500 in seawater)
% Optional input arguments:
%    tolerance	scalar	error in time delays, s
%    limits		axes limits of plot, meters:
%		1 x 4	for 2 dimensions, [xMin xMax yMin yMax]
%		1 x 6	for 3 dimensions, [xMin xMax yMin yMax zMin zMax]
%
% Values entered from the keyboard when this function executes:
%    - number of inter-phone delays
%    - for each inter-phone delay: which two phones are involved in the pair, 
%	and the delay value
%
% Outputs:
%    m1		1 x M	first phone number of each pair
%    m2		1 x M	second phone number of each pair
%    d		1 x M	arrival-time delay between phone 1 and phone 2, sec;
%			d(i) > 0 if the sound reached phone m1(i) first, 
%			< 0 if phone m2(i) first (this is the negative of 
%			Canary's correlation offset value)
%    useful	1 x M	whether each phone pair value is less than max 
%			possible delay
%
% D is the number of dimensions (usually 2 or 3)
% n is the number of phones
% m is the number of entered time delays

global previousM1 previousM2 previousD scale scaleText

D = size(arr,1);
if (nargin < 3), tolerance = []; end
if (nargin < 4), limits    = []; end

checkScale('init')
if (D == 2)
  plotPhones(arr, limits);	% turns hold on
end

if (~exist('previousM1')), previousM1 = []; end
if (isempty(previousM1))
  n = input('Number of inter-phone delays? ');
else
  n = input('Number of inter-phone delays? [enter NaN to use previous set] ');
end
if (isnan(n))
  % Use previous values.
  m1 = previousM1;
  m2 = previousM2;
  d  = previousD;

else
  % Get new values from user.
  d    = zeros(1,n);
  m1   = zeros(1,n);
  m2   = zeros(1,n);
  maxD = zeros(1,n);
  
  for i = 1:n
    m1(i) = input('Between phone # ');
    m2(i) = input('    and phone # ');
    maxDelay = norm(arr(:,m1(i)) - arr(:,m2(i))) / c;

    d(i) = -input(sprintf('    max delay is %g, actual delay%s is? ', ...
	maxDelay * scale, scaleText));
    checkScale(d(i));

    if (~isempty(tolerance)), t = tolerance; 
    else t = defaultTolerance(d);
    end
    if (D == 2)
      PlotHyperbolas(d(i) / scale, t, arr, m1(i), m2(i), c, limits);
    end
  end
  
  d = d / scale;
  previousM1 = m1;
  previousM2 = m2;
  previousD = d;
end  

hold off
clf

if (D == 2)
  useful = PlotHyperbolas(d, tolerance, arr, m1, m2, c, limits);
else
  useful = 1 : length(m1);		% wrong!
end
