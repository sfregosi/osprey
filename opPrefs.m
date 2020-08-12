function opPrefs(cmd, x0)
% opPrefs('newmenu', parent)
%    Create a menu (a child of the parent) listing miscellaneous preferences.
%
% opPrefs('checkmenu')
%    Set check-marks on the menu for the current channel appropriately.
%
% opPrefs('dateTime')
%    Flip the 'show date/time' flag.
%
% opPrefs('showUnits')
%    Flip the 'show unit names' flag.
%
% opPrefs('showTime')
% opPrefs('showFreq')
%    Flip the 'show "time"' or 'show "frequency"' flags, respectively.
%
% opPrefs('showWvf')
%    Show the waveform, or hide it if it's already showing.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% printing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% opPrefs('newprintmenu')
%    Create the print preferences menu.
%
% opPrefs('checkprintmenu')
%    Put checkmarks on the printing preferences menu.
%
% opPrefs('printlabel')
%    Flip the 'print labels' flag.
%
% opPrefs('portrait')
% opPrefs('landscape')
%    Change printed page orientation.
%
% opPrefs('printlef')
% opPrefs('printcen')
% opPrefs('printrig')
%    Change printed page position in X.
%
% opPrefs('printtop')
% opPrefs('printmid')
% opPrefs('printbot')
%    Change printed page position in Y.

global opMiscMenus opPrintLabel uiInputButton uiInput1 opPrintRes
global opUseDateTime opDateTime opDateFix opShowUnits opShowFreq opShowTime
global opShowWvf opGramFrac opTabDelimitLogs opPrintPrefMenu opPrintPortrait
global opLogFreq

switch (cmd)
case 'newmenu'
  par = x0;                            % parent menu
  set(par, 'Callback', 'opPrefs(''checkmenu'');');
  opMiscMenus(1) = uimenu(par, 'Callback', 'opPrefs(''dateTime'');', ...
      'Label', 'Use hr:min:sec labels');
  opMiscMenus(2) = uimenu(par, 'Callback', 'opPrefs(''showUnits'');', ...
      'Label', 'Show "Hz" and "s" at ends of axes');
  opMiscMenus(3) = uimenu(par, 'Callback', 'opPrefs(''showTime'');', ...
      'Label', 'Show "time" label on X-axis');
  opMiscMenus(4) = uimenu(par, 'Callback', 'opPrefs(''showFreq'');', ...
      'Label', 'Show "frequency" label on Y-axis');
  opMiscMenus(5) = uimenu(par, 'Callback', 'opPrefs(''<<dummy>>'');', ...
      'Label', 'Share colors with other windows', 'Visible', 'off');
  opMiscMenus(6) = uimenu(par, 'Callback', 'opPrefs(''showWvf'')', ...
      'Label', 'Show waveform', 'Accelerator', 'w');
  opMiscMenus(7) = uimenu(par, 'Callback', 'opPrefs(''tabDelimitLogs'')',...
      'Label', 'Make log files be tab-delimited');
  opMiscMenus(8) = uimenu(par, 'Callback', 'opPrefs(''logfreq'')',...
      'Label', 'Logarithmic spacing in frequency');
  
case 'checkmenu'
  for i = 1:nCols(opMiscMenus)
    if (i==1), x = opUseDateTime; end
    if (i==2), x = opShowUnits;   end
    if (i==3), x = opShowTime;    end
    if (i==4), x = opShowFreq;    end
    if (i==5), x = 0;             end		% used to be opShareColors
    if (i==6), x = opShowWvf;     end
    if (i==7), x = opTabDelimitLogs; end
    if (i==8), x = opLogFreq;     end

    set(opMiscMenus(i), 'Checked', iff(x, 'on', 'off'));
  end

case 'dateTime'
  opUseDateTime = ~opUseDateTime;
  opDateFix = iff(opUseDateTime, mod(opDateTime, 1) * secPerDay, 0);
  opRedraw;

case 'showUnits'
  opShowUnits = ~opShowUnits;
  opRedraw;

case 'showTime'
  opShowTime = ~opShowTime;
  opRedraw;

case 'showFreq'
  opShowFreq = ~opShowFreq;
  opRedraw;

case 'showWvf'
  opShowWvf = ~opShowWvf;
  opRedraw

case 'logfreq'
  opLogFreq = ~opLogFreq;
  opRedraw

case 'tabDelimitLogs'
  opTabDelimitLogs = ~opTabDelimitLogs;

case 'wvfsize'					% display a dialog box
  uiInput('Set size of waveform display', 'OK|Cancel', ...
      'opPrefs(''wvfsizecallback'')', [], ...
      str2mat('What percentage of the display', ...
              'area should the waveform occupy?'), ...
      sprintf('%.1f', (1 - opGramFrac) * 100));

case 'wvfsizecallback'				% callback from dialog box
  if (uiInputButton ~= 1), return; end			% Cancel?
  k = sscanf(uiInput1, '%f');
  if (length(k) == 1)
    if (k >= 1 && k <= 99)
      opGramFrac = 1 - k / 100;
      opRedraw
    end
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% printing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'newprintmenu'
  par = x0;                            % parent menu
  set(par, 'Callback', 'opPrefs(''checkprintmenu'');');
  opPrintPrefMenu(1) = uimenu(par, 'Callback','opPrefs(''printlabel'');',...
      'Label', 'Include filename label');
  opPrintPrefMenu(2) = uimenu(par, 'Callback','opPrefs(''res75'');',...
      'Label', 'Resolution: 75 dpi', 'Separator', 'on');
  opPrintPrefMenu(3) = uimenu(par, 'Callback','opPrefs(''res300'');',...
      'Label', 'Resolution: 300 dpi');
  opPrintPrefMenu(4) = uimenu(par, 'Callback','opPrefs(''res600'');',...
      'Label', 'Resolution: 600 dpi');
  opPrintPrefMenu(5) = uimenu(par, 'Callback', 'opPrefs(''landscape'');',...
      'Label', 'Print landscape', 'Separator', 'on');
  opPrintPrefMenu(6) = uimenu(par, 'Callback', 'opPrefs(''portrait'');',...
      'Label', 'Print portrait');

case 'checkprintmenu'
  set(opPrintPrefMenu, 'Checked', 'off');
  set(opPrintPrefMenu(iff(opPrintPortrait, 6, 5)), 'Checked', 'on')
  set(opPrintPrefMenu(1), 'Checked', iff(opPrintLabel, 'on', 'off'))
  ix = iff(strcmp(opPrintRes,'-r75'), 2, iff(strcmp(opPrintRes,'-r600'), 4,3));
  set(opPrintPrefMenu(ix), 'Checked', 'on')

case 'landscape',  opPrintPortrait = false;
case 'portrait',   opPrintPortrait = true;
case 'printlabel', opPrintLabel = ~opPrintLabel;
case 'res75',      opPrintRes = '-r75';
case 'res300',     opPrintRes = '-r300';
case 'res600',     opPrintRes = '-r600';

otherwise
  error(['Osprey internal error: Unknown command: ' cmd]);
end
