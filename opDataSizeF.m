function data = opDataSizeF(cmd)
% opDataSizeF
%    Set the data size of the current channel to whatever the popup
%    says.  This is called when the user changes the popup value.
%
% opDataSizeF('setpopup')
%    Set the displayed popup to the correct value for channel ch.
% 
% opDataSizeF('default')
%    Set the data size to the default value (256).
% 
% string = opDataSize('string')
%    Return the popup string with the |-separated list of names.
 
global opDataSizePopup opDataSize

if (nargin < 1)
  x = get(opDataSizePopup, 'Value');		% returns line number on popup
  if (x > 1)
    prev = opDataSize;
    opDataSize = 2 ^ (x+1);
    if (opDataSize ~= prev), opRefresh(1); end
  else
    % User chose the 'Data Size' on the menu. Fix: reset popup to correct value.
    opDataSizeF('setpopup');
  end
else
  if (ischar(cmd))
    if (strcmp(cmd, 'default'))
      opDataSize = 256; 			% default
    elseif (strcmp(cmd, 'string'))
      data = ['Samples/frame|           8|         16|         32',...
	      '|         64|       128|       256|       512|     1024',...
	      '|     2048|     4096|     8192|   16384|   32768|   65536',...
	      '|  131072|  262144|  524288'];
    elseif (strcmp(cmd, 'setpopup'))
      set(opDataSizePopup, 'Value', round(log(opDataSize) / log(2) - 1));
    else 
      error('Osprey internal error: Bad string arg %s for %s.', cmd, mfilename);
    end
  else
    error('Osprey internal error: Number passed to %s.', mfilename);
  end
end
