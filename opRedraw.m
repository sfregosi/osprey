function ret0 = opRedraw(cmd, x0, x1)
% opRedraw
%    Remove everything from the current figure and repaint it.
%
% opRedraw('repaint' [,filename [,setbc]])
%    As above.  If filename is present, it becomes the window name.
% If setbc is non-zero, set up initial brightness/contrast values.
%
% scale = opRedraw('curscale')
%    Return window scaling as a 2-element vector [s/inch Hz/inch].
%
% opRedraw('manscale')
%    Ask user for scaling values, then rescale image.
%
% newfiguresize = opRedraw('doscale', [x y], figuresize)
%    [Internal function] Rescale T0,T1,F0,F1 according to [x y] scaling.
%    Returns new figure size (or 0 if don't need to resize).
%
% opRedraw('mansize')
%    Ask user for window-size values, then rescale image.
%
% opRedraw('scalecallback')
%    This is used in the manscale code for handling user input.
%
% opRedraw('sizecallback')
%    This is used in the mansize code for handling user input.
%
% opRedraw('position')
%    Re-position the items in the window after the window size changes.
%
% opRedraw('yaxislabels')
%    Make the Y-axis labels not have exponential notation.
%
% opRedraw('close')
%    Close all Osprey windows.   


% N.B. The opAxes object may not exist yet when this function is called.

global opc opT0 opT1 opF0 opF1 opTMax opSRate opAxes opFig opChans
global uiInput1 uiInput2 uiInputButton opInhibitRedraw

if (nargin < 1),  cmd      = 'repaint'; end
if (nargin >= 2), filename = x0; else filename = ''; end
if (nargin >= 3), setbc    = x1; else setbc = 0;  end

if (~gexist4('opInhibitRedraw')), opInhibitRedraw = 0; end

if (strcmp(cmd, 'curscale'))
  set(opAxes(opc), 'Units', 'inches');  
  pos = get(opAxes(opc), 'Position');
  ret0 = [opT1-opT0, opF1-opF0] ./ pos(3:4);
  
elseif (strcmp(cmd, 'manscale'))
  cur = opRedraw('curscale');
  if (strcmp(cmd, 'manscale'))
    uiInput('Manual scaling', 'OK|^Apply|Cancel',...
	'opRedraw(''scalecallback'')', [0 0], ...
	'X-axis seconds per inch', num2str(cur(1)), ...
	'Y-axis Hertz per inch', num2str(cur(2)));
    return;	% execution continues immediately below upon user input
  end
  
elseif (strcmp(cmd,'scalecallback'))
  if (uiInputButton == 3), return; end			% Cancel
  cur = opRedraw('curscale');
  x = str2double(uiInput1);
  y = str2double(uiInput2);
  if (length(x) ~= 1 || any(x<=0) || any(isnan(x))), x=cur(1); end
  if (length(y) ~= 1 || any(y<=0) || any(isnan(y))), y=cur(2); end
  
  set(opFig, 'Units', 'inch');
  newsz = opRedraw('doscale', [x y], sub(get(opFig,'Pos'), 3:4));
  if (any(newsz))
    set(opFig, 'Units', 'inch');
    fpos = get(opFig, 'Pos');
    if (~newsz(1)), newsz(1) = fpos(3); end
    if (~newsz(2)), newsz(2) = fpos(4); end
    set(opFig, 'Pos', [fpos(1:2) newsz]);
    cmd = 'repaint';		% fall through and repaint window
    filename = ''; 		% for 'repaint'
    setbc = 0;	 		% for 'repaint'
  else 
    opRefresh; 
  end
  
elseif (strcmp(cmd,'doscale'))
  % Compute the scaling using T0/1, F0/1; return [x y] which, if 
  % nonzero, are new figure size.
  xy = x0;					% x-y position
  fsize = x1;					% figure size
  [opT0,opT1,ts] = opRescale(opT0, opT1, opTMax,    xy(1), 1, fsize);
  [opF0,opF1,fs] = opRescale(opF0, opF1, opSRate/2, xy(2), 2, fsize);
  ret0 = [ts fs];				% new figure size; 0 for no chg

elseif (strcmp(cmd, 'mansize') || strcmp(cmd, 'sizecallback'))
  set(opAxes(opc), 'Units', 'inches');  pos = get(opAxes(opc), 'Position');
  set(opFig,       'Units', 'inches'); fpos = get(opFig,       'Position');
  if (strcmp(cmd, 'mansize'))
    uiInput('Manual sizing', 'OK|^Apply|Cancel','opRedraw(''sizecallback'')',...
	[0 0], 'Image width, inches', num2str(pos(3)), ...
	'Image height, inches',num2str(pos(4)));
    return;	% execution continues immediately below upon user input
  end
  if (uiInputButton == 3), return; end		% Cancel
  x = str2double(uiInput1);
  y = str2double(uiInput2);
  if (length(x) ~= 1 || any(x<=0)), x=pos(3); end
  if (length(y) ~= 1 || any(y<=0)), y=pos(4); end
  set(opFig, 'Position', [fpos(1:2), [x y] + (fpos(3:4) - pos(3:4))]); drawnow;
  cmd = 'repaint';			% fall through

elseif (strcmp(cmd, 'manTF'))
  uiInput('Window time/frequency limits', 'OK|^Apply|Cancel', ...
      'opRedraw(''TFcallback'')', [], ...
      'Start and end time', sprintf('[ %-.5g %-.5g ]',opT0,opT1), ...
      'Low and high frequency',sprintf('[ %-.5g %-.5g ]',opF0,opF1));

elseif (strcmp(cmd, 'TFcallback'))
  if (uiInputButton == 3), return; end
  eval(['tt = ', uiInput1, ';']);
  t0 = 0; t1 = 0; f0 = 0; f1 = 0;
  if (length(tt) == 1),     t0 = tt; t1 = tt + (opT1 - opT0);
  elseif (length(tt) == 2), t0 = min(min(tt)); t1 = max(max(tt));
  end
  eval(['ff = ', uiInput2, ';']);
  if (length(ff) == 1),     f0 = ff; f1 = ff + (opF1 - opF0);
  elseif (length(ff) == 2), f0 = min(min(ff)); f1 = max(max(ff));
  end
  t0 = max(t0, 0);
  t1 = min(t1, opTMax);
  f0 = max(f0, 0);
  f1 = min(f1, opSRate/2);
  if (t0 < t1)					% handles '[]' input okay
    opT0 = t0;
    opT1 = t1;
  end
  if (f0 < f1)
    opF0 = f0;
    opF1 = f1;
  end
  opRefresh;

elseif (strcmp(cmd, 'position'))
  % Re-position controls when the window size changes.
  if (~opInhibitRedraw)
    opPositionControls;
    opRedraw('yaxislabels');		% needed if number of Y-ticks changed
  end

elseif (strcmp(cmd, 'yaxislabels'))
  for ch = opChans
    % Fix gram Y-axis not to have exponential notation.
    tx = get(opAxes(ch), 'YTick');
    % Calculate number of digits of precision, dig.
    if (length(tx) > 1), dig = max(0, -floor(log10(abs(1.01 * diff(tx(1:2))))));
    else dig = 3;
    end
    for i = 1 : length(tx)
      t = tx(i);
      % Get Hz without or with a decimal point.
      str = iff(dig==0, sprintf('%d',t), sprintf('%*.*f',dig+2,dig,t));
      if (i == 1), newtx = str; else newtx = str2mat(newtx, str); end
    end
    set(opAxes(ch), 'YTickLabel', newtx);
  end

elseif (strcmp(cmd, 'close'))
  % First close main window, then auxiliary windows.
  closereq		% main window
  for tag = {'opMeasureFig' 'opMeasurePrefsFig' 'OspreySpectrum' ...
	    'opMultiLogFig'}
    delete(findobj(0, 'Tag', tag{1}));
  end

end

% Note:  The 'repaint' code here is executed after some of the above
% commands are finished.  It's not part of the main if-elseif-elseif-else
% for dispatching on cmd.
%
% Anything that uses 'repaint' here should be careful about filename and setbc.

if (strcmp(cmd,'repaint') && ~opInhibitRedraw)
  if (isempty(filename))
    filename = opFileName('getsound');
  end
  opInitFigure(filename);
  drawnow
  opPositionControls;
  opRefresh(0, setbc);
end
