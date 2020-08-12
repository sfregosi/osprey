function [m1,m2] = allPairs(n)
%allPairs	all possible pairs of indices
%
% m = allPairs(n)
%   Return all possible pairs of indices from 1 .. n.  There are N = n*(n-1)/2 
%   pairs, and the return value m is an Nx2 array.  The first index of pair N
%   is m(N,1), and the second index is m(N,2).
%
%   For instance, for n=3, the pairs are (1,2), (1,3), and (2,3), so
%	m = [1 2
%	     1 3
%	     2 3]
%
% [m1,m2] = allPairs(n)
%   If there are two output arguments, the pairs are returned as two separate
%   column vectors, one for each column of m.
%
% Dave Mellinger

m1 = zeros(n * (n-1) / 2, 1);
m2 = zeros(n * (n-1) / 2, 1);

ix = 1;
for i = 1 : n-1
  for j = i+1 : n
    m1(ix) = i;
    m2(ix) = j;
    ix = ix + 1;
  end
end

if (nargout < 2)
  m1 = [m1 m2];
end
