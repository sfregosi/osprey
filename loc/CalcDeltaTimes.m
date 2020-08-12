function [delta,jac] = CalcDeltaTimes(x,array,h1,h2,measuredDelay)
%CalcDeltaTimes		compute theoretical minus actual time delays
%
% delta = CalcDeltaTimes(x,array,h1,h2,measuredDelay)
%    Compute theoretical time delays from given coordinates, assuming the
%    given phone locations, and subtract these from the given measured time
%    delays, producing a vector of time delay errors.
%
%    If you use zeros(1,m) for measuredDelay, you will get the theoretical
%    time delays.
%
%    Inputs:
%	x		D x 1	location to compute time delays for
%	array		D x n	positions of phones
%	h1		1 x m	first phone indices
%	h2		1 x m	second phone indices
%	measuredDelay	1 x m	measured time delays between first and
%				second phones (expressed in meters)
%    Outputs:
%	delta		m x 1	time delay differences (expressed in meters)
%       jac		D x m	Jacobian of time delay differences function
%
%    D is the number of dimensions, usually 2 or 3
%    n is the number of phones
%    m is the number of time delays (usually n*(n-1)/2, but can be different)
%
% [delta,jac] = CalcDeltaTimes( ... )
%    A second output argument is the Jacobian of time delay difference 
%    function at the point x.

xbig = x * ones(1, length(measuredDelay));
delta = (  sqrt(sum((xbig - array(:,h1)) .^ 2)) ...
         - sqrt(sum((xbig - array(:,h2)) .^ 2)) ...
         - measuredDelay).';

if (nargout >= 2)
  % This is how it works in Matlab version 6: two output args passed back to
  % lsqnonlin instead of a separate call from lsqnonlin to CalcDeltaJacobian.
  jac = CalcDeltaJacobian(x,array,h1,h2,measuredDelay).';
end
