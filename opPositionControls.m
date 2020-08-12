function opPositionControls
% opPositionControls
% (Re-)position the buttons, sliders, text boxes, and so on in the 
% Osprey window.
%
% See opMakeControls for the order of elements in the vector.

global opFig opAxes opNChans opChans opMeasurePos opWvfAxes opAmpCalib
global opShowUnits opShowTime opShowFreq opShowWvf opGramFrac opInhibitRedraw

prev = pushProp(opFig, 'HandleVisibility', 'on', 'Units', 'pixels');

% Create menus if necessary.
opMenus;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create controls (in the wrong positions) if necessary.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prevIR = opInhibitRedraw;	% push previous value
opInhibitRedraw = 1;		%#ok<NASGU>    stop circularity in Matlab V7.1    
controls = opMakeControls(opFig);
opInhibitRedraw = prevIR;	% pop


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The rest of this file positions the controls.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xywh = get(opFig, 'Position');

% Background axes object convering the whole window.
set(controls(1), 'Units', 'pixels', 'Position', [0 0 xywh(3) xywh(4)]);
axes(controls(1));

% Determine width of measurement strings.
dummy = text(50, 50, 'sample rate 0.00000 s', 'FontSize', 8, 'Units','pixels');
mWide = sub(get(dummy, 'Extent'), 3);
delete(dummy);

% Zoom/crunch buttons.
wide = 39;
hinc = 8;
left = 8 + (mWide - hinc - wide - wide) / 2;
top  = xywh(4) - 12;
high = 39;
set(controls(4), 'Position', [left           top-high wide high]);
set(controls(5), 'Position', [left+wide+hinc top-high wide high]);
top = top - high - 8;

set(controls(2), 'Position', [left           top-high wide high]);  
set(controls(3), 'Position', [left+wide+hinc top-high wide high]);
bBot   = top - high;
bRight = left + wide + hinc + wide;				%#ok<NASGU>

% Popup menus.
left = 10;
wide = mWide - 5;
top  = bBot - 12;
high = 18;
inc  = high + 6;
set(controls(13), 'Position', [left top-high wide high]);  top = top - inc;
set(controls(14), 'Position', [left top-high wide high]);  top = top - inc;
set(controls(15), 'Position', [left top-high wide high]);  top = top - inc;
set(controls(16), 'Position', [left top-high wide high]);
pBot   = top - high;
pRight = left + wide;

% Measures.
top = pBot - 20;
left = 6;
opMeasurePos = [left top];	% used by opMeasure('painttext')
opMeasure('painttext');

% Brightness and contrast sliders.
%left = 52 + pRight + iff(opShowFreq, 20, 0);
left = 80 + pRight + iff(opShowFreq, 20, 0);
wide = 200;
bot = 10;
high = 16;
inc = high + 8;
set(controls(6), 'Position', [left bot wide high]);       % contrast slider
set(controls(7), 'Position', [left+wide+5 bot+8]);        % contrast text
%set(controls(8), 'Position', [left+wide+67 bot+2 25 15]); % 'Set' button
bot = bot + inc;
set(controls(9), 'Position', [left bot wide high]);       % brightness slider
set(controls(10), 'Position',[left+wide+5 bot+8]);        % brightness text
sLeft  = left;
sTop   = bot + high;
sRight = left + wide + 80;

% Play rate pulldown.
left = sRight + 15;
wide = 90;
bot = 8;
high = 20;
set(controls(12), 'Position', [left bot wide high]);
rRight = left + wide;
rTop = bot + high;

% Play button.  Same width as play rate pulldown, and sits above it.
bot = rTop;
high = 22;
set(controls(11), 'Position', [left-1 bot wide+2 high]);

% Log button.  (Note: controls(8) used to be the Set button; now that function
% is done via a menu.)
left = rRight + 15;
wide = 80;
bot = 10;
high = 35;
set(controls(8), 'Position', [left bot wide high]);
lRight = left + wide;

% Prev-file and next-file buttons.
left = lRight + 15;
wide = 75;
high = 22;
bot = 6;
vspace = 0;
set(controls(23), 'Position', [left bot+high+vspace wide high]);	% prev
set(controls(24), 'Position', [left bot             wide high-1]);	% next
fRight = left + wide;	%#ok<NASGU>

% Scrollbars and gram(s).  Also waveform(s), if present.
thick     = 15;			% thickness of each scrollbar
left      = 10;			% space to left of vertical scrollbar
right     = 10;			% space to right of vertical scrollbar
top       = 10;			% space above horizontal scrollbar
bot       = 10;			% space below horizontal scrollbar
gspace    = 5;			% space between axes
imLeft  = sLeft;
dbWide  = iff(isnan(opAmpCalib), 0, 35);
imWide  = xywh(3) - imLeft - left - right - thick - dbWide;
imBot   = 35 + sTop + iff(opShowTime, 20, 0);
imHigh  = xywh(4) - imBot - bot - top - thick;
gramhi  = iff(opShowWvf, (imHigh - gspace) * opGramFrac, imHigh);
wvfhi   = imHigh - gspace - gramhi;
grambot = imBot + iff(opShowWvf, wvfhi + gspace, 0);
vsright = imLeft + imWide + left + thick;
set(controls(17), 'Position', [imLeft  (xywh(4)-top-thick)  imWide  thick]);
set(controls(18), 'Position', [(xywh(3)-right-thick-dbWide)  grambot  thick  gramhi]);

% Main axes objects for grams.  First create any axes needed.
for ax = length(opAxes)+1 : opNChans	% loop is usually executed 0 times
  opAxes(ax) =  axes('Units', 'pixels', 'Box', 'off', 'YDir', 'normal', ...
    'TickDir', 'out');
end
for ax = length(opWvfAxes)+1 : opNChans	% loop is usually executed 0 times
  opWvfAxes(ax) =  axes('Units', 'pixels', 'Box', 'off', 'YDir', 'normal', ...
    'TickDir', 'out');
end
% Position all the axes and set visibility.
set(opAxes,    'Visible', 'off');
set(opWvfAxes, 'Visible', 'off');
zgram = (gramhi + gspace) / length(opChans) - gspace;  % height of each gram
zwvf  = (wvfhi  + gspace) / length(opChans) - gspace;  % height of each wvf
for i = 1 : length(opChans)
  set(opAxes(opChans(i)), 'Units', 'pixels', 'Visible', 'on', 'Position', ...
    [imLeft grambot+(length(opChans)-i)*(zgram+gspace) imWide zgram]);
  
  % Waveform axis object(s) (and, for visibility, their children).
  if (opShowWvf)
    set(opWvfAxes(opChans(i)), 'Units','pixels', 'Visible','on', 'Position',...
      [imLeft imBot+(length(opChans)-i)*(zwvf+gspace) imWide zwvf]);
  end
end

% dB colorbar.
left = vsright + 10;
set(controls(20), 'Units', 'pixels', 'Position', [left imBot 10 imHigh], ...
  'Visible', iff(isnan(opAmpCalib), 'off', 'on'), 'TickDir', 'out');

% 'Hz' and 's'
if (opShowUnits)
  set(controls(21), 'Units','pix', 'Pos', [imLeft-23       imBot+imHigh-8])% Hz
  set(controls(22), 'Units','pix', 'Pos', [imLeft+imWide-8 imBot-15])	   % s
end  
set(controls(21), 'Units', 'norm', 'Visible', iff(opShowUnits, 'on', 'off'))
set(controls(22), 'Units', 'norm', 'Visible', iff(opShowUnits, 'on', 'off'))

% controls(23) and controls(24) are above, under prev-file and next-file.

popProp(opFig, prev);
set(opFig, 'HandleVisibility', 'Callback')
