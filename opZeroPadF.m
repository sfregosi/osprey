function pad = opZeroPadF(cmd)
% opZeroPadF
%    Set the zero pad size to whatever the popup says.  This is called
%    when the user changes the popup value.
%
% opZeroPadF('setpopup')
%    Set the displayed popup to the correct value.
% 
% opZeroPadF('default')
%    Set the zero pad size to the default value (0).
% 
% string = opZeroPadF('string')
%    Return the popup string with the |-separated list of names.
 
global opZeroPadPopup opZeroPad

if (nargin < 1)
  x = get(opZeroPadPopup, 'Value');
  if (x > 1)
    prev = opZeroPad;
    opZeroPad = 2 ^ (x-2) - 1;
    if (opZeroPad ~= prev), opRefresh(1); end
  else
    opZeroPadF('setpopup');			% reset popup to correct value
  end
elseif (isstr(cmd))
  if (strcmp(cmd, 'default'))
    opZeroPad = 0;				% default
  elseif (strcmp(cmd, 'string'))
    pad = 'Zero Padding|    None|     1x|     3x|     7x|    15x|    31x';
  elseif (strcmp(cmd, 'setpopup'))
    set(opZeroPadPopup, 'Value', round(log(opZeroPad+1) / log(2) + 2));
  else
    error('Osprey internal error: Bad string arg %s for %s.', cmd, mfilename);
  end
else
  error('Osprey internal error: Number passed to %s.', mfilename);
end
