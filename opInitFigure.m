function opInitFigure(windowname)
% opInitFigure(windowname)
% Draw the main Osprey window, with buttons and sliders and so on.
%
% See also opOpen.

global opFig opAxes opDefaultWinPos opNSamp opSRate
global opUseDateTime opDateTime opTitlePrefix

menu_bug_correction = [-5 50];	  % MATLAB bug: windows are displaced this much

if (opExists > 0)
  set(opFig, 'Visible', 'on');

else
  opFig = figure('Units', 'pixels', 'Tag', 'Osprey', ...
    'Position', opDefaultWinPos + [menu_bug_correction 0 0], ...
    'CloseRequestFcn', 'opRedraw(''close'');');
  if (matlabver >= 5), set(opFig, 'ResizeFcn', 'opRedraw(''position'')'); end
  opAxes = [];
end

% Append 
if (gexist4('opTitlePrefix'))
  windowname = [opTitlePrefix windowname];
end

% Append date if available.
if (opUseDateTime && opDateTime ~= 0)
  fileEndDate = opDateTime + (opNSamp / opSRate / secPerDay);
  str = datestr(floor(opDateTime), 'yyyy mmm dd');
  % If file spans midnight, add the next day too.  (Is wrong at end of month!)
  if (floor(opDateTime) ~= floor(fileEndDate))
    str = [str '-' datestr(floor(fileEndDate), 'dd')];
  end
  windowname = [windowname ' (' str ')'];
end

set(opFig, 'Name', windowname, 'NumberTitle', 'off', 'Units', 'pixels', ...
  'Resize', 'on', 'Pointer', 'crosshair', 'Visible', 'on', ...
  'HandleVis', 'callback');
