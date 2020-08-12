function c = opGetPcCorrection(r)
%c = opGetPcCorrection(r)
%    Get the playback rate correction factor c for sounds played at
%    rate r.  This factor is used to correct a buggy Matlab-to-
%    soundcard interface that plays back sounds at the wrong rate 
%    (i.e., a rate other than the Fs specified in a sound() call).  
%    This function returns 1 on non-Windows computers.
%
%    If r is not supplied, defaultsrate is used.
%
%    This is used in opNewSignal to set opPlayCorrection.
%
% See also opPlay, defaultsrate.

c = 1;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% old code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin < 1)                                                 %#ok<UNRCH>
  r = defaultsrate;
end
if (~strcmp(sub(computer, 1:2), 'PC'))
  c = 1;
else
  % First make a sound, to get everything in memory.
  snd = zeros(r/4,1);             % 0.25 second of silence
  if (exist('audioplayer'))                                     %#ok<EXIST>
    pl = audioplayer(snd,r);
    if (matlabver >= 7), playblocking(pl); else eval('pl.playblocking'); end
  else
    sound(snd, r);
  end    
  etime(clock,eval('clock'));   % get these functions compiled in Matlab

  % Now do the real thing, and time it.
  snd = zeros(r,1);             % 1 second of silence
  if (exist('audioplayer')), pl = audioplayer(snd,r);           %#ok<EXIST>
  else pl = [];
  end
  t0 = clock;
  if (isempty(pl))
    sound(snd, r);
  else
    if (matlabver >= 7), playblocking(pl); else eval('pl.playblocking'); end
  end
  c = etime(clock, t0);
  if (c > 0.9 && c < 1.1), c = 1; end
  if (c < 0.2), c = 1; end      % not sure why this is needed
end
