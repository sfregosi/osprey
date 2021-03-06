function [m1,m2,d,useful] = enterTimes(arr, c, tolerance, limits)
%enterTimes	Enter a set of sound arrival times to use in localization.
%
% [m1,m2,d,useful] = enterTimes(arr, c, tolerance, limits)
%    Have the user enter from the keyboard a set of arrival times at each 
%    phone.  As each is entered, display its hyperbola.  The values can be 
%    either seconds or milliseconds; the program guesses about which it might 
%    be, and gives the user a chance to correct the guess.
%
%    Locations can be done in 2 or 3 dimensions.  Plotting is not done
%    in 3 dimensions.
%
% Required input arguments:
%    arr	2 x n	phone positions in x, y, and optionally z, meters
%    c		scalar	speed of sound, m/s (~343 in air, ~1500 in seawater)
% Optional input arguments:
%    tolerance	scalar	error in time delays, s (used only in plotting)
%    limits		axes limits of plot, meters:
%		1 x 4	for 2 dimensions, [xMin xMax yMin yMax]
%		1 x 6	for 3 dimensions, [xMin xMax yMin yMax zMin zMax]
%
% Values entered from the keyboard when this function executes:
%    - number of phones
%    - for each phone, the time that the sound signal arrived at that phone
%
% Outputs:
%    m1		1 x m	first phone number of each pair
%    m2		1 x m	second phone number of each pair
%    d		1 x m	arrival-time delay between phone 1 and phone 2, sec;
%			d > 0 if the sound reached phone 1 first, < 0 if
%			phone 2 first (this is the negative of Canary's 
%			correlation offset value)
%    useful	1 x m	whether each phone-pair value is less than the maximum
%			possible delay
%
% D is the number of dimensions (usually 2 or 3)
% n is the number of phones
% m is the number of entered time delays

global previousM1 previousM2 previousD scale scaleText

if (~exist('previousM1')), previousM1 = []; end

D = size(arr,1);
if (nargin < 3), tolerance = []; end
if (nargin < 4), limits    = []; end

checkScale('init')
if (D == 2)
  plotPhones(arr, limits);	% turns hold on
end

if (length(previousM1))
  nn = input('Number of phones? [enter NaN to re-use previous set] ');
else
  nn = input('Number of phones? ');
end

if (isnan(nn))
  % Use previous values.
  m1 = previousM1;
  m2 = previousM2;
  d  = previousD;

else
  % Enter new values.
  for i = 1 : nn
    %h(i) = input('Enter phone number: ');
    h(i) = i;
    t(i) = input(sprintf('Enter arrival time%s for phone %d: ', ...
	scaleText, h(i)));
    if (i > 1)
      checkScale(t(i) - t(i-1));
    end
  end
  disp(' ')
  
  t = t / scale;
  [m1,m2,d] = timesToDelays(h, t);

  previousM1 = m1;
  previousM2 = m2;
  previousD = d;
end
hold off

if (D == 2)
  useful = PlotHyperbolas(d, tolerance, arr, m1, m2, c, limits);
else
  useful = 1 : length(m1);		% wrong!
end
