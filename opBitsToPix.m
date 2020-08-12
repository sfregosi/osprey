function [pix,dBLims] = opBitsToPix(bits, bright, contr)
% [pix,dBLims] = opBitsToPix(bits, bright, contr, selpixbox)
%    Convert values in spectrogram (which might be 3-D) from log-scaled
%    numbers (bits) to grayscale values (pix).  Also returns the dB spectrum
%    levels (re 1 uPa^2/Hz) of the brightest and darkest colormap values.
%
%    Now done in opRefChan: Color the selection using selpixbox.

global opDataSize opSRate opAmpCalib

opColorMap('setlimits', bright, contr);
[lolim, hilim, n] = opColorMap('getlimits');
if (~opColorMap('install', bright, contr))
  error('Internal colormap error.'); 
end

% Linearly scale 'bits' so that value lolim becomes 1 and hilim becomes n.
mul = (n-1) / (hilim - lolim);
pix = min(n, max(1, round((bits + (1/mul - lolim)) * mul)));

% Calculate absolute levels.
if (~isnan(opAmpCalib))
  bLims = [1 n]/mul - (1/mul - lolim);	% bits values of brightest/darkest pix
  win = opWinTypeF(opDataSize);	 	% window function; column vec
  scale = sqrt(opDataSize / 256);		% scaling factor from opComputeSpect
  normWin = sum(win.^2) * opSRate / 2;	% from NRC book Ocean Noise & Mar Mamms
  powLims = (exp(bLims) * scale * opAmpCalib) .^ 2 / normWin;
  dBLims = 10 * log10(powLims);
else
  dBLims = [nan nan];
end

% [now done in opRefChan] Color the selection.
% selpixbox = [max(selpixbox(1),1)  max(selpixbox(2),1) ...
%   min(selpixbox(3),nCols(pix))  min(selpixbox(4),nRows(pix))];
% if (selpixbox(1) <= selpixbox(3) && selpixbox(2) <= selpixbox(4))
%   % Do the selection.
%   for ix = 1 : size(pix,3)
%     pix(selpixbox(2):selpixbox(4), selpixbox(1):selpixbox(3), ix) = ...
%       pix(selpixbox(2):selpixbox(4), selpixbox(1):selpixbox(3), ix) + n;
%   end
% end
