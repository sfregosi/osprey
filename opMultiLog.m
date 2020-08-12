function [ret1,ret2] = opMultiLog(cmd, logNo)
%opMultiLog        set osprey up for maintaining several data logs at once
%
% opMultiLog(N)
%    Display a window with N buttons, allowing you to choose between the
%    N data logs that will be maintained simultaneously.  The current data
%    log, if there is one, becomes Log #1.
%
% opMultiLog('showlognum' [,force])
%    If this is a different log from the one last used, or if the current log
%    is empty, or if 'force' is present and non-zero, show the log number.
%    Called from opDataLog.
%
% [logcat,lognum] = opMultiLog('catall')
%    Concatenate all of the logs vertically and return it as logcat.
%    Also return a 2-column index array: column 1 says which log that row of
%    logcat comes from, and column 2 says which entry in that log the row is.
%
% ok = opMultiLog('checknewfile')
%    Check whether it's okay to open a new file. If unsaved logs exist, this
%    means checking whether the user wants to save them, and returning ok=1
%    if they're all saved or the user says throw them away.  If there are no
%    unsaved logs, the return value 'ok' is 1. If the user cancels, ok=0.
%
% name = opMultiLog('getname' [, logNo])
%    Return the name of the current log, or of logNo if that is specified.  
%    This is either a user-specified name, or if no name has been specified,
%    a name like 'Log #3'.
%
% str = opMultiLog('getloginfo')
%    Return a string with all current named logs, with quotes around each name.
%    Used in saving prefs.
%
% opMultiLog('setloginfo')
%    Set the current log names.  Used in loading prefs.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Internal callbacks:
% opMultiLog('go')
%    Callback after user chooses the number of logs desired.
%
% opMultiLog('showbuttonfig')
%    Display the figure with the N buttons on it.  Resize buttons as needed
%    to fit names.
%
% opMultiLog('click', N)
%    Callback for clicking on radiobutton #N.  Save the current log and load
%    up log #N.
%
% opMultiLog('saveall')
%    For each existing log, do a 'Save datalog as...' in Osprey.
%
% opMultiLog(''checknewfile1')
%    Auxiliary for a callback from checknewfile.
%
% opMultiLog('clearall')
%    User has asked to clear all logs.  Confirm.
%
% opMultiLog('clearall!')
%    Really clear all logs.
%
% opMultiLog('ok')
%    Callback from initial GUI: user clicked OK.  Read number of logs and
%    their names, if any.
%
% opMultiLog('cancel')
%    Callback from initial GUI: user clicked Cancel.

global opLog opLogPrev opLogChanged opLogIx
global opLogMenuNext opLogMenuPrev opLogMenuNextAny opLogMenuPrevAny

global opMlButtons	% the buttons on the display
global opMlLogs		% cell array; copies of opLogs, one per button
global opMlPrevs	% cell array; copies of opLogPrev
global opMlLogIx	% scalar vector; copies of opLogIx
global opMlChangeds	% array of scalars; copies of opLogChanged
global opMlCurrentIx	% index of the currently-enabled log
global opMlNVisible	% number of buttons showing (= number of logs)
global opMlLastLogIx	% last log number that a point was logged to
global opMlLogNames	% cell vector of log names
    
if (~gexist4('opLogIx')),      opLogIx      = inf; end
if (~gexist4('opLogChanged')), opLogChanged = 0;   end



if (nargin < 1)
  % Callback from the main menu.  Show and populate the initial GUI.
  gui = opMultiLogFig;
  if (gexist4('opMlNVisible'))
    if (opMlNVisible > 1)
      set(findobj(gui, 'Tag', 'NLogsEdit'), 'String', num2str(opMlNVisible))
    end
    set(findobj(gui, 'Tag', 'LogNamesEdit'), 'String', opMlLogNames) % cell vec
  end
  return
end

% Find the buttons figure, or generate it if it's not there yet.
f = findobj(0, 'Tag', 'multilog');
if (isempty(f) && ~strcmp(cmd, 'checknewfile') && ~strcmp(cmd, 'logclick'))
  f = opMLFig;
  for ch = get(f, 'Children').'
    if (strcmp(get(ch, 'Type'), 'uicontrol'))
      [k,count] = sscanf(get(ch,'Tag'), 'Log #%d');
      if (count == 1)
        opMlButtons(k) = ch;
	set(opMlButtons(k), 'Units', 'pixels')
      end
    end
  end
  set(f, 'Visible', 'off');          % good for when only 1 log in use
  if (~gexist4('opMlLogs'))
    opMlLogs      = cell(1, length(opMlButtons));
    opMlPrevs     = cell(1, length(opMlButtons));
    opMlChangeds  = zeros(1, length(opMlButtons));
    opMlLogIx     = inf * ones(1, length(opMlButtons));
    opMlCurrentIx = 1;
    opMlLogNames  = cell(0,0);
    set(opMlButtons(1), 'Value', 1);         % turn the radiobutton on
  end
  if (~gexist4('opMlNVisible')), opMlNVisible = 1; end
end

switch(cmd)
case {'ok' 'cancel'}
  % Callback from the initial GUI.
  gui = findobj('Tag', 'opMultiLogFig');	% a figure
  if (strcmp(cmd, 'ok'))
    nEdit     = findobj(gui, 'Tag', 'NLogsEdit');	% a uicontrol/edit
    namesEdit = findobj(gui, 'Tag', 'LogNamesEdit');	% a uicontrol/edit
    [n, count] = sscanf(get(nEdit, 'String'), '%d');
    if (count ~= 1 || n ~= round(n) || n < 1)
      errordlg('Please enter a reasonable number of logs: 1 or more.', ...
	  'Bad number of logs', 'modal')
      return
    end
    % User is asking for a figure with N buttons.
    if (n > length(opMlButtons))
      errordlg(['Sorry, I can handle only ' num2str(length(opMlButtons)) ...
	      ' logs at present.'], 'Too many logs', 'modal');
      return
    end
    opMlNVisible = n;
    opMlLastLogIx = 0;
    opMlLogNames = strtrim(cellstr(get(namesEdit, 'String')));
    opMultiLog('showbuttonfig')		% at last!
  end
  delete(gui)
    
case 'showbuttonfig'
  % Set up n logs and their names.
  set(f, 'Visible', 'on', 'Units', 'pixels')
  n = opMlNVisible;
  if (opMlCurrentIx > n), opMultiLog('click', 1); end
  curr = iff(n > 1, 'current ', '');
  set(opLogMenuNext, 'Label', ['Next entry in ' curr 'log']);
  set(opLogMenuPrev, 'Label', ['Previous entry in ' curr 'log']);
  set(opLogMenuNextAny, 'Visible', iff(n > 1, 'on', 'off'));
  set(opLogMenuPrevAny, 'Visible', iff(n > 1, 'on', 'off'));
  
  % Handle names.  The hard part here is getting the button pos/size right.
  p1 = get(opMlButtons(1), 'Position');
  left = p1(1);
  figpos = get(f, 'Position');
  for i = 1 : length(opMlButtons)
    nm = opMultiLog('getname', i);	% have to find how wide this name is
    tt = text(0,0,nm,'FontSiz',get(opMlButtons(i),'FontSiz'),'Units','pix');
    wid = sub(get(tt, 'Extent'), 3) + 22;  % 22 is for size of radiobutton
    delete(tt)
    set(opMlButtons(i), 'String', nm, 'Position', [left p1(2) wid p1(4)])
    left = left + wid + 4;
    if (i == n), set(f, 'Position', [figpos(1:2) left-2 figpos(4)]); end
  end
  delete(gca)            % axes object gets created by text(...)

case 'click'
  % First save old log values and turn off old button.
  opMlLogs    {opMlCurrentIx} = opLog;
  opMlPrevs   {opMlCurrentIx} = opLogPrev;
  opMlChangeds(opMlCurrentIx) = opLogChanged;
  opMlLogIx   (opMlCurrentIx) = opLogIx;
  set(opMlButtons(opMlCurrentIx), 'Value', 0);   % turn old radiobutton off
  
  % Then set up new log value and turn on new button.
  opLog        = opMlLogs{logNo};		% set up newly-clicked log
  opLogPrev    = opMlPrevs{logNo};
  opLogChanged = opMlChangeds(logNo);
  opLogIx      = opMlLogIx(logNo);
  set(opMlButtons(logNo), 'Value', 1);		% turn new button on
  opMlCurrentIx = logNo;

case 'saveall'
  origlog = opMlCurrentIx;
  for i = 1 : opMlNVisible
    opMultiLog('click', i);
    opDataLog('saveASCII', opMultiLog('getname', i));
  end
  opMultiLog('click', origlog);

case 'getname'
  if (nargin < 2), logNo = opMlCurrentIx; end
  ret1 = '';
  if (logNo <= length(opMlLogNames))
    ret1 = opMlLogNames{logNo};         % sometimes this is empty
  end
  if (isempty(ret1))
    ret1 = sprintf('Log #%d', logNo);
  end
  
case 'getloginfo'		% used when saving preferences
  % Return a cell array with the number of logs and any names that are defined.
  ret1 = sprintf('{ %d ', opMlNVisible);
  for i = 1 : length(opMlLogNames)
    ret1 = [ret1 '''' opMlLogNames{i} ''' '];		%#ok<AGROW>
  end
  ret1 = [ret1 '}'];

case 'setloginfo'
  % Parse a cell array as generated by 'getloginfo'.
  opMlNVisible = logNo{1};
  opMlLogNames = logNo(2:end);
  if (opMlNVisible > 1 || strcmp('on', get(f, 'Visible')))
    opMultiLog('showbuttonfig');
  end

case 'checknewfile'
  % Beware: This gets called from osprey.m before dialog box figure exists.
  if (~gexist4('opMlCurrentIx') || opMlCurrentIx < 1)
    % This gets called from opNewSignal when opening a new file.
    %mprintf('Omitting checknewfile!'); ret1=1; %ret1 = opDataLog('checknewfile');
    ret1 = 1;
    return
  end
  % See whether any log has changed.  If so, ask user what to do.
  ret1 = true;			% default value
  if (any(opMlChangeds) || opLogChanged)
    warnstate = warning('off');					%#ok<WNOFF>
    str = str2mat('There are unsaved log(s). What should I do with them?', ...
	'', ...
	'(To cancel, close this window via the button in its title bar.)');
    v = questdlg(str, 'Unsaved logs','Save them and clear','Append to them',...
        'Clear them', '');		% that last '' prevents a default...
    warning(warnstate);			% ...but causes a warning
    switch(v)
      case 'Save them and clear'
        opMultiLog('saveall');
        opMultiLog('clearall!')
      case 'Append to them'
        % don't need to do anything
      case 'Clear them'
        opMultiLog('clearall!');
      case ''				% empty str: user clicked close window
        ret1 = false;			% override default value of 1
    end
  end
  return

case 'clearall'
  warnbox(str2mat('Clear all logs?', ...
    'Do you really want to clear all the logs?', 'You can''t undo this!'), ...
    'opMultiLog(''clearall!'')');

case 'clearall!'
  % Beware: This gets called from opNewSignal before dialog box (figure) exists.
  if (~gexist4('opMlCurrentIx') || opMlCurrentIx < 1)
    % This gets called from opNewSignal when opening a new file.
    opDataLog('clear!');
  else
    origlog = opMlCurrentIx;
    for i = 1 : opMlNVisible
      opMultiLog('click', i)
      opDataLog('clear!');
    end
    opMultiLog('click', origlog);
  end

case 'showlognum'
  % Show log name if this is a different log from last time, or if the
  % second arg is present and non-zero.
  if (gexist4('opMlNVisible') && opMlNVisible > 1)
    if (isempty(opLog) || opMlLastLogIx ~= opMlCurrentIx || ...
	  (nargin > 1 && logNo))
      printf('%s:', opMultiLog('getname'));
      opMlLastLogIx = opMlCurrentIx;
    end
  end

case 'catall'
  ret1 = [];			% array: vertical concatenation of all logs
  ret2 = zeros(0,2);		% Nx2 array, with columns [log# entry#]
  for i = 1 : opMlNVisible
    ll = opMlLogs{i};
    ret1(end+1 : end+nRows(ll), 1:nCols(ll)) = ll;
    ret2(end+1 : end+nRows(ll), 1) = i;
    ret2(end-nRows(ll)+1 : end, 2) = (1 : nRows(ll)).';
  end

end	% switch
