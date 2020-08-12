
% This script runs Steve Mitchell's locator, using a given array and the
% arrival times of sounds at the phones in this array.  It displays the phones,
% plots the hyperbolas, calculates the best location, and prints and plots it.
%
% Sometimes when there aren't enough phones, locations are ambiguous (see
% Spiesberger, J.L. 2001. Hyperbolic location errors due to an insufficient
% number of receivers. J. Acoust. Soc. Am. 109:3076-3079.).  If a location
% looks wrong on the plot and you think you have a better idea, you can make
% this routine re-calculate a best-fit location near a given point.  Just 
% right-click at that point in the plot.
%
% Upon entry, you need these variables defined:
%    arr        D x n	phone positions, meters
%    delays     k x M	each row has the set of delay times of the sound
%                       between pairs of phones, sec
%    m1, m2	k x M	each row has indices specifying between which phones 
%                       the delay was measured; if there is only 1 row, then
%                       it is used for all k of the delays
%    c		scalar	speed of sound, m/s
%    limits		(optional) limits of grid for initial guess and for 
%			plotting
%		1 x 4	(for 2-D) [xmin xmax ymin ymax]
%		1 x 6	(for 3-D) [xmin xmax ymin ymax zmin zmax]
%    resolution scalar	(optional) grid size for finding best-fit loc, meters
%    tolerance  scalar	(optional) time-of-arrival error allowed, seconds (used
%			in plotting)
%
% In the above list,
%    D	is the number of dimensions (2 or 3)
%    n	is the number of phones
%    k	is the number of locations to calculate (often 1)
%    M	is the number of inter-phone delays to use for each calculation
% (You don't have to set these variables; they're just the array sizes.)
%
% If 'delays' has more than one row (k>1), several locations are calculated
% successively.  Only the last location is left on the plot; for the results of
% the other localizations, use xopt or read the command window (see 'diary').
%
% Upon finishing, these variables are set:
%    xopt       D x k	optimal X-Y position (m)
%    actual     M x k	actual arrival-time differences
%    calc       M x k	arrival-time differences for optimal position
%    err        M x k	difference between actual and calc
%    mnorm      1 x k	sum-squared time differences
%    sigma      1 x k	mean error
%
% It's a misfeature that input args (namely delay, m1, m2) have one
% location per row, while output args (all of them) have one per column.

if (~exist('limits')), limits = []; end
if (~exist('tolerance')), tolerance = []; end
if (~exist('resolution')), resolution = []; end

disp('Finding loc(s)...');

if (exist('xInit', 'var')), k0 = size(delays,1); 
else                        k0 = 1; xopt=[];actual=[];calc=[];err=[];mnorm=[];
end
for k = k0 : size(delays,1)
  mk = 1; if (size(m1,1) > 1), mk = k; end
  if (size(arr,1) == 2)
    plotPhones(arr, limits);                   % turns hold on
    %tolerance = 0; disp('locateDelays: re-fudging tolerance')
    useful = PlotHyperbolas(delays(k,:), tolerance, arr, ...
      m1(mk,:), m2(mk,:), c, limits);
  else
    useful = 1 : size(m1,2);
  end

  if (exist('xInit', 'var'))
    [xopt(:,k),actual(:,k),calc(:,k),err(:,k),mnorm(k)] = ...
	bestFit(m1(mk,useful), m2(mk,useful), delays(k,useful), arr, ...
	limits, resolution, c, xInit);
  else
    [xopt(:,k),actual(:,k),calc(:,k),err(:,k),mnorm(k)] = ...
	bestFit(m1(mk,useful), m2(mk,useful), delays(k,useful), arr, ...
	limits, resolution, c);
  end
  sigma(k) = showResults(xopt(:,k), m1(mk,useful), m2(mk,useful), ...
      actual(:,k), calc(:,k), err(:,k), mnorm(k), c);
end

set(gca, 'ButtonDownFcn', [
    'if (strcmp(get(gcf, ''SelectionType''), ''alt'')),' ...
    'q=get(gca,''CurrentPoint'');xInit=q(1,1:2).'';locateDelays;'...
    'clear xInit;end']);
