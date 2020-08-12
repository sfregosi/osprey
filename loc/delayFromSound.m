function [d,m1,m2,xHilb] = delayFromSound(x, sRate, freqs, maxDelay, showXCorr, relOffset)
%delayFromSound		calculate interchannel delays from a multichannel sound
%
% d = delayFromSound(snd, sRate)
%   Given a multi-channel sound 'snd', with each channel in a column, calculate
%   the time delay between channels.  sRate is in samples/second.  The result
%   d is a row vector of length N*(N-1)/2 with the inter-channel time delays (in
%   seconds) for each pair, in this order of pairs:
%     1:2 1:3 1:4...1:N   2:3 2:4 2:5...2:N   3:4 3:5...3:N   .....   (N-1):N
%
%   N.B.: This requires the signal processing toolbox.
%
% d = delayFromSound(snd, sRate, freqs)
%   You can also specify a set of frequencies to filter with. freqs should be
%   a 2-element vector specifying the passband of the filter, in Hz.  The
%   default (which is also used if freqs is []) is to use the entire band,
%   i.e., freqs = [0 sRate/2].
%
% d = delayFromSound(snd, sRate, freqs, maxDelay)
%   Use only answers whose absolute value is between -maxDelay and +maxDelay.
%   maxDelay can be scalar, or can have one value for each channel pair in the
%   order specified above.
%
% d = delayFromSound(snd, sRate, freqs, maxDelay, showXCorr)
%   If showXCorr is true, display the cross-correlation functions in a separate
%   figure.  The default is false.
%
% d = delayFromSound(snd, sRate, freqs, maxDelay, showXCorr, relOffset)
%   relOffset specifies a relative time offset between the start times (in
%   seconds) of the sound samples in each channel.  It's a length-N vector, with
%   N the number of channels.  Only *differences* between relOffset values
%   matter.  The default is 0.
%
% [d,m1,m2,xcFuncs] = delayFromSound( ... )
%   Additional return arguments are the phone indices used in the
%   cross-correlations (m1 and m2) and the cross-correlation functions between
%   all pairs of phones.
%
% Dave Mellinger

if (nargin < 3), freqs = []; end
if (nargin < 4), maxDelay = nRows(x) / sRate; end
if (nargin < 5), showXCorr = false; end
if (nargin < 6), relOffset = zeros(1, nCols(x)); end

if (nCols(x) < 3)
  error('I need at least 3 channels to do localization.')
end

if (isscalar(maxDelay))
  maxDelay = maxDelay * ones(1, (nCols(x) * (nCols(x)-1)) / 2);
end

[m1,m2] = allPairs(nCols(x));
if (isempty(freqs))
  xc = corr(x(:,m1), x(:,m2));			% inefficient! possibly very!!
else
  filt = freqs / (sRate/2);
  xc = corr(x(:,m1), x(:,m2), filt);		% inefficient! possibly very!!
end

if (~exist('hilbert', 'file'))
  % Should fix this! Analytic signal (via Hilbert transform) is easy.  See
  % 'Analytic signal' in Wikipedia.
  error('You need the signal processing toolbox to localize sounds.');
end
xHilb = abs(hilbert(xc));				% analytic signal

% Get index of maximum possible delay.
maxDI = round(maxDelay * sRate);
maxDI = min(maxDI, nRows(x));

% Do the time offset for each pair.
offT = zeros(1, length(maxDI));
midIx = (nRows(xHilb) + 1) / 2;
d = nan(1, length(maxDI));
for i = 1 : length(maxDI)
  % Get ix0 and ix1, the range of physically possible indices to find peak.
  offT(i) = relOffset(m2(i)) - relOffset(m1(i));
  offIx = round(offT(i) * sRate);
  ix0 = midIx - (maxDI(i)-1) + min(0, offIx);
  ix1 = midIx + (maxDI(i)-1) - max(0, offIx);
  ix0 = max(ix0, 1);
  ix1 = min(ix1, nRows(xHilb));
  if (ix0 <= ix1)				% if ix0>ix1, d(i) stays NaN
    [~,maxIx] = max(xHilb(ix0 : ix1, i));
    d(i) = (maxIx-1 - (midIx - ix0)) / sRate + offT(i);
    %d(i) = (maxIx - midIx + i0-1) / sRate;
  end
  %[~,maxIx] = max(xHilb(midIx-maxDI+1 : midIx+maxDI-1, :));
end
%d
%off

if (showXCorr)
  % Show the cross-correlations.
  f = findobj(0, 'Tag', 'locXCorrFig');
  if (isempty(f))
    f = figure('Name', 'Cross-correlations for location', ...
      'NumberTitle', 'off', 'Tag', 'locXCorrFig'); 
  end
  figure(f)
  for i = 1 : nCols(xHilb)
    subplot(ceil(nCols(xHilb)/2), 2, i)
    % Choose one: all cross-corr values, or just physically possible ones:
    %plot((-midIx+1 : midIx-1) / sRate, xHilb(:,i))
    plot((-maxDI(i)+1 : maxDI(i)-1) / sRate, xHilb(midIx-maxDI(i)+1 : midIx+maxDI(i)-1, i))
    xlims fit
    title(sprintf('%d * %d', m1(i), m2(i)))
    if (i >= nCols(xHilb)-1), xlabel('seconds'); end	% label bottom 2 plots
  end
end
