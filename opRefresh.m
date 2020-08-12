function opRefresh(newspect, setbc)
% opRefresh
% opRefresh(0)
%    Refresh the image for all visible channels, assuming something 
%    like brightness or contrast has changed.
%
% opRefresh(1)
%    Recalculate the spectrogram (after something like hopsize has changed)
%    (i.e. flush the cache) and refresh the image.
%
% opRefresh(1 or 0, setbc)
%    If a third argument is present and non-zero, set default initial
%    brightness/contrast values.

global opChans

if (nargin < 1), newspect = 0; end
if (nargin < 2), setbc    = 0; end

if (newspect)
  opCache('clear');
end

opRefChan(opChans, setbc);
