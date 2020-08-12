function spect = opCache(ch, x1, x2, fftSize, y1, y2)
% spect = opCache(ch, x1, x2, fftSize, y1, y2)
%   Return spect frames from x1 to x2 inclusive for the channel(s)
%   specified by ch.  Calculate which ones need computing and which to
%   retrieve from the cache.  y1 and y2 specify the range of frequency
%   bin numbers to return.
%
% opCache('clear')
%   Clear the cache.
%
% opCache('clear', [], [], fftSize)
%   Clear the cache and initialize it for the given fftSize.  Cache data
%   height is fftSize/2.

global opNChans

% Here is the cache:
persistent c		% the cache; see struct below
persistent timestamp

if (isempty(timestamp)), timestamp = 0; end

maxCache   = 5000000; 	% max number of cells in cache, roughly; 40 MB/chan
%maxCache  = 1000000;	% max number of cells in cache, roughly; 8 MB/chan
maxBlock  = round(maxCache/5);		% maximum cache block size

if (ischar(ch))
  switch(ch)
    case 'clear'
      % Create new cache, with one element of struct array c for each channel.
      if (nargin >= 4 && fftSize > 1)
	n = round(maxCache / fftSize * 2 / opNChans);  % initial # spect frames
      else
	n = 0;
        fftSize = 0;
      end
      c = struct(...
	  'index',	-1 * ones(1,n), ...
	  'data',	zeros(fftSize/2, n), ...
	  'timestamp',  -1 * ones(1,n), ...
	  'dummy',	cell(1, opNChans));   % needed to make c the right size
      return
    otherwise
      error('Bad string argument passed to opCache: %s', ch);
  end	% switch
end

if (length(c) < 1 || nRows(c(1).data) ~= fftSize/2)
  opCache('clear', [], [], fftSize);
end

for j = 1 : length(ch)
  ch1 = ch(j);
  % Figure out which frames need computing and make space for them.  This also
  % re-stamps existing, now-reused frames with the current timestamp.
  [fr0,fr1,c(ch1)] = whichNeed(c(ch1), x1, x2, timestamp);
  if (~isempty(fr0))
    [slotnums,c(ch1)] = findRoom(c(ch1), sum(fr1 - fr0 + 1), timestamp);
  end
  
  % Split up large blocks, so we don't make any huge spectrograms.
  [fr0,fr1] = splitSegs(fr0, fr1, floor(maxBlock/fftSize*2));% split 'em up
  
  % Get new spect blocks, add to cache.
  j = 1;
  for i = 1:length(fr0)
    ss = slotnums(j : j + fr1(i) - fr0(i));
    c(ch1).data(:,ss)    = opComputeSpect(ch1, fr0(i), fr1(i));
    c(ch1).index(ss)     = fr0(i) : fr1(i);
    c(ch1).timestamp(ss) = timestamp;
    j = j + length(ss);
  end
end

% finish up
timestamp = timestamp + 1;
spect = makeSpect(c,ch,x1,x2,y1,y2);	% final result


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fr0,fr1,cItem] = whichNeed(cItem, x1, x2, tNow)
% Given a start frame x1 and end frame x2, figure out which frames
% aren't in the cache, returning two vectors of start- and end-frames
% that need computing.  Also, time-stamp the frames that ARE in the
% cache as being used at time tNow.

ix = cItem.index;

% Get slot numbers that refer to frames that are in the cache.
present = find(ix >= x1 & ix <= x2);

% Set time stamp.
cItem.timestamp(present) = tNow;

% Make a vector of frame numbers that are missing from the cache.
x = 1 : x2-x1+1;				% in ascending order
x(ix(present) - x1 + 1) = [];

% Collapse consecutive runs into [start,end] pairs.
[fr0,fr1] = consec(x);
fr0 = fr0 + x1 - 1;
fr1 = fr1 + x1 - 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [slotnums,cItem] = findRoom(cItem, n, tNow)
% Make room for n new frames, by creating new ones if necessary and
% flushing existing slots.  Return list of n slot numbers to supplant.
%
% tNow should be non-negative.

x = sum(cItem.timestamp < tNow);

if (x < n)
  % Create new frames in data array and new scalars in index and timestamp.
  cItem.data  (:, end+1 : end+n-x) = 0;
  cItem.index    (end+1 : end+n-x) = -1;
  cItem.timestamp(end+1 : end+n-x) = -1;
end

[~,i] = sort(cItem.timestamp);	% sort: re-use the least-recently-used slots
slotnums = sort(i(1:n));	% use the oldest n of them


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fr0,fr1] = splitSegs(g0, g1, maxsize)
% Split any interval [fr0(i),fr1(i)] longer that maxsize up into pieces
% of length at most maxsize.  fr0 and fr1 should be the same length.

fr0 = [];  fr1 = [];
for i = 1:length(g0)
  fr0 = [fr0, g0(i)           : maxsize : g1(i)];
  fr1 = [fr1, g0(i)+maxsize-1 : maxsize : g1(i)];
  if (length(fr1) < length(fr0)), fr1 = [fr1, g1(i)]; end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function spect = makeSpect(c, ch, x1, x2, y1, y2)
% Assemble frames x1 to x2, which are in the cache, into a single block,
% using only frequency bins y1 to y2.

spect = zeros(y2-y1+1, x2-x1+1, length(ch));
for i = 1 : length(ch)
  ch1 = ch(i);
  slots = find(c(ch1).index >= x1 & c(ch1).index <= x2);
  [~,ix] = sort(c(ch1).index(slots));
  spect(:,:,i) = c(ch1).data(y1:y2, slots(ix));
end
