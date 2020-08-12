function delta = CalcCorrErrors(x,array,h1,h2,normxc,sRate,c)
%CalcCorrErrors		compute correlation errors between phone pairs
%
% delta = CalcCorrErrors(x,array,h1,h2,normxc)
%    Compute theoretical time delays from given coordinates, assuming the
%    given phone locations, and subtract these from the given measured time
%    delays, producing a vector of time delay errors.
%
%    If you use zeros(1,m) for measuredDelay, you will get the theoretical
%    time delays.
%
%    Inputs:
%	x		D x 1	location to compute correlation errors, m
%	array		D x n	positions of phones, m
%	h1		1 x m	first phone indices (values are in 1..n)
%	h2		1 x m	second phone indices (values are in 1..n)
%	normxc		{1 x m}	normalized trimmed correlation functions between
%				first and second phones of each pair; only the
%				physically possible ones; they are of varying
%				lengths	because the phones are different 
%				distances apart
%	sRate		scalar	sample rate, Hz
%	c		scalar	speed of sound, m/s
%    Outputs:
%	delta		m x 1	correlation errors for each pair
%       jac		D x m	Jacobian of time delay differences function
%
%    D is the number of dimensions, usually 2 or 3
%    n is the number of phones
%    m is the number of time delays (usually n*(n-1)/2, but can be different)

% Left over from elsewhere: a additional return arg, no longer used
% [delta,jac] = CalcCorrErrors( ... )
%    A second output argument is the Jacobian of time delay difference 
%    function at the point x.

nTest = 0;
delta = zeros(length(h1), 1);
for i = 1 : length(h1);
  p1 = h1(i);
  p2 = h2(i);
  dDist = norm(x - array(:,p1)) - norm(x - array(:,p2));% >0: closer to phone 1
  dSam = dDist / c * sRate;
  mid = (length(normxc{i}) + 1) / 2;
  if (abs(dSam) >= mid)
    continue
  end
  xcval = normxc{i}(mid + dSam);
  delta(i) = (1 - xcval)^2;
  nTest = nTest + 1;
end
if (nTest > 0)
  delta = sqrt(err) / nTest;
else
  delta = inf;
end


% xbig = x * ones(1, length(measuredDelay));
% delta = (  sqrt(sum((xbig - array(:,h1)) .^ 2)) ...
%          - sqrt(sum((xbig - array(:,h2)) .^ 2)) ...
%          - measuredDelay).';
