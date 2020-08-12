function [spect,pixbox,realbox,wvf,wvfbox] = ...
                                      opGetSpect(chans, t0, t1, f0, f1, selbox)
% spect = opGetSpect(chans, t0, t1, f0, f1)
%    Get a spectrogram of the relevant section of sound, and return it.
%    This is done by getting the gram from a cache, reading it from a 
%    file, or computing it.
%
% [spect,pixbox] = opGetSpect(chans, t0, t1, f0, f1, selbox)
%    As above, but also compute pixel coordinates of a box (selbox) specified in
%    time and frequency.  selbox and pixbox are [t0 f0 t1 f1].'.
% 
% [spect,pixbox,realbox] = opGetSpect(chans, t0, t1, f0, f1, selbox)
%    As above, but return a box representing the true bounds of the spect
%    that is returned.  This may be different than [t0 f0 t1 f1].' because of
%    roundoff error, as the dimensions of spect are necessarily integers.
%    The values are the pixel centers of the returned spect. 
%
% [spect,pixbox,realbox,wvf,wvfbox] = opGetSpect(chans, t0, t1, f0, f1, selbox)
%    As above, but also return the samples that went into making spect.
%    These start at realbox(1) but do NOT necessarily end at realbox(2).
%    Also returned in wvfbox are the times of the first and last samples.

global opDataSize opHopSize opZeroPad opSRate opNSamp

data    = opDataSize;
hop     = round(opHopSize * data);
pad     = opZeroPad * data;
srate   = opSRate;
fftSize = data + pad;
fRate   = srate / hop;
binSize = (srate / 2) / (fftSize / 2);
nframe  = floor((opNSamp - data) / hop + 1);

frm0 = max(1,         floor((srate * t0 - (data - 1)/2) / hop + 3/2));
frm1 = min(nframe,    floor((srate * t1 - (data - 1)/2) / hop + 3/2));
bin0 = max(1,         1 + floor(f0 / binSize + 1/2));
bin1 = min(fftSize/2, 1 +  ceil(f1 / binSize - 1/2));

% Make sure they're in order.
frm1 = max(frm0, frm1);
bin1 = max(bin0, bin1);

realbox = [((frm0-1)*hop+(data-1)/2)/srate  (bin0-1)*binSize ...
	   ((frm1-1)*hop+(data-1)/2)/srate  (bin1-1)*binSize];

% Compute any spectrogram frames that aren't there yet.
opPointer('watch');
spect = opCache(chans, frm0, frm1, fftSize, bin0, bin1);
opPointer('crosshair');

pixbox = [];
%if (nargin > 5 && selbox(3) > selbox(1) && selbox(4) > selbox(2))
if (nargin > 5)
  %pixbox = [max(1,            floor(selbox(1) * fRate)   - (frm0-1) + 1), ...
	    %max(1,            floor(selbox(2) / binSize) - (bin0-1) + 1), ...
            %min(nCols(spect),  ceil(selbox(3) * fRate)   - (frm0-1)), ...
	    %min(nRows(spect),  ceil(selbox(4) / binSize) - (bin0-1))];
  pto = (data/2 - hop) / srate;		% pixbox T offset
  pfo = binSize / 2;			% pixbox F offset
  pixbox = [floor((selbox(1,:) - pto) * fRate)   - (frm0-1) + 1
	    ceil(( selbox(2,:) - pfo) / binSize) - (bin0-1) + 1
            ceil(( selbox(3,:) - pto) * fRate)   - (frm0-1)
	    ceil(( selbox(4,:) - pfo) / binSize) - (bin0-1) + 1];
end

if (nargout >= 4)
  wvf = opSoundIn((frm0-1) * hop, (frm1 - frm0) * hop + data, chans);
  wvfbox = [(frm0-1)*hop  (frm1-1)*hop+data-1] / srate;
end
