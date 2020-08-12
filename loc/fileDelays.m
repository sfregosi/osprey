
% This script loads data from files, if the files haven't been read yet.
% If the files have been read, it does not re-read them, since load('ASCII')
% is so slow.  On input, these variables must be set:
%
%    arrfile	file name of array phone positions; positions should be 
%               in columns of x and y for 2-dimensional locations, and 
%		x, y, and z for 3-dimensional locations
%    arrcols	which columns of arrfile to use (normally just [1 2] for
%               2-dimensional locations, or [1 2 3] for 3-dimensional ones)
%    delayfile	file name of file with time delays between pairs of phones,
%               with columns of
%                     phoneNumber1  phoneNumber2  delayBetween1and2
%               The delay should be measured in seconds; see enterDelays
%               for the sign convention.  There can be more than three columns,
%               in which case each column (from #3 on) will trigger calculation
%               of one location.
%
% After execution, these are set:
%
%    arr	the phone positions, as a D x n array
%    delays	time delays between phones, as a 1 x m vector; see
%		enterDelays.m for the sign convention
%    m1, m2     m x 1 vectors, with one entry for each time delay, telling
%               which two phones the delays are measured between;
%               m1 is for phone1 and m2 for phone2
%
% D is the number of dimensions, usually 2 or 3
% n is the number of phones
% m is the number of time delays (usually n*(n-1)/2, but can be different)
%
% This does not call locateDelays; do that separately.  To run locateDelays, 
% you'll also need to specify the speed of sound c.


if (~exist('prevarrfile')),  prevarrfile  = ''; end
if (~exist('prevdelayfile')), prevdelayfile = ''; end
if (~exist('arrcols')), arrcols = [1 2]; end


disp(sprintf('Time delays are from %s.', delayfile));
delays = load(delayfile, 'ASCII');
m1 = delays(:,1).';
m2 = delays(:,2).';
delays = delays(:,3:end).';

disp(sprintf('Array positions are from %s.', arrfile));
arr = load(arrfile, 'ASCII');
arr = arr(:, arrcols).';			% pick off desired columns
if (size(arr,1) < 2), arr(2,1) = 0; end	% change 1-dim array to 2-dim
