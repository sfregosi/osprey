function jac = CalcDeltaJacobian(x,array,h1,h2,measuredDelay)
%CalcDeltaJacobian	compute gradient of the time delay difference function
%
%jac = CalcDeltaJacobian(x,array,h1,h2,measuredDelay)
%   Computes the gradient of the time delay difference function 
%   (see CalcDeltaTimes.m).
%
%   Inputs:
%	x		D x 1	location to compute Jacobian for
%	array		D x n	positions of phones
%	h1		1 x m	first phone indices
%	h2		1 x m	second phone indices
%	measuredDelay	1 x m	measured time delays between first and
%				second phones (only the length of this
%				vector is used)
%   Output:
%	jac		D x m	time delay differences function Jacobian,
%				transposed
%
%   D is the number of dimensions, usually 2 or 3
%   n is the number of phones
%   m is the number of time delays (usually n*(n-1)/2, but can be different)

D = size(x,1);
m = length(measuredDelay);

xbig = x * ones(1, m);
d1 = xbig - array(:,h1);
d2 = xbig - array(:,h2);

jac = d1 ./ (ones(D,1) * sqrt(sum(d1.*d1))) ...
    - d2 ./ (ones(D,1) * sqrt(sum(d2.*d2)));
