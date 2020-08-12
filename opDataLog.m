function opDataLog(cmd, ch, pt)
% opDataLog('click', [ch, [xypoint]])
%	User did a Shift-LeftClick.  Log a point in the data log.  But first
%       have to check for the log format having changed; calls 'click!' upon
%	success.
%
% opDataLog('click!', ch, xypoint)
%	Really log a point
%
% opDataLog('show')
%	Print current contents of log in command window.
%
% opDataLog('showheader' [,filenum [,dateIndexes])
%	Print header for current contents in command window or, if filenum is
%	present, to a file. If dateIndexes is present, it indicates which
%	fields have time/dates in them.
%
% opDataLog('clear')
%	Check if okay to clear the data log, then clear it with 'clear!'.
%
% opDataLog('clear!')
%       Really clear the data log.
%
% opDataLog('callback')
%       Utility function for 'clear'.
%
% opDataLog('save', logNum)   or   opDataLog('saveASCII', logNum)
%	Open up a save dialog box for the data log.  If logNum is present, it
%       says the log number to display in save dialog box (see opMultiLog.m).
%
% opDataLog('switch' [,val [,displayp]])
%       Enable/disable the data log.  If the val argument is supplied, set
%       the enable value to that (1=on, 0=off).  If the displayp argument
%       is supplied, it says whether to display a message (default=1).
%
% opDataLog('truncate')
%       Remove a point from the end of the data log.
%
% opDataLog('next')
%	Go to the next point in the data log.
%
% opDataLog('prev')
%	Go to the previous point in the data log.
%
% opDataLog('pickLoadFile' or 'cancelLoad' or 'loadKeyPress')
%	These are callbacks from the load dialog box.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       If you change anything here, look at opMultiLog.m too.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global opc opLog opLogPrev opMeas
global opLogLoadDir opMlCurrentIx opMousePos opTextExt
global opLogChanged uiInputButton opUseDateTime opDateTime 
global opT0 opT1 opF0 opF1 opSelT0 opSelT1 opSelF0 opSelF1 opTMax opSRate
global opDataLogLastFile opDataLogSaveDir
global opLogIx			% for "next/prev log entry" movement

if (~gexist4('opLogIx')), opLogIx = inf; end

switch(cmd)
case 'clear!'
  opLog = [];
  opLogChanged = 0;
  opLogIx = inf;
  
case 'clear'
  if (opLogChanged)
    uiInput(char('Clear data log?', ...
      'Data log has unsaved data in it;', 'OK to clear?'), ...
      'OK|Cancel', 'opDataLog(''callback'')');
  else
    opDataLog('clear!');
  end
  
case 'callback'
  if (uiInputButton == 1)
    opDataLog('clear!');
  end

case 'click'					% shift-click: add to log
  if (~opSelect), 
    helpdlg({'To add to Osprey''s data log, first select an area using the'
	'left and right mouse buttons, then hold down shift and click again.'},...
	'Add to datalog');
    return
  end
  
  % These are used in the callback from the menu.
  if (nargin < 2), ch = opc; end
  if (nargin < 3), pt = opMousePos; end

  %hdr = (nRows(opLog) == 0);
  if (~gexist4('opLogPrev'))
    opLogPrev = [opMeas.enabled]; 
    opLog = [];
    %hdr = 1;
  end
  diffmeas = (length(opLogPrev) ~= length(opMeas)) || ...
    any(opLogPrev ~= [opMeas.enabled]);
  nc = ['opDataLog(''click!'', ' num2str(ch) ',[' sprintf('%.6f ', pt) '])'];
  if (opLogChanged && diffmeas)
    uiInput(char('Save data log?', ...
      'The set of measurements has changed and I must', ...
      'clear the data log.  Save it before clearing?'), ...
      'Save log|Don''t save log|Cancel', ...
      char(['opDataLog(''saveASCII''); opDataLog(''clear!'');' nc], ...
      ['opDataLog(''clear!'');' nc], ...
      '  '));
  else
    if (diffmeas), opDataLog('clear!'); end
    eval(nc);
  end

case 'click!'					% really do it
  opLogPrev = [opMeas.enabled];

  force = isempty(opLog);
  n = nRows(opLog) + 1;
  opLog(n, 1) = 0;				% fake a line to correct #logs
  line = opMeasure('logpt', ch, pt);		% log a point
  if (n > 1 && all(line == opLog(n-1, :)) && ...
      ~yesno(['That data log entry is the same as'; ...
      'the previous one; keep it anyway? ']))
    opLog(n, :) = [];
    return
  end
  opLog(n, 1:length(line)) = line;
  opLogChanged = 1;
  if (force)					% print datalog header?
    opDataLog('showheader')
  end
  opMultiLog('showlognum', force)		% shows only if different log
  printf('%15.4f\t', line);

  % Make log entry in temp file in case Matlab crashes.
  fd = fopen('OspreyBackupDatalog.txt', 'a');
  if (fd >= 0)					% is <0 if file is read-only
    fn = opFileName('getsound');
    if (~strcmp(opDataLogLastFile, fn) || ftell(fd) == 0)
      if (ftell(fd) > 50000)			% limit the file size
        fclose(fd);
        fd = fopen('OspreyBackupDatalog.txt', 'w');
      end
      if (ftell(fd) == 0), opDataLogLastFile = ''; end		% re-do header
      fprintf(fd, '\nStarting a new datalog for the file\n\t%s\n', fn);
      if (isempty(opDataLogLastFile))
        fprintf(fd, [...
          'It''s okay to delete this file; it''s here only as a backup in\n'...
          'case Matlab crashes.  To use it after losing data, remove all\n' ...
          'lines (including these header lines) except the data you want,\n'...
          're-save this file, restart Osprey on the file above, set up\n' ...
          'the same measurements, and do Datalog->Load.  This file is\n' ...
          'limited in size to about 50 KB.\n']);
      end
      fprintf(fd, '\n');
      opDataLogLastFile = fn;
    end
    fprintf(fd, '%15.3f\t', line);
    fprintf(fd, '\n');
    fclose(fd);
  end

case {'save' 'saveASCII'}
  isText = strcmp(cmd, 'saveASCII');
  datalog = opLog;
  % First fix log entries that have times to include time/date that file
  % starts.  If opDateTime is 0, it means the sound file didn't provide a time 
  % stamp, and we should just save seconds.
  dateIxs = [];			% columns to show as dates
  if (opUseDateTime && (opDateTime ~= 0))
    dateIxs = opMeasure('timeIndex');
  end
  
  if (nargin < 2), ch = ''; end		% so it's not undefined
  if (isempty(opTextExt)), opTextExt = 'txt'; end
  ext = iff(isText, opTextExt, 'mat');
  dir = iff(isempty(opDataLogSaveDir), pathDir(opFileName), opDataLogSaveDir);
  initfile = fullfile(dir, [stripAudioExt(pathFile(opFileName('getsound'))) ...
    iff(nargin>=2, ['.' ch], '') '.' ext]);
  opPointer('watch');
  str = ['Save data log ' iff(isText, 'as text', '(.mat format)') ...
    iff(nargin>=2, [': ' ch], '')]; % for saving multiple logs; ch is log name
  [f,d] = uiputfile({['*.' ext];'*.txt';'*.log';'*.box'}, str, initfile);
  opPointer('crosshair');
  if ((~ischar(f)) || any(size(f) == 0)), return; end		% Cancel

  if (isText), opTextExt = pathExt(f); end
  fname = fullfile(d,f);
  opDataLogSaveDir = d;
  if (~isText)
    datalog(:,dateIxs) = datalog(:,dateIxs) / secPerDay + opDateTime;%#ok<NASGU>
    datacolumns = opMeasure('getlogname', find(opLogPrev), 'long'); %#ok<NASGU>
    save(fname, 'datalog', 'datacolumns', '-mat', '-v6');
  else
    % Write a text log file.
    fd = fopen(fname, 'wt+');
    if (fd < 0)
      error(['Unable to open file ' fname ' for writing.']);
    end
    fprintf(fd, '%%');		% so Osprey or Matlab can easily load it later
    opDataLog('showheader', fd, dateIxs);
    for i = 1 : nRows(datalog)
      for j = 1 : nCols(datalog)
	if (any(j == dateIxs))
	  tj = datalog(i,j) / secPerDay + opDateTime;
	  fprintf(fd, '%s\t', datestr(tj, 'yyyy-mm-dd HH:MM:SS.FFF'));
	else
	  fprintf(fd, '%15.5f\t', datalog(i,j));
	end
      end
      fprintf(fd, '\n');
    end
    fclose(fd);
  end
  opLogChanged = 0;

case 'show'
  % Print current contents of log in command window.
  opMultiLog('showlognum', 1);
  opDataLog('showheader');
  for i = 1 : nRows(opLog)
    printf('%15.4f\t', opLog(i,:));
  end

case 'showheader'
  % Print header for current contents in command window.  Optional 'ch' is
  % file number to print to (used by saveASCII) instead of command window.
  if (nargin < 2), fnum = 1; else fnum = ch; end
  if (nargin < 3), dateIxs = []; else dateIxs = pt; end
  % If user is doing programemd re-measurement and hasn't manually made a
  % measure yet, opLogPrev is empty. Use opMeas.enabled in that case.
  if (~isempty(opLogPrev)), measP = opLogPrev;
  else measP = [opMeas.enabled];
  end
  x = opMeasure('getlogname', find(measP));
  for i = 1 : length(x)
    fprintf(fnum, iff(any(i == dateIxs), '%19s\t', '%14s\t'), deblank(x{i}));
  end
  fprintf(fnum, '\n');

case 'truncate'
  if (nRows(opLog) > 0)
    opLog(nRows(opLog),:) = [];
    printf('---------- Removed one datalog item ----------')
  end

case {'next' 'prev' 'nextAny' 'prevAny'}		% go to next/prev item
  isany  = (strcmp(cmd, 'nextAny') | strcmp(cmd, 'prevAny'));
  isnext = (strcmp(cmd, 'next')    | strcmp(cmd, 'nextAny'));
  if (isempty(opLog)), return; end			% error check
  
  [c0,c1,cD] = getcols(opLogPrev, 'start time', 'end time', 'duration');
  if (isempty(c0) + isempty(c1) + isempty(cD) > 1)
    warndlg({'To use "next" and "previous", you must have'
	'the measurements "start time" and "end time" enabled'
	'(or either one of these plus "duration").  See the'
	'menu item Preferences->Measurements.'}, 'Oops', 'modal');  
    return
  end

  if (~opSelect)
    % No selection.  Use previously shown log entry.  opLogIx might be inf.
    opLogIx = opLogIx + iff(isnext, 1, -1);
    opLogIx = max(1, min(nRows(opLog), opLogIx));
  else
    % Get cols to compare.
    if (c0 == 0),     colIx = [c1 cD]; value = [opSelT1 opSelT1-opSelT0];
    elseif (c1 == 0), colIx = [c0 cD]; value = [opSelT0 opSelT1-opSelT0];
    else              colIx = [c0 c1]; value = [opSelT0 opSelT1];
    end
    curIx = iff(isempty(opMlCurrentIx), 1, opMlCurrentIx);
    if (isany)
      [e,eIx] = opMultiLog('catall');
      e = e(:, colIx(1));
    else
      % See if current selection exists in log.
      r = find(all(opLog(:,colIx) == ones(nRows(opLog),1) * value, 2));% match?
      e = opLog(:,colIx(1));
      eIx = [curIx*ones(length(e),1)  (1:length(e)).'];
    end
    if (~isany && ~isempty(r))
      % Current selection IS a datalog entry.  Just find the next/previous.
      if (any(opLogIx == r)), r = opLogIx; end	     % handle duplicate entries
      opLogIx = iff(isnext, max(r) + 1, min(r) - 1);
      opLogIx = max(1, min(nRows(opLog), opLogIx));
    else
      % Current selection is not a log entry.  Find nearest entry to selection.
      if (isnext)			% next entry after selection
	e(e <= value(1)) = inf;
	[mn,ix] = min(e - value(1));
	if (isinf(mn)), ix = length(e); end
      else					% previous entry before sel
	e(e >= value(1)) = -inf;
	[mx,ix] = min(value(1) - e);
	if (isinf(mx)), ix = 1; end
      end
      if (eIx(ix,1) ~= curIx)
	opMultiLog('click', eIx(ix,1));	% switch logs
      end
      opLogIx = eIx(ix,2);
    end    
  end

  % Adjust screen time bounds to show the new selection.
  [t0,t1] = getval(c0, c1, cD, opLog(opLogIx, :));
  [opT0,opT1,opSelT0,opSelT1] = adjust(opT0, opT1, t0, t1, 0, opTMax);
      
  % Ditto for freq bounds, if possible.
  [c0,c1,cD] = getcols(opLogPrev,'low frequency','high frequency','bandwidth');
  if (~isempty(c0))
    [f0,f1] = getval(c0, c1, cD, opLog(opLogIx, :));
  else
    % No freq bounds in log.  Use selection if any, else what's on screen now.
    if (opSelect), f0 = opSelF0; f1 = opSelF1;
    else           f0 = opF0;    f1 = opF1;
    end
  end
  [opF0,opF1,opSelF0,opSelF1] = adjust(opF0, opF1, f0, f1, 0, opSRate/2);

  opMeasure('newsel', opc);
  opRefresh;

%%%%%%%%%%%%%%%%%%%%%%%%% loading log files %%%%%%%%%%%%%%%%%%%%%%%%%
case 'load'
  %opLoadLogFig
  h = opDataLogLoad;
  ph = get(h, 'Pos');
  set(h, 'Units','pix','Pos',[sub((get(0,'ScreenSize') - ph)/2,3:4) ph(3:4)]);

case 'loadRadioClick'
  % Button was clicked.  Turn off the other button.
  [~,textBut,matBut] = getObjects;
  set(gcbo, 'Value', 1);
  set(iff(gcbo == textBut, matBut, textBut), 'Value', 0);

case {'pickLoadFile' 'cancelLoad' 'loadKeyPress'}   % callbacks from dialog box
  [dbox,textBut,~,nameEdit,colsEdit] = getObjects;
  if (strcmp(cmd, 'loadKeyPress'))
    chr = get(dbox, 'CurrentCharacter') + 0;
    if (length(chr) ~= 1 || ~strcmp(get(dbox, 'SelectionType'), 'normal'))
      return
    elseif (any(chr == [10 13])), cmd = 'pickLoadFile';		% return
    elseif (chr == 27),           cmd = 'cancelLoad';		% escape
    else   
      return
    end
  end

  % Retrieve data from dialog box, then remove box from screen.
  if (strcmp(cmd, 'pickLoadFile'))
    isText = logical(get(textBut,   'Value'));
    vname  = deblank(get(nameEdit, 'String'));
    cname  = deblank(get(colsEdit, 'String'));
    while (~isempty(vname) && isspace(vname(1))), vname = vname(2:end); end
    while (~isempty(cname) && isspace(cname(1))), cname = cname(2:end); end
  end
  set(dbox, 'Visible', 'off');			% make it disappear
  drawnow
  if (strcmp(cmd, 'cancelLoad')), return; end
  
  % Get file name.
  p = iff(gexist4('opLogLoadDir'), opLogLoadDir, pathDir(opFileName));
  [f,p] = uigetfile1(fullfile(p, iff(isText, '*.log;*.txt;*.box','*.mat')), ...
      ['Load ' iff(isText, 'text', 'MATLAB') ' log file']);
  if (isnumeric(f)), return; end		% Cancel
  opLogLoadDir = p;
  
  fname = fullfile(p, f);
  if (isText)
    %% Load a text log.
    [v,nm] = loadTextLog(fname);		% loadTextLog is defined below
    if (isempty(nm))
      % No column names in log.  Try using currently active set of measurements.
      nHave = sum([opMeas.enabled]);
      if (nCols(v) ~= nHave)
	error(['There are no measurement names in the file, so I am\n' ...
	  'trying to match the current set of measurement names to what\n' ...
	  'is in the file. But the number of columns in the file (%d)\n' ...
	  'does not match the number of measurements you currently have\n' ...
	  'enabled (%d).  Use "Preferences->Measurements" to enable or\n' ...
	  'disable measurements so that they match what is in the file,\n' ...
	  'and try again.'], nCols(v), nHave);
      end
      nm = opMeasure('getlogname', inf);
    end
  else
    %% Load a MATLAB log.
    s = load('-mat', fname);
    if (~isfield(s, vname))
      error('The data log variable %s is not present in file %s.',vname,fname); 
    elseif (~isfield(s, cname))
      error('The data columns variable %s is not present in file %s.', ...
	cname, fname);
    end
    v = s.(vname);			% measurement values (array)
    nm = s.(cname); nm = nm(:).';	% measurement names (cell vector)
  end
  
  %% Process data.
  % Process the read-in data to make it into a data log.  Have to match the
  % read-in measurement names to the set of known names.
  if (~isnumeric(v))
    error('The data array %s in %s is not a numeric array.', vname, fname);
  elseif (nCols(v) ~= length(nm) && ~isempty(v))
    error(['The data array %s has a different number of columns than ' ...
      'the length of the variable list %s in %s.'], vname, cname, fname);
  end
  % At last!  Set the log.
  [v1,leftovers] = opMeasure('setNames', nm, v);  % v1 might be smaller than v
  
  % Fix columns with date numbers to have seconds since file start.
  dateIxs = opMeasure('timeIndex');
  dlims = [datenum('1-Jan-1500') datenum('1-Jan-2500')];
  fixIx = all(v1(:,dateIxs) >= dlims(1) & v1(:,dateIxs) < dlims(2));
  v1(:,dateIxs(fixIx)) = (v1(:,dateIxs(fixIx)) - opDateTime) * secPerDay;
  
  opLog = v1;
  if (nRows(opLog) > 0), opLogPrev = [opMeas.enabled]; end
  printf('Loaded %d log entries, each with %d measurements, from %s .', ...
    nRows(opLog), nCols(opLog), fname);
  if (~isempty(leftovers))
    warndlg({['These measurement(s) were mentioned in "' vname '", but '] ...
      'I do not have any measurements with these names:' ...
      '' ...
      leftovers{:} ...
      '' ...
      'These measurements will be ignored.'}.', ...
      'Bad measurement names')					     %#ok<CCAT>
  end
  

  %% End loading log files.

otherwise
  error(['Osprey internal error: Unknown command ''', cmd, '''.']);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dbox,textBut,matBut,nameEdit,colsEdit] = getObjects
dbox     = findobj(get(0, 'Children'), 'flat', 'Tag', 'opDataLogLoadDialog');
textBut  = findobj(dbox, 'Tag', 'textRadioButton');
matBut   = findobj(dbox, 'Tag', 'matRadioButton');
nameEdit = findobj(dbox, 'Tag', 'datalogNameEdit');
colsEdit = findobj(dbox, 'Tag', 'datacolumnsNameEdit');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [c0,c1,cD] = getcols(enb, name0, name1, nameD)
%  Given the names of start-time (name0), end-time (name1), and
%  duration (nameD) measurements, and the set of enabled measurements
%  (enb) in the log, check whether at least two are enabled and return
%  [] if not.  If so, calculate their columns in the current log.  Any
%  columns not currently enabled are returned as column 0.  enb is the
%  set of enabled measures as a logical vector.

global opMeas

i0 = find(strcmp(name0, {opMeas.iname}));	% start time / low freq
i1 = find(strcmp(name1, {opMeas.iname}));	% end time   / high freq
iD = find(strcmp(nameD, {opMeas.iname}));	% duration   / bandwidth

c0 = []; c1 = []; cD = [];
if (enb(i0) + enb(i1) + enb(iD) < 2), return; end

c0 = iff(enb(i0), sum(enb(1:i0)), 0);	% column in log of start time / low f
c1 = iff(enb(i1), sum(enb(1:i1)), 0);	% column in log of end time   / high f
cD = iff(enb(iD), sum(enb(1:iD)), 0);	% column in log of duration   / bandwid


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x0,x1] = getval(c0, c1, cD, log)
%  Given columns in the data log, calculate the start (x0) and end (x1)
%  times.  log is a single line of the data log.
%
%  Also works for the analogous frequency measurements.

if (c0 == 0)				% have end and duration
  x0 = log(1,c1) - log(1,cD);
  x1 = log(1,c1);
elseif (c1 == 0)			% have start and duration
  x0 = log(1,c0);
  x1 = log(1,c0) + log(1,cD);
else					% have start and end (and maybe dur.)
  x0 = log(1,c0);
  x1 = log(1,c1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [t0,t1,s0,s1] = adjust(T0,T1,S0,S1,mn,mx)
% Given current screen bounds T0 and T1 and new selection bounds S0 and S1,
% adjust both so that the selection is visible.  First check to see if S0..S1
% is already on-screen; if not, if it can be made on-screen without changing
% the span (T1-T0); if not, change the span.  Results are checked against
% overall bounds mn and mx.

% Set defaults.
t0 = T0;
t1 = T1;
s0 = max(mn, min(mx, S0));
s1 = max(mn, min(mx, S1));

if (s0 >= T0 && s1 <= T1)	
  % Already on screen; do nothing except check bounds, below.
else
  % Not on-screen, but small enough to fit.
  if (s1 - s0 <= T1 - T0), wid = T1 - T0;	% small enough to fit
  else wid = (s1 - s0) * 2;		% too big to fit; use twice sel width
  end
  t0 = (s0 + s1)/2 - wid/2;
  t1 = t0 + wid;
end

% Check against global bounds mn and mx.  Try to keep same span.
if (t0 < mn)
  t1 = t1 + (mn - t0);
  t0 = mn;
end
if (t1 > mx)
  t0 = max(mn, t0 - (t1 - mx));
  t1 = mx;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [v,nm] = loadTextLog(fname)
% Load a text log that has tab- or comma-delimited values.  This is complicated
% because of date strings in the log. Returns v (the array of log values, with
% date encoded as in datenum) and nm (the names of the measurements in v).

fd = fopen(fname, 'r');
if (fd < 0)
  error('Can''t open file %v for reading.', fname)
end
v = [];
n = 0;
lnN = 0;
nm = {};
while (1)
  lnN = lnN + 1;
  ln = fgetl(fd);
  if (isnumeric(ln))                   % EOF?
    fclose(fd); 
    return
  end
  %% Parse the line. First look for header line; if not, get data from it.
  ln = strtrim(ln);
  % Is this a header line? Must be before first data line (n==0) with at least
  % half of the alphanumeric characters being non-digits (regexp \D).
  anum = ln(regexp(ln, '\w'));	% \w means alphanumeric characters
  isHeader = (n==0) && (length(regexp(anum, '\D')) >= length(anum)/2);
  % If header line, remove %; if not, remove % and everything after it.
  if (isHeader)
    if (~isempty(ln) && ln(1) == '%'), ln = ln(2:end); end
  else
    ln(find([ln '%'] == '%', 1) : end) = [];
  end
  ln = strtrim(ln);
  % Figure out if it's tab-, comma-, or space-delimited.
  if     (any(ln == 9)),   strs   = strtrim(regexp(ln, '\t', 'split')); % 9=tab
  elseif (any(ln == ',')), strs   = strtrim(regexp(ln, ',',  'split'));
  else                     strs   = strtrim(regexp(ln, ' ',  'split'));
  end
  % Remove empty elements.
  c = mapcar(@isempty, strs);
  strs = strs(~[c{:}]);
  % Get measurement names if present. \D in regexp means a non-digit character.
  if (length(strs) >= 1 && (isHeader || strs{1}(1) == '%'))	% msmt names?
    nm = [{strtrim(strs{1}((strs{1}(1) == '%')+1 : end))} strs(2:end)];
    continue
  end
  n1 = n+1;
  for i = 1 : length(strs)
    if (any(strs{i} == ':'))
      v(n1,i) = datenum(strs{i});                                   %#ok<AGROW>
      n = n1;                     % increment n only if ln is non-empty
    else
      v(n1,i) = str2double(strs{i});                                %#ok<AGROW>
      if (isnan(v(n1,i)))
	fclose(fd);
	error('Unknown number format, line %d of file %v. Here is the line:\n%s', ...
	  lnN, fname, strs{i});
      end
      n = n1;		% increment n only if ln is non-empty
    end
  end
end
