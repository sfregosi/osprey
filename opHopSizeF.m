function hop = opHopSizeF(cmd)
% opHopSizeF
%    Set opHopSize to whatever the popup says.  This is called when
%    the user changes the popup value.
%
% opHopSizeF('setpopup')
%    Set the displayed popup to the correct value.
% 
% opHopSizeF('default')
%    Initialize the hop size to the default value.
% 
% string = opHopSizeF('string')
%    Return the popup string with the |-separated list of names.
 
global opHopSizePopup opHopSize

if (nargin < 1)
  val = get(opHopSizePopup, 'Value');
  if (val > 1)
    prev = opHopSize;
    opHopSize = 2 ^ (val-6);
    if (opHopSize ~= prev), opRefresh(1); end
  else
    % User chose the 'Hop Size' on the menu.  Fix: reset popup to correct value.
    opHopSizeF('setpopup');
  end
elseif (isstr(cmd))
  if (strcmp(cmd, 'default'))
    opHopSize = 2 ^ (-1);		 	% default is 1/2
  elseif (strcmp(cmd, 'setpopup'))
    set(opHopSizePopup, 'Value', round(log(opHopSize) / log(2) + 6));
  elseif (strcmp(cmd, 'string'))
    hop = 'Hop Size|    1/16|    1/8|    1/4|    1/2|      1|      2|      4|      8|    16';
  else
    error('Osprey internal error: Bad string arg %s for %s.', cmd, mfilename);
  end
else
  error('Osprey internal error: Number passed to %s.', mfilename);
end
