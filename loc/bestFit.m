function [xOpt,actual,calc,err,mnorm] = bestFit(m1,m2,d,arr,limits,resol,c,xInit)
%bestFit	calculate the best-fit location for the given time delays d
%
%[xopt,actual,calc,err] = bestFit(m1, m2, delays, arr, limits, resol, c, xInit)
%    Calculate the best-fit location for the given time delays.  Searching is
%    done using the Levenberg-Marquardt nonlinear least-squares optimization
%    procedure.  The initial search point is either specified explicitly as
%    xInit, or is chosen as the best-fitting point from a grid that spans the
%    space given by 'limits'.  The calculation may be done in either two or
%    three dimensions.
%
%    If the global variable UseIshmaelLocalizer is non-zero, this routine
%    uses the same algorithm that Ishmael uses for localization.  If it's zero
%    (the default), it uses a slightly more general algorithm that MATLAB says
%    is better in some cases.  Do 'doc lsqnonlin' for details; the options used
%    with UseIshmaelLocalizer are LargeScale 'off' and LevenbergMarquardt 'on'.
%
%    Inputs:
%	m1	1 x m	first element of pairs of phones
%	m2	1 x m	second element of pairs of phones
%	delays	1 x m	measured delays between those phone pairs, s
%	arr	D x n	phone positions, m
%	limits	1 x 4	(for 2-D) [xmin xmax ymin ymax]
%		1 x 6	(for 3-D) [xmin xmax ymin ymax zmin zmax]
%			limits of grid for initial guess (optional; use []
%			to not specify it; xInit is used if supplied, else 
%			this is used; if neither is supplied, limits is 
%			calculated from arr)
%	resol	scalar	# of initial points in each dimension for initial-guess
%			grid (optional; use [] to get the default, which
%			is 10, or use xInit below)
%	c	scalar	speed of sound
%	xInit	1 x n	initial position guess (optional; use either this
%			or 'limits' and 'resol', above)
%   Outputs:
%       xopt	n x 1	optimal X-Y or X-Y-Z point, m
%       actual	n x 1	actual arrival-time differences for the point xopt
%       calc	n x 1	theoretical arrival-time differences at the optimal
%			position
%       err	n x 1	difference between actual and calc
%
%   D is the number of dimensions, 2 or 3
%   n is the number of phones
%   m is the number of time delays (usually n*(n-1)/2, but can be different)

global UseIshmaelLocalizer
if (isempty(UseIshmaelLocalizer)), UseIshmaelLocalizer = 0; end     % default

m = length(m1);
D = size(arr,1);
if (isempty(limits)), limits = defaultLimits(arr); end	% default value
if (isempty(resol)),  resol = 10;                  end	% default value

if (nargin < 8 || isempty(xInit))		% was xInit supplied?
  % Calculate point of least square delay error coarsely, using grid.
  disp('')
  % First construct the grid.
  if (D == 2), [x,y] = meshgrid(linspace(limits(1),limits(2),resol), ...
	                        linspace(limits(3),limits(4),resol));
  else       [x,y,z] = meshgrid(linspace(limits(1),limits(2),resol), ...
                                linspace(limits(3),limits(4),resol), ...
                                linspace(limits(5),limits(6),resol));
  end

  % Calculate error at each gridpoint.
  e = zeros(size(x));
  for i = 1:m
    d1 = (x - arr(1,m1(i))).^2 + (y - arr(2,m1(i))).^2;
    d2 = (x - arr(1,m2(i))).^2 + (y - arr(2,m2(i))).^2;
    if (D == 3)
      d1 = d1 + (z - arr(3,m1(i))).^2;
      d2 = d2 + (z - arr(3,m2(i))).^2;
    end
    dd = (sqrt(d2) - sqrt(d1)) - d(i)*c;
    
    % Change this for minimizing Chebychev or norm other than L2
    e  = e + dd .* dd;
  end
  
  % Find the best point, xInit.
  [~,bestIx] = min(e(:));
  xInit(1,1)     = x(bestIx(1));
  xInit(2,1)     = y(bestIx(1));
  if (D == 3)
    xInit(3,1)   = z(bestIx(1));
  end
end

% Apply Levenberg-Marquardt least squares optimization.
if (exist('optimoptions', 'file'))
  
  % Workaround for MATLAB bug: There are two versions of optimoptions in the
  % default MATLAB search path, with the wrong one first.  Put the right one
  % first temporarily.
  %origPath = path;
  %path(pathDir(which('optim/optimoptions')), origPath)

  % This was set up for Optimization Toolbox v6.3 (MATLAB version 8; R2013a).
  op = optimoptions('lsqnonlin', 'Jacobian', 'on', 'TolFun', 1e-7, ...
    'Display', 'off');
  if (exist('UseIshmaelLocalizer', 'var') && UseIshmaelLocalizer > 0)
    % Force lsqnonlin to use the algorithm that Ishmael uses.
    op = optimoptions(op, 'Algorithm', 'levenberg-marquardt');
  end
  %path(origPath);			% restore original path
  
  fun = @(x)CalcDeltaTimes(x, arr, m1, m2, -d * c);
  xOpt = lsqnonlin(fun, xInit, [], [], op);
  
elseif (exist('optimset', 'file'))	% options handling changed in Matlab version 5
  % Version 5-7 MATLAB.  Not sure of optimization toolbox version
  if (~exist('lsqnonlin', 'file'))
    error('You need the optimization toolbox to use this localization method.')
  end
  
  op = optimset('lsqnonlin');
  vv = sscanf(version, '%d');
  if (vv <= 5)
    op = optimset(op, 'Jacobian', 'CalcDeltaJacobian', 'TolFun', 1e-7);
  else
    %op = optimset(op, 'Jacobian', 'on', 'JacobMult', 'CalcDeltaJacobian', ...
      %'TolFun',1e-7);    % does not work; was for some other version??
    op = optimset(op, 'Jacobian', 'on', 'TolFun', 1e-7, 'Display', 'off');
    if (exist('UseIshmaelLocalizer', 'var') && UseIshmaelLocalizer > 0)
      % Force lsqnonlin to use the algorithm that Ishmael uses.
      op = optimset(op, 'LargeScale', 'off', 'LevenbergMarquardt', 'on');
    end
  end
  xOpt = lsqnonlin('CalcDeltaTimes', xInit, [], [], op, arr, m1, m2, -d * c);
else
  % Pre-version-5 MATLAB.
  options    = foptions;
  options(1) = -1;		% no warning messages
  xOpt = lsq('CalcDeltaTimes', xInit, options, 'CalcDeltaJacobian',...
                                 arr, m1, m2, -d * c);
end

calcDeltaTimes = CalcDeltaTimes(xOpt, arr, m1, m2, -d*c);
calcTimes = d' - calcDeltaTimes / c;
mnorm = norm(calcDeltaTimes)^2;

h1     = m1';
h2     = m2';
actual = -d';
calc   = -calcTimes;
err    = calcDeltaTimes * c;

i = find(h2 < h1);
if (~isempty(i))
   temp       = h1(i);		% swap h1 and h2...
   h1(i)      = h2(i);
   h2(i)      = temp;
   actual(i)  = -actual(i);	% ...and invert delays appropriately
   calc(i)    = -calc(i);
   err(i)     = -err(i);
end
