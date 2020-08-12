function [ret0,ret1,n] = opColorMap(cmd, x0, x1)
% opColorMap('setlimits', brightness, contrast)
%    Set colormap limits when drawing new images.
%
% [lolim,hilim,ngrays] = opColorMap('getlimits')
%    Return the range of values which should be converted to pixel values
%    ranging from 1 to ngrays.
%
% ngrays = opColorMap('getlimits')
%    With only one return value, return the number of gray values.
%
% opColorMap('getselindex')
%    Get the index of the selection color.
%
% repaint = opColorMap('install', brightness, contrast)
%    If possible, install a colormap for the given brightness and 
%    contrast values and return 1.  If not possible, return 0 to indicate
%    that the pixels must be repainted.
%
% [b,c] = opColorMap('setbc', spect)
%    Given a spectrogram (which might be 3-D), calculate initial brightness
%    and contrast values.
%
% opColorMap('setgram', colorfunction)
%    Set the name of the colormap function that constructs the colormap to use.
%    The colorfunction should be a string calling a function with an arg of n,
%    as, for example, 'gray(n)'.
%
% opColorMap('setsel', rgb)
%    Set the selection color to the given 3-element RGB vector.

% Color handling:
% Brightness and contrast control two linear mappings:
% From spectrogram values into pixel values, and from pixel values
% into grey levels.  whiteval and blackval are the spectrogram
% values that are mapped to pixel values c1 and c0, respectively,
% which are mapped to white and black, respectively, in the color 
% map.  opLoLimit and opHiLimit are mapped to pixel values 1 to n.
%
% When pixel values are computed (see opBitsToPix), the color
% map is set up so that the range from black to white spans
% only a portion of the available (n=48) colors.  This is so that
% small changes to brightness or contrast can be effected by 
% changing opLoLimit and opHiLimit and installing a different 
% color map.

global opFig opLoLimit opHiLimit opColor 
global opIconColorMap opColorMapName opAxes opBrightness opContrast
global opBackgroundColor opBrightReverse

n = 48;					% number of grays
span = 0.8;				% big=>fine, small=>coarse color map
minnie = log(1e-1);			% min displayable value
maxie  = log(1e9);			% max displayable value

if (nargin >= 3)
  x1 = max(1-x1, 0.001);		% slider sense is reverse of color map
end

switch(cmd)
  case 'getlimits'		% return the colormap limits
    if (nargout > 1)
      ret0 = opLoLimit;
      ret1 = opHiLimit;
    else
      ret0 = n;
    end
    
  case 'getselindex'	% return index of selection color
    ret0 = n + 1;
    
  case 'geticonbase'	% return first index of icon colormap
    ret0 = n + 2;
    
  case 'setbc'		% return brightness and contrast
    % Heuristic: 85% of pixels are white; 14% more scale linearly
    % to half-grey; the rest scale linearly at the same rate.
    spect = x0;
    pct = percentile(spect(:), [0.85  0.99]);
    white = pct(1);
    black = (pct(2) - pct(1)) * 2 + pct(1);
    ret0 =     ((black + white) - 2*minnie) / (maxie - minnie) / 2;% brightness
    ret1 = 1 - ((black - white)           ) / (maxie - minnie) ;   % contrast
    
  case 'setlimits'	% set limits
    bright = x0;
    contr  = x1;
    opLoLimit = (maxie - minnie) * (bright - contr/2) + minnie;
    opHiLimit = (maxie - minnie) * (bright + contr/2) + minnie;
    
  case 'install'	% try to install a color map
    bright = x0;
    contr  = x1;
    
    % Construct color map.
    whiteval = (maxie - minnie) * (bright - contr/2 * span) + minnie;
    blackval = (maxie - minnie) * (bright + contr/2 * span) + minnie;
    
    range = opHiLimit - opLoLimit;
    c0 = round((whiteval-opLoLimit)/range * (n-1) + 1); % white before here
    c1 = round((blackval-opLoLimit)/range * (n-1) + 1); % black after here
    
    if (c0 < 1 || c1 > n || c1-c0+1 < n/3)
      ret0 = 0;				% can't diddle cmap; must redraw pixels
    else
      basemap = eval(opColorMapName);
      opBackgroundColor = basemap(1,:);
      
      % colormap: white in 1..c0; then grays in c0..c1; then black in c1..n
      map = [ones(c0-1,1) * basemap(1,:);
	interp1((1:n)', basemap, linspace(1,n,c1-c0+1).');
	ones(n-c1,1) * basemap(n,:)];
      
      % Append to map yellow (or whatever) for selections and icon colors.
      map = [map;
	opColor;      %ones(n,1) * opColor * opColorDepth + (1-opColorDepth) * map;
	opIconColorMap
	];
      
      set(opFig, 'HandleVis', 'on');
      colormap(map);
      set(opFig, 'HandleVis', 'callback');
      ret0 = 1;
      set(opAxes, 'Color', basemap(1,:));
      
      % Set whether 0 values correspond to left (1) or right (0) end of slider.
      opBrightReverse = (norm(opBackgroundColor) < 0.5);
    end
    
  case 'setgram'	% set the colormap name
    opColorMapName = x0;
    opColorMap('install', opBrightness, opContrast);
    opRefresh;
    
  case 'setsel'		% set the selection color
    opColor = x0;
    opColorMap('install', opBrightness, opContrast);
    
  otherwise
    error('Osprey internal error: unknown command %s.', cmd);
    
end
