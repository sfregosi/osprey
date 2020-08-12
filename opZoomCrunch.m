function opZoomCrunch(hv,zc)
% opZoomCrunch(HorV, ZorC)
% Zoom or crunch the spectrogram (accroding to ZorC) in either the
% horizontal or vertical (according to HorV) direction.
% Shift it if necessary to keep it on-screen.

global opT0 opT1 opF0 opF1 opTMax opSRate opChans

if (hv == 'h')
  x0 = opT0;
  x1 = opT1;
  xMax = opTMax;
elseif (hv == 'v')
  x0 = opF0;
  x1 = opF1;
  xMax = opSRate / 2;
else 
  error('Unknown hv option passed to opZoomCrunch.')
end

if (zc == 'c')
  inc = (x1 - x0) / 2;
  x0 = x0 - inc;
  x1 = x1 + inc;
  
  if (x0 < 0)
    x1 = x1 - x0;
    x0 = 0;
  end
  if (x1 > xMax)
    x0 = x0 - (x1 - xMax);
    x1 = xMax;
    if (x0 < 0), x0 = 0; end
  end
elseif (zc == 'z')
  if (x0 == 0)
    x1 = x1 / 2;
  else
    incr = (x1 - x0) / 4;
    x0 = x0 + incr;
    x1 = x1 - incr;
  end
else
  error('Unknown zc option passed to opZoomCrunch.')
end

if (hv == 'h')
  opT0 = x0;
  opT1 = x1;
else
  opF0 = x0;
  opF1 = x1;
end

opRefChan(opChans);
