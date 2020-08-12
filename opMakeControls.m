function controls = opMakeControls(fig)
% controls = opMakeControls(fig)
%    Return the vector of controls for the current window.  Assumes fig
%    is an Osprey window (see opInitFigure).  If the controls already exist,
%    returns immediately; otherwise creates the controls and returns them.
%    The controls are NOT positioned correctly; see opPositionControls.
%
%    Note that opAxes and opWvfAxes are now created in opPositionControls.
%
% The order of elements in the controls vector is
%
%   1   background pixel-based axes (opWindowAxes)
%   2   Horz. Zoom   button
%   3   Horz. Crunch button
%   4   Vert. Zoom   button
%   5   Vert. Crunch button
%   6   Contrast slider
%   7   Contrast text
%   8   Log button (used to be Set button)
%   9   brightness slider
%  10   brightness text
%  11   Play button
%  12   Playback Rate pulldown
%  13   Data Size   pulldown
%  14   Zero Pad    pulldown
%  15   Hop Size    pulldown
%  16   Window Type pulldown
%  17   h scroll bar
%  18   v scroll bar
%  19   main gram image axes object
%  20	dB colorbar axes
%  21   'Hz'
%  22   's'
%  23   next-file button
%  24   prev-file button

global opControls opWindowAxes opContrastSlider opContrastText
global opBrightnessSlider opBrightnessText opPlayBut opPlayRateMenu
global opDataSizePopup opZeroPadPopup opHopSizePopup opWinTypePopup
global opHScrollBar opVScrollBar opAxes opWvfAxes
global opVCrunchIcon opVZoomIcon opHCrunchIcon opHZoomIcon opImageButtons

if (opExists == 2)
  controls = opControls;
  return
end

% Create new controls.

figure(fig);
set(fig, 'Units', 'pixels');
controls = zeros(1,22);

if (~gexist4('opHCrunchIcon'))
  opIcons;
end

if (matlabver <= 4), set(fig, 'NextPlot', 'add');
else,                set(fig, 'HandleVisibility', 'on');
end

% Background axes object convering the whole window.
controls(1)  = axes('Visible', 'off');
opWindowAxes = controls(1);

% Zoom/crunch buttons.
controls(2)  = axes('Units', 'pixels');
opImageButtons(1) = image(opHZoomIcon,'ButtonD','opZoomCrunch(''h'',''z'')');
set(controls(2), 'Visible', 'off');

controls(3)  = axes('Units', 'pixels');
opImageButtons(2) = image(opHCrunchIcon,'ButtonD','opZoomCrunch(''h'',''c'')');
set(controls(3), 'Visible', 'off');

controls(4)  = axes('Units', 'pixels');
opImageButtons(3) = image(opVZoomIcon,'ButtonD','opZoomCrunch(''v'',''z'')');
set(controls(4), 'Visible', 'off');

controls(5)  = axes('Units', 'pixels');
opImageButtons(4) = image(opVCrunchIcon,'ButtonD','opZoomCrunch(''v'',''c'')');
set(controls(5), 'Visible', 'off');

axes(opWindowAxes);

% Contrast and brightness sliders and associated text
controls(6)  = uicontrol('Style', 'slider', 'Callback', 'opSlider(''c'')', ...
	       'Value', 0.5);
opContrastSlider = controls(6);
uiSlider(opContrastSlider);
controls(7)  = text('Units', 'pixels', 'String', 'Contrast');
opContrastText = controls(7);

controls(9)  = uicontrol('Style', 'slider', 'Callback','opSlider(''b'')', ...
	       'Value', 0.5);
opBrightnessSlider = controls(9);
uiSlider(opBrightnessSlider);
controls(10) = text('Units','pixels', 'String','Brightness');
opBrightnessText = controls(10);

% Play and Playback Rate buttons
controls(11) = uicontrol('Style','PushB', ...
               'Callback', 'opPlay(''button'')', ...
	       'HorizontalAlign', 'center');
opPlayBut = controls(11);
opPlay('disptext');	                     	% set to default value
controls(12) = uicontrol('Style', 'popup', ...
               'HorizontalAlign', 'right', ...
               'Callback', 'opPlay(''setrate'')',...
	       'String', '0');
opPlayRateMenu = controls(12);

% Log button.
controls(8) = uicontrol('Style','PushButton', ...
               'Callback', 'opDataLog(''click'')', ...
	       'HorizontalAlign', 'center', 'String', 'Add to log');

% Pulldowns -- data size, zero pad, hop size, win type
controls(13) = uicontrol('Style', 'Popup', ...
               'String', opDataSizeF('string'), ...
	       'Callback', 'opDataSizeF');
opDataSizePopup = controls(13);
opDataSizeF('setpopup');	                % display current value
controls(14) = uicontrol('Style', 'Popup', ...
               'String', opZeroPadF('string'), ...
	       'Callback', 'opZeroPadF');
opZeroPadPopup = controls(14);
opZeroPadF('setpopup');		                % display current value
controls(15) = uicontrol('Style', 'Popup', ...
               'String', opHopSizeF('string'), ...
	       'Callback', 'opHopSizeF');
opHopSizePopup = controls(15);
opHopSizeF('setpopup');		                % display current value
controls(16) = uicontrol('Style', 'Popup', ...
               'String', opWinTypeF('string'), ...
               'Callback', 'opWinTypeF');
opWinTypePopup = controls(16);
opWinTypeF('setpopup');		                % display current value

% Main scroll bars
controls(17) = uicontrol('Style', 'slider', 'Callback', 'opSlider(''h'')', ...
    'BusyAction', 'cancel', 'Interruptible', 'off');
opHScrollBar = controls(17);
controls(18) =  uicontrol('Style', 'slider', 'Callback', 'opSlider(''v'')',...
    'BusyAction', 'cancel', 'Interruptible', 'off');
opVScrollBar = controls(18);		

% Main image axes objects. These are now made in opPositionControls, not here.
if (opExists == 2), delete(opAxes); end  % not sure if this is needed
opAxes = [];

% dB colorbar
controls(20) = axes;
axes(opWindowAxes);

% 'Hz' and 's'
controls(21) = text('Units','pixels', 'String','Hz');	% Hz
controls(22) = text('Units','pixels', 'String','s');	% s

% 'Next file' and 'Prev file' buttons.
controls(23) = uicontrol('Style','pushbutton', ...
  'Callback', 'opNextFile(''prev'')', ...
  'HorizontalAlign', 'center', 'String', 'Previous file');
controls(24) = uicontrol('Style','pushbutton', ...
  'Callback', 'opNextFile(''next'')', ...
  'HorizontalAlign', 'center', 'String', 'Next file');

% Waveform axis.
if (~isempty(opWvfAxes)), delete(opWvfAxes(ishghandle(opWvfAxes))); end
opWvfAxes = [];

opControls = controls;

%#ok<*MAXES>
