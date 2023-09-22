function opMenus
% opMenus
% Create the pulldown menus in the menu bar.
% If they already exist, return immediately.

global opFig opFileMenu opChannelMenu opHScrollMenu opVScrollMenu
global opDataLogMenu opInhibitRedraw
global opLogMenuNext opLogMenuNextAny opLogMenuPrev opLogMenuPrevAny

if (~isempty(opFileMenu) && any(get(opFig, 'Children') == opFileMenu))
  return
end

% Get rid of MATLAB's File, Windows, Help menus.
if (matlabver >= 5)
  opInhibitRedraw = 1;						%#ok<NASGU>
  set(opFig, 'MenuBar', 'none', 'HandleVis', 'on');
  opInhibitRedraw = 0;
end

% Menus.

opFileMenu = uimenu(opFig, 'Label', 'File  ');
f = opFileMenu;
uimenu(f, 'Label', 'Open...',         'Callback', 'opOpen(''open'');', ...
    'Accelerator', 'o');
uimenu(f, 'Label', 'Next file in folder',  'Callback', 'opNextFile(''next'');');
uimenu(f, 'Label', 'Previous file in folder',  'Callback', 'opNextFile(''prev'');');
uimenu(f, 'Label', 'Calibration...',  'Callback', 'opCalibrate');
uimenu(f, 'Label', 'Save selection as...','Callback', 'opEdit(''saveAs'');')
uimenu(f, 'Label', 'Play whole sound','Callback', 'opPlay(''all'')');
si = uimenu(f, 'Label', 'Save/print image');
uimenu(si, 'Label', 'PNG file...',    'Callback', 'opPrint(''png'')');
uimenu(si, 'Label', 'JPEG file...',   'Callback', 'opPrint(''jpg'')');
uimenu(si, 'Label', 'EPS file...',    'Callback', 'opPrint(''eps'')');
uimenu(si, 'Label', 'TIFF file...',   'Callback', 'opPrint(''tiff'')');
uimenu(si, 'Label', 'Sound playback video (AVI)...', ...
    'Callback', 'opPlay(''movie'')');
%pr = uimenu(f, 'Label', 'Print');
uimenu(si, 'Label', 'Print',          'Callback', 'opPrint(''wysiwyg'')');
prPrefs = uimenu(si, 'Label', 'Save/print preferences', ...
    'Callback', 'opPrefs(''checkprintmenu'')', 'Separator', 'on');
opPrefs('newprintmenu', prPrefs);

opChannelMenu = uimenu(f, 'Label', 'Channel');
opChannel('makemenu');
uimenu(f, 'Label', 'Quit',	      'Callback', 'opOpen(''quit'')', ...
    'Accelerator', 'q');

e = uimenu(opFig, 'Label','Edit  ');
uimenu(e, 'Label', 'Copy',	      'Callback', 'opEdit(''copy'');', ...
    'Accelerator', 'c');
%uimenu(e, 'Label', 'Plot waveform',   'Callback', 'opEdit(''plot'');');

s = uimenu(opFig, 'Label', 'Select  ');
uimenu(s, 'Label', 'Clear selection', 'Callback', 'opSelect(''none'')', ...
    'Accelerator', 'l');
uimenu(s, 'Label', 'All',             'Callback', 'opSelect(''all'')', ...
    'Accelerator', 'a');
uimenu(s, 'Label', 'All, H only',     'Callback', 'opSelect(''all-h'')');
uimenu(s, 'Label', 'All, V only',     'Callback', 'opSelect(''all-v'')');
uimenu(s, 'Label', 'Window, H only',  'Callback', 'opSelect(''win-h'')', ...
    'Accelerator', 'h');
uimenu(s, 'Label', 'Window, V only',  'Callback', 'opSelect(''win-v'')', ...
    'Accelerator', 'v');

z = uimenu(opFig, 'Label', 'Zoom  ');
uimenu(z, 'Label', 'to whole sound',  'Callback', 'opZoom(''all'')');
uimenu(z, 'Label', 'to selection',    'Callback', 'opZoom(''sel'')');
uimenu(z, 'Label', 'to sel., H only', 'Callback', 'opZoom(''sel-h'')');
uimenu(z, 'Label', 'to sel., V only', 'Callback', 'opZoom(''sel-v'')');

w = uimenu(opFig, 'Label','Window  ');
uimenu(w, 'Label', 'Spectrum',           'Callback', 'opSpectrum(''info'');');
uimenu(w, 'Label', 'Redraw window',    	 'Callback', 'opRedraw(''position'')');
uimenu(w, 'Label', 'Manual sizing...',   'Callback', 'opRedraw(''mansize'')');
uimenu(w, 'Label', 'Manual scaling...',  'Callback', 'opRedraw(''manscale'')');
uimenu(w, 'Label','Manual T/F limits...','Callback', 'opRedraw(''manTF'')');
uimenu(w, 'Label', 'Linked windows...',  'Callback', 'opView(''link'');');
uimenu(w, 'Label', 'Guess brightness and contrast', ...
    'Callback', 'opRefresh(0,1)', 'Accelerator', 'b');
drawnow
%figure(opFig);      % needed in Matlab 6

p = uimenu(opFig, 'Label', 'Preferences  ');
uimenu(p, 'Label', 'Load prefs...', 'Callback',      'opPrefSave(''load'');');
uimenu(p, 'Label', 'Save prefs...', 'Callback',      'opPrefSave(''save'');');
uimenu(p, 'Label','Auto load prefs...','Callback','opPrefSave(''autoload'');');
uimenu(p, 'Label', 'Measurements...', 'Callback', 'opMeasure(''dialogbox'');')
ss = uimenu(p, 'Label', 'Misc.', 'Callback', 'opPrefs(''checkmenu'');');
opPrefs('newmenu', ss);
uimenu(ss, 'Label', 'Set height of waveform display...', ...
    'Callback', 'opPrefs(''wvfsize'')');
  
v = uimenu(opFig, 'Label', 'View  ');
gc = uimenu(v, 'Label', 'Spectrogram color');
x = 'opColorMap(''setgram'', '; y = ');';
uimenu(gc, 'Label','      hot',     'Callback', [x '''hot(n)'''          y]);
uimenu(gc, 'Label','     gray',     'Callback', [x '''flipud(gray(n))''' y]);
uimenu(gc, 'Label','inverted gray', 'Callback', [x '''gray(n)'''         y]);
uimenu(gc, 'Label','     bone',     'Callback', [x '''flipud(bone(n))''' y]);
uimenu(gc, 'Label','inverted bone', 'Callback', [x '''bone(n)'''         y]);
uimenu(gc, 'Label','      jet',     'Callback', [x '''jet(n)'''          y]);
uimenu(gc, 'Label','     cool',     'Callback', [x '''cool(n)'''         y]);
cs = uimenu(v, 'Label', 'Selection Color');
x = 'opColorMap(''setsel'', '; y = ');';
uimenu(cs, 'Label','Yellow    ', 'Callback', [x '[1 1 0]' y]);
uimenu(cs, 'Label','  Red',      'Callback', [x '[1 0 0]' y]);
uimenu(cs, 'Label','Green',      'Callback', [x '[0 1 0]' y]);
uimenu(cs, 'Label',' Aqua',      'Callback', [x '[0 1 1]' y]);
uimenu(cs, 'Label','Purple',     'Callback', [x '[1 0 1]' y]);
uimenu(cs, 'Label',' Blue',      'Callback', [x '[0 0 1]' y]);
hs = uimenu(v, 'Label', 'H Scroll', 'Callback','opScrollAmount(''s'')');
opHScrollMenu = hs;		% see opScrollAmount
uimenu(hs, 'Label', 'Click in background of H scrollbar scrolls by...');
uimenu(hs, 'Label', '     1/4 screen', 'Callback','opScrollAmount(''h'',1/4)');
uimenu(hs, 'Label', '     1/2 screen', 'Callback','opScrollAmount(''h'',1/2)');
uimenu(hs, 'Label', '     3/4 screen', 'Callback','opScrollAmount(''h'',3/4)');
uimenu(hs, 'Label', '      1   screen','Callback','opScrollAmount(''h'',1)');
vs = uimenu(v, 'Label', 'V Scroll',    'Callback','opScrollAmount(''s'')');
opVScrollMenu = vs;
uimenu(vs, 'Label', 'Click in background of V scrollbar scrolls by...');
uimenu(vs, 'Label', '     1/4 screen', 'Callback','opScrollAmount(''v'',1/4)');
uimenu(vs, 'Label', '     1/2 screen', 'Callback','opScrollAmount(''v'',1/2)');
uimenu(vs, 'Label', '     3/4 screen', 'Callback','opScrollAmount(''v'',3/4)');
uimenu(vs, 'Label', '      1   screen','Callback','opScrollAmount(''v'',1)');

uimenu(v, 'Label', 'Temporarily label time axis from 0','Callback','opRefChan(''StartAt0'')');

% Datalog menu.
d = uimenu(opFig, 'Label', 'Datalog  ');
opDataLogMenu = ...
uimenu(d,'Label','Make log entry',      'Callback','opDataLog(''click'')');
uimenu(d,'Label','Save log as text...', 'Callback','opDataLog(''saveASCII'')');
uimenu(d,'Label','Save log in MATLAB format...','Callback','opDataLog(''save'')');
uimenu(d,'Label','Load log...',          'Callback', 'opDataLog(''load'')');
opLogMenuNext    = uimenu(d,'Label','Next log entry', ...
    'Callback', 'opDataLog(''next'')', 'Accelerator', 'n');
opLogMenuPrev    = uimenu(d,'Label','Previous log entry', ...
    'Callback', 'opDataLog(''prev'')', 'Accelerator', 'p');
opLogMenuNextAny = uimenu(d,'Label','Next entry in any log', ...
    'Callback', 'opDataLog(''nextAny'')', 'Accelerator', 'u', 'Visible','off');
opLogMenuPrevAny = uimenu(d,'Label','Previous entry in any log', ...
    'Callback', 'opDataLog(''prevAny'')', 'Accelerator', 'd', 'Visible','off');
uimenu(d,'Label','Clear log',            'Callback', 'opDataLog(''clear'')');
uimenu(d,'Label','Remove last log entry','Callback','opDataLog(''truncate'')');
uimenu(d,'Label','Show current log',     'Callback', 'opDataLog(''show'')');
uimenu(d,'Label','Use multiple logs...', 'Callback', 'opMultiLog');
set(opFig, 'HandleVis', 'callback');

% Localization menu.
ll = uimenu(opFig, 'Label', 'Locate  ');
if (exist('lsqnonlin', 'file'))
  uimenu(ll, 'Label','Locate selection',    'Callback','opLocate(''locate'')');
  uimenu(ll, 'Label','Localization options','Callback','opLocate(''showDialog'')');
else
  uimenu(ll, 'Label', 'Requires MATLAB''s optimization toolbox');
end

h = uimenu(opFig, 'Label', 'Help  ');
uimenu(h, 'Label', 'Help', 'Callback', 'osprey(''help'')');
