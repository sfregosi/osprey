function win = opWinTypeF(cmd)
% opWinTypeF
%    Set the window type to whatever the popup says.  This is called when
%    the user changes the popup value.
%
% win = opWinTypeF(len)
%    Return a window of length len (as a column vector) to multiply the
%    samples by before FFTing.  This is called from the spectrogram
%    calculator in opComputeSpect.  The Kaiser window uses beta=5.
%
% num = opWinTypeF('default')
%    Set the window type to the default value ('Hamming').
% 
% str = opWinTypeF('string')
%    Return the popup string with the |-separated list of names.
%
% opWinTypeF('setpopup')
%    Set the displayed popup to the correct name.
%
% win = opWinTypeF('name')
%    Return the name of the window. Used in printing.

global opWinTypePopup opWinType

if (nargin < 1)
  x = get(opWinTypePopup, 'Value');
  if (x > 1)
    prev = opWinType;
    opWinType = x + iff(exist('kaiser.m','file') > 0, 0, 1);
    if (prev ~= x), opRefresh(1); end
  else
    % User chose the 'Win Type' on the menu.  Fix: reset popup to correct value.
    opWinTypeF('setpopup');
  end
elseif (ischar(cmd))
  if (strcmp(cmd, 'default'))
    opWinType = 5;				% default is Hamming
  elseif (strcmp(cmd, 'string'))
    % No signal processing toolbox? omit Kaiser.
    win = ['Window Type|' ...
	    iff(exist('kaiser.m','file'), '    Kaiser|', '') ...
	    '    Bartlett|    Hann|    Hamming|    Blackman|    Rectangular'];
  elseif (strcmp(cmd, 'name'))
    win = {'Kaiser' 'Bartlett' 'Hann' 'Hamming' 'Blackman' 'Rectangle'};
    win = win{opWinType-1};
  elseif (strcmp(cmd, 'setpopup'))
    set(opWinTypePopup, 'Value', opWinType);
  else 
    error('Osprey internal error: Bad string arg %s for %s.', cmd, mfilename);
  end
else
  len = cmd;
  typ = opWinType;
  if (typ == 2 && ~exist('kaiser.m','file'))
    disp('You have requested a Kaiser window (perhaps in a preferences');
    disp('file?), but you need to buy the signal processing toolbox for');
    disp('that.  I will use a Hamming window instead.');
    opWinType = 5;
    typ = 5;
  end
  n = ((1 : len) / (len + 1)).';          % ranges from 0 to 1 NON-inclusive
  if (typ == 2)                           % Kaiser
    win = kaiser(len, 5);
  elseif (typ == 3)                       % Bartlett (triangular)
    win = 1 - 2 * abs(n - 0.5);
  elseif (typ == 4)                       % Hann
    win = 0.5 - 0.5 * cos(2 * pi * n);
  elseif (typ == 5)                       % Hamming
    win = 0.54 - 0.46 * cos(2 * pi * n);
  elseif (typ == 6)                       % Blackman
    win = 0.42 - 0.5 * cos(2 * pi * n) + 0.08 * cos(4 * pi * n);
  elseif (typ == 7)      			        % rectangular
    win = ones(length(n), 1);
  else
    error('Hmmm.  Unknown window type, which should be impossible.');
  end
end
