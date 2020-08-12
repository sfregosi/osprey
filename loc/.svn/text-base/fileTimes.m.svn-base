
% This script loads data from files, if the files haven't been read yet.
% On input, these variables must be set:
%
%    arrfile	file name of array phone positions; positions should be 
%               in columns of x and y for 2-dimensional locations, and 
%		x, y, and z for 3-dimensional locations
%    arrcols	which columns of arrfile to use (normally just [1 2] for
%               2-dimensional locations, or [1 2 3] for 3-dimensional ones)
%    timefile	arrival times at each phone (s)
%    p		phones to use
%
% After execution, these are set:
%
%    arr	the phone positions, as a D x n array
%    arrivals	times of arrival, as an n x 1 vector
%
% D is the number of dimensions, usually 2 or 3
% n is the number of phones


if (~exist('prevarrfile')),  prevarrfile  = ''; end
if (~exist('prevtimefile')), prevtimefile = ''; end

disp(sprintf('Arrival times are from %s.', timefile));
if (~strcmp(timefile, prevtimefile))
  disp('Loading...');
  arrivals = load(timefile, 'ASCII');
  prevtimefile = timefile;
end

disp(sprintf('Array positions are from %s.', arrfile));
if (~strcmp(arrfile, prevarrfile))
  disp('Loading...');
  arr = load(arrfile, 'ASCII');
  ARR = arr(:, arrcols).';			% pick off desired columns
  if (size(arr,1) < 2), arr(2,1) = 0; end	% change 1-dim array to 2-dim
  prevarrfile  = arrfile;
end

if (~strcmp(p, 1:length(arr)))		% not strings, but strcmp still works
  disp(sprintf('Using phones [%d%s] from this array.', ...
      p(1), sprintf(' %d',p(2:length(p)))));
end
