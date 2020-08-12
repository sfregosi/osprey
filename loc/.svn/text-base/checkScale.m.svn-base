function checkScale(val)
%checkScale	Check an entered value, query user about sec/ms if unreasonable.
%
% askedYet = checkScale(askedYet, val)
%    If val > 5, ask whether the delays are in ms, not s.
%    If val < .05, ask whether the delays are in s, not ms.
%    Also set up scaleText, for displaying the units.
%
% Uses global variables scale, scaleText, and askedYet.

global scale scaleText askedYet

if (strcmp(val, 'init'))
  if (~exist('scale'))	% MATLAB stupidity: exist() changed from v4.2 to v5
    scale = [];
  end
  if (isempty(scale))
    scale = 1;		% ==1 if delays are sec, ==1000 if msec
    scaleText = 'sec';
  end
  askedYet = 0;
  scaleText = '';
  return
end

minTime = 1;		% if delay is less than this, ask about seconds
maxTime = 5;		% if delay is more than this, ask about milliseconds

if (~askedYet) 
  if (abs(val) > maxTime & scale == 1)
    ans = input('Are these time delays all in milliseconds? [y/n] ', 's');
    if (length(ans))
      if (lower(ans(1)) == 'y')
	scale = 1000;
	scaleText = ' (msec)';
      end
    end
    askedYet = 1;

  elseif (abs(val) < minTime & val ~= 0 & scale == 1000)
    ans = input('Are these time delays all in seconds? [y/n] ', 's');
    if (length(ans))
      if (lower(ans(1)) == 'y')
	scale = 1;
	scaleText = ' (sec)';
      end
    end
    askedYet = 1;
    
  end
end
