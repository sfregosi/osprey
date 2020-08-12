function [ret,ret2] = opMeasure(cmd, x0, x1)
%opMeasure	Osprey's measurement facility.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      To add a new measure, see osprey/measures/README.txt .
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% msmts = opMeasure('measure', t, f)
%     Given a two-column list of times 't' (i.e., start- and end-times) and a 
%     two-column list of frequencies 'f' (i.e., low and high frequencies),
%     calculate the current set of measurements for each t/f box and return it.
%     If f has only one row, use the same low/high frequencies for each
%     point in t.
%
% opMeasure('init')
%     Initialize.
%
% x = opMeasure('getone', chan, measurename)
%     Given the name of a measure, return its current value.
%     This is an external hook not otherwise used in Osprey.
%
% opMeasure('getlogcol', measurename [,'datalog'])
%     Determine which column of the current measurement set contains a given
%     named measure. Returns NaN for a bad name or one that's not currently in
%     the log. If the third argument 'datalog' is present, do this for the
%     datalog instead of the current measurement set; these are different if the
%     user has recently changed the set of measurements and hasn't added to the
%     datalog since then.
%
% opMeasure('enableMeasure', 'name', onP)
%     Enable (opP=1) or disable (onP=0) the named measure.  Default is onP=1.
%
% str = getname('getlogname', colnum [,'long'])
%     Given datalog column number(s) in colnum, return the column name(s)
%     as a cell vector of strings.  colnum has indices into opMeas.  As a
%     special case, if colnum is inf, return all current measures.  If the
%     'long' argument is present, return the longer name (iname) rather
%     than the default short one (sname).  From opDataLog and opPrefSave,
%     when they are writing to text files (log and prefs files, respectively).
%
% opMeasure('flip', n)
%     Flip measure #n from on to off or vice versa.
%
% opMeasure('painttext')
%     Display the names of the various measures at location opMeasurePos.
%
% opMeasure('newpt', chan, pt)
%     Display the values of the various measures for the given [t f] point.
%     From opMouseClick.
%
% vec = opMeasure('logpt', chan, pt);
%     Compute and return a line for the data log.  From opMouseClick via 
%     opDataLog.
%
% opMeasure('newsel', chan)
%     Display the values of the various measures for the current selection.
%
% opMeasure('setmeasures', measures, prefversion)
%     Use the given cell vector of measure names to set which ones are
%     enabled now.  Does not do any redisplay.
%
% ix = opMeasure('timeIndex')
%     Return the indices of the current set of measurements that are
%     time measures that are subject to opDateTime correction.
%
% [newLog,unmatched] = opMeasure('setNames', names, log)
%     Given a set of measurement names (a cell vector) and a corresponding
%     log array, match the known measurements with each item in names,
%     enable those measurements, and return the log with its columns in the
%     right order.  'unmatched' is the list of names that weren't found.
%
% opMeasure('sepMeasWin')
%     Toggle the flag for showing measurements in a separate window.

global opc opMeas opT0 opT1
global opNSamp opSRate opHopSize opZeroPad opDataSize opLog opOspreyDir
global opSelT0 opSelT1 opSelF0 opSelF1 opSepMeasWin
global opLastClick opUseDateTime opDateFix opLogPrev

switch(cmd)
case 'measure'            % measure a given set of points
  t = x0;
  f = repmat(x1, nRows(t) / max(nRows(x1),1), 1);
  n = size(t, 1);
  ret = zeros(n,0);
  for i = 1 : n
    opT0 = t(i,1);
    opT1 = t(i,2);
    opSelT0 = t(i,1);  opSelT1 = t(i,2);
    opSelF0 = f(i,1);  opSelF1 = f(i,2);
    opRefresh(1)
    m = opMeasure('logpt', opc, [0 0]);
    ret(i, 1:length(m)) = m;
  end
  
case 'init'
  oldmeas = [];
  if (~isempty(opMeas))
    oldmeas = {opMeas.enabled};		% save existing enabled-measure list
  end
  % Process each function in the 'measures' directory.
  fns = findsubfns(fullfile(opOspreyDir, 'measures'));% cell array of fn handles
  opMeas = struct; opMeas = opMeas([]);	% make 0-length struct array
  order = zeros(1,1);			% stop lint complaints
  for i = 1 : length(fns)
    % Get info from the measurement(s) and store it.
    y = feval(fns{i}, 'init');
    for j = 1 : length(y)
      z = y(j);
      n = length(opMeas) + 1;		   % next empty slot in opMeas
      opMeas(n).fn       = fns{i};	   % function object
      opMeas(n).iname    = z.longName;	   % internal name
      opMeas(n).sname    = z.screenName;   % user-visible name; should be short
      opMeas(n).unit     = z.unit;	   % unit name
      opMeas(n).needSel  = any(strcmp(z.type, {'selection' 'gramlet'}));
      opMeas(n).needGram = strcmp(z.type, 'gramlet');   % need a gramlet?
      opMeas(n).fixTime  = z.fixTime;	   % a time measurement?
      opMeas(n).pt       = strcmp(z.type, 'point');	% need a point?
      order(n)           = z.sortIndex;	   % for sorting onscreen values
      if (~isfield(z, 'enabled')), opMeas(n).enabled = false;
      else opMeas(n).enabled = logical(z.enabled);
      end
    end
  end
  [~,ix] = sort(order);		% sort by sortIndex
  opMeas = opMeas(ix);
  
  if (length(oldmeas) == length(opMeas))
    [opMeas.enabled] = deal(oldmeas{:});
  end

case 'getlogcol'
  % Determine which column of the current msmt set contains the given named
  % measure(s). Returns NaN for a bad measure name or one that's not currently
  % in the log. If x0 is a string, returns a scalar; otherwise x0 should be a
  % cell array of strings, and the return value is the same size as x0.
  % If x1 is present and is 'datalog', do same thing for current datalog msmts.
  if (ischar(x0)), x0 = {x0}; end	% ensure it's a cell array
  ret = nan(size(x0));			% default value
  x = iff(nargin >= 3 && (strcmp(x1, 'datalog')) && ~isempty(opLogPrev), ...
    opLogPrev, [opMeas.enabled]);
  for i = 1 : numel(x0)
    m = find(strcmp(x0{i}, {opMeas.sname}));	% find index of given name x0
    if (~isempty(m) && x(m(1)))		% matches an enabled measure name?
      ret(i) = sum(x(1 : m(1)));
    end
  end

case 'getlogname'
  colnum = x0;
  if (any(isinf(colnum))), colnum = find([opMeas.enabled]); end
  if (nargin >= 3 && strcmp(x1, 'long')), ret = {opMeas(colnum).iname};
  else                                    ret = {opMeas(colnum).sname};
  end

case 'dialogbox'
  % Show the dialog box for checking/unchecking measurements.
  % First create figure.
  h = findobj(get(0, 'Children'), 'flat', 'Tag', 'opMeasurePrefsFig');
  if (length(h) > 1), h = h(1); end
  if (isempty(h))
    h = figure('Tag', 'opMeasurePrefsFig', 'HandleVis', 'callback', ...
      'Name', 'Measurements', 'NumberTitle', 'off', 'Pos', [200 20 100 100]);
  else
    delete(get(h, 'Children'));
    figure(h);
  end
  
  % Parameters controlling positioning within window:
  cbSpace = 20;			% vertical spacing between adjacent checkboxes
  butHi = 30;			% vertical height of buttons
  fWid = 300;			% figure width
  names = char(opMeas.iname);
  iM = (names(:,1) == 'M' & isdigit(names(:,2)));  % is it an Acoustat measure?
  m = (sum(iM)+1) * cbSpace;	% total height of checkboxes

  % Resize window to fit all the stuff.
  set(h, 'Pos', [sub(get(h, 'Pos'), 1:2) fWid*2-20 m+butHi+40]); % resize it

  % Display most checkboxes -- Acoustat in right column, others in left.
  ypos = (m + butHi + 30 - cbSpace) * [1 1];
  for i = 1 : length(opMeas)
    uicontrol('Style', 'checkbox', 'String', names(i,:), ...
        'TooltipString', names(i,:), 'Value', opMeas(i).enabled, ...
	'Callback', ['opMeasure(''flip'', ' num2str(i) ')'], ...
	'Pos', [(iM(i)*(fWid-20) + 10) ypos(iM(i)+1) fWid-20 cbSpace]);
    ypos(iM(i)+1) = ypos(iM(i)+1) - cbSpace;
  end

  % Make checkbox for separate measurements window.
  uicontrol('Style', 'checkbox', 'FontWeight', 'bold', ...
      'String', 'Show measurements in a separate window', ...
      'Value', opSepMeasWin, 'Callback', 'opMeasure(''sepMeasWin'');', ...
      'Position', [80 butHi+20 fWid*2-160 cbSpace]);

  % Make close button.
  uicontrol('Style', 'pushb', 'Pos', [fWid-40 10 80 butHi], ...
      'String', 'Close', 'Callback', 'set(gcbf, ''Visible'', ''off'')');

case 'flip'			% turn a measure on or off
  measNum = x0;
  opMeas(measNum).enabled = ~opMeas(measNum).enabled;
  opMeasure('painttext');
  figure(findobj(get(0, 'Children'), 'flat', 'Tag', 'opMeasurePrefsFig'))
  
case 'painttext'		% display measures on screen
  opMeasure('newsel', opc);	% display the values

case {'newpt' 'newsel' 'logpt' 'getone'}
  chan = x0;
  if (any(strcmp(cmd, {'newpt' 'newsel'})))
    % Display enabled measurement names; this is usually, but not always,
    % redundant.
    %str = strvcat(iff(opSepMeasWin, {opMeas(x).iname}, {opMeas(x).sname}));
    str = char(opMeas(logical([opMeas.enabled])).sname);
    showMeas(str, true);		% true says str has measure names
  end
  
  sel = [];
  if (opSelect)
    sel = [opSelT0(chan) opSelF0(chan) opSelT1(chan) opSelF1(chan)].'; 
  end

  if (strcmp(cmd, 'logpt') || strcmp(cmd, 'newpt'))
    opLastClick = x1;
  end
  
  % Set up 'list' as a boolean vector of which measurements to get.
  % s (a scalar) says whether to do 'selection' measurements.
  if (strcmp(cmd, 'getone'))
    measname = x1;
    list = find(strcmp(measname, {opMeas.sname}));
    if (length(list) ~= 1), error(['Unknown measure name: ' measname]); end
    s = any([opMeas(list).needSel]) & ~isempty(sel);
  else
    list = [opMeas.enabled];
    s = (strcmp(cmd, 'logpt') | strcmp(cmd, 'newsel')) & ~isempty(sel);
  end
  
  % Fetch spect if necessary.
  if (s && any(list & [opMeas.needGram]))
    [spect,~,bx] = opGetSpect(chan, sel(1), sel(3), sel(2), sel(4), sel);
  end

  ret = zeros(1, sum(list ~= 0));
  lc = opLastClick;
  strs = cell(1, sum(list ~= 0));	% strings to display
  si = 0;				% strs index
  fftSize = opDataSize * (1 + opZeroPad);
  params = struct( ...
      'sRate',		opSRate, ...
      'totalSamples',	opNSamp, ...
      'frameSize',	opDataSize, ...
      'zeroPad',	opZeroPad, ...
      'FFTsize',	fftSize, ...
      'hopSize',	opHopSize, ...
      'frameRate',	opSRate / (opHopSize * opDataSize), ...
      'binBW',		opSRate / fftSize, ...
      'channel',	chan, ...
      'nlogs',		nRows(opLog), ...
      'winType',	opWinTypeF('name'));
  for i = find(list)		% i is measure number
    si = si + 1;
    v = [];

    plug = opMeas(i);			% 'plug-in' struct for this measure
    if (opMeas(i).needSel)		% need selection?
      if (s && opMeas(i).needGram)	% spect might be [] here
	v = feval(plug.fn, 'measure', plug.iname, lc, sel, bx, spect, params);
      elseif (s)
	v = feval(plug.fn, 'measure', plug.iname, lc, sel, [], [], params);
      end
    elseif ((plug.pt && ~isempty(lc)) || ~plug.pt)
      v = feval(plug.fn, 'measure', plug.iname, lc, [], [], [], params);
    end
    suf = plug.unit;

    if (strcmp(cmd, 'logpt') || strcmp(cmd, 'getone'))
      if (isempty(v)), v = NaN; end
      ret(si) = v;
    else
      % Figure out number format for v.
      if (~isempty(v))
	if (opMeas(i).fixTime && opUseDateTime)
	  v = mod(v + opDateFix, 24*60*60);
	  strs{si} = sprintf('%d:%02d:%05.2f', floor(v/60/60), ...
	      mod(floor(v/60), 60), mod(v, 60));
        elseif (v == round(v) && abs(v) < 100000)            % small integer
          strs{si} = sprintf('%d %s', v, suf);
        else
          y = floor(log10(abs(v)));
          if (-3<y && y<5), strs{si} = sprintf('%-6.*f %s', 4 - y, v, suf);
          else              strs{si} = sprintf('%-.5ge%d %s', v/10^y, y, suf);
          end
	end
      else
        % No v and it's a selection measure ==> erase the measure.
	strs{si} = ' ';
      end
    end		% if (strcmp(cmd, ...))
  end		% for i
  
  % Display strs.
  if (~strcmp(cmd, 'logpt') && ~strcmp(cmd, 'getone'))
%     % If sel exists, use old sel values rather than recomputing.
%     if (opSelect && ~s)
%       ix = strmatch('', strs, 'exact');
%       for k = 1 : length(ix)		% how to do this without a loop??
% 	strs(ix(k)) = opMeasStrSave{chan}(ix(k));
%       end
%     end
%     opMeasStrSave{chan} = strs;
    showMeas(strs, false);		% false says strs has measure values
  end

case 'setmeasures'
  measures = x0;
  version = x1;
  if (version <= 1), measures = [measures, 0]; end        % # datalogs
  if (version <= 3), measures = [measures, 0]; end        % channel #
  if (version <= 5), measures = [measures(1:16) 0 0 measures(17:18)]; end
  if (version <= 6), measures = [measures(1:13) 0 measures(14:20)]; end
  if (version > 7)
    error('Osprey internal error: Version number of prefs file is too large.');
  end

  if (version <= 6)
    % For legacy prefs files: Convert measure numbers to measure names.
    nm = {  'file length' 'sample rate'	'time'		 'frequency' ...
	    'amplitude'	'sample number' 'start time'	 'end time'  ...
	    'duration'	'low frequency'	'high frequency' 'bandwidth' ...
	    'energy'	'power'		'peak frequency' 'peak time' ...
	    'peak amplitude' 'centroid time' 'centroid frequency'    ...
	    'number of datalog entries' 'channel number' };
    measures = nm(measures);
  end

  % For each measure now present, check whether it's in 'measures'.
  for i = 1 : length(opMeas)
    opMeas(i).enabled = any(strcmp(opMeas(i).iname, measures)) || ...
      any(strcmp(opMeas(i).sname, measures));
  end
  %[opMeas.enabled] = deal(measures{:});

case 'timeIndex'
  ret = find([opMeas(logical([opMeas.enabled])).fixTime]);
  
case 'setNames'
  % Find 'names' in set of available measurements, and enable them.  Also
  % rearrange log into newLog with its columns in the right order.
  names = strtrim(x0);			% remove leading/trailing whitespace
  log = x1;
  newLog = zeros(size(log));		% accumulates reordered columns of log
  ci = 0;				% last column used yet in newLog
  used = zeros(1, length(names));	% which names have been found?
  for i = 1 : length(opMeas)
    % First try long name (iname), then short name (sname).
    pos = find(strcmp(opMeas(i).iname, names));
    if (isempty(pos)), pos = find(strcmp(opMeas(i).sname, names)); end
    opMeas(i).enabled = ~isempty(pos);
    if (opMeas(i).enabled)
      ci = ci + 1;
      newLog(:,ci) = log(:,pos(1));
      used(pos(1)) = 1;
    end
  end
  ret = newLog(:,1:ci);			% unused columns get trimmed off
  ret2 = names(~used);			% cell vector of unused names
  opMeasure('painttext');

case 'enableMeasure'
  if (nargin < 3), x1 = 1; end		% default is to turn it on
  measName = x0;
  onP = x1;
  pos = find(strcmp(measName, {opMeas.iname}));
  if (~isempty(pos))
    opMeas(pos).enabled = onP;
  end
  opMeasure('painttext');
  
case 'sepMeasWin'
  opSepMeasWin = ~opSepMeasWin;
  opRedraw;

otherwise
  error(['Osprey internal error: Unknown command: ', cmd]);

end		% switch


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fns = findsubfns(d)
% Find all the m-files in the directory d, and return them as a cell array of
% function objects.  This is tricky only because in order to make them usable
% function objects, that directory has to be on the path when str2func is
% called.

mfiles = dir(fullfile(d, '*.m'));
a = ~isempty(strfind([';' path ';'], [';' d ';']));	% already in path?

if (~a), addpath(d); end				% add if needed
fns = cell(0,1);
for i = 1 : length(mfiles)
  fns{i} = str2func(pathRoot(mfiles(i).name));
end
if (~a), rmpath(d); end					% remove if added
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showMeas(strs, isNames)
% Display either measure names (isNames=true) or measure values (isNames=false)
% in either the main window or opMeasFig, depending on opSepMeasFig.

global opFig opWindowAxes opMeasurePos
global opSepMeasWin	% boolean saying whether to use separate window
global opMeasFig	% the separate window, if any
global opMeasAxes	% the axis object holding the two text objects

fontsize = 8;                               % in points
prev = pushProp(opFig, 'HandleVisibility', 'on');   % push
tag = iff(isNames, 'opMeasureNames', 'opMeasureNums');

% Delete or hide any old measure texts present.
delete(findobj(0, 'Tag', tag));

% Make sure the separate measurement window is set up right.
present = (~isempty(opMeasFig) && any(get(0, 'Children') == opMeasFig));
if (opSepMeasWin)
  if (~present)
    opMeasFig = figure('IntegerHandle', 'off', 'Name', 'Measurements', ...
	'NumberTitle', 'off', 'Units', 'pixels', 'Tag', 'opMeasureFig', ...
        'Position', [50 50 200 500]);
    % Make background axes, and size it to be same size as window.
    p = get(opMeasFig, 'Pos');
    opMeasAxes = axes('Units', 'pix', 'Pos', [0 0 p(3:4)], 'Visible', 'off');
    set(opMeasFig, 'ResizeFcn', ['global opMeasAxes; ' ...
      'set(opMeasAxes, ''Pos'', [0 0 sub(get(gcf,''Pos''),3:4)]);'])
  end
  set(opMeasFig, 'Visible', 'on');
else
  if (present), set(opMeasFig, 'Visible', 'off'); end
end

% Display new text.
axes(iff(opSepMeasWin, opMeasAxes, opWindowAxes));
xoff = 0;
if (~isNames)
  % Set up values to be 3 pixels to right of names.
  xoff = sub(get(findobj('Tag', 'opMeasureNames'), 'Extent'), 3);
end
xy = iff(opSepMeasWin, [10 10], ...
  opMeasurePos(1:2));
t = text(xy(1) + xoff, xy(2), strs, 'Units', 'pixels', 'FontSize', fontsize,...
  'FontWeight', iff(opSepMeasWin, 'bold', 'normal'), 'Tag', tag, ...
  'VerticalAlign', iff(opSepMeasWin, 'bottom', 'top'));
if (opSepMeasWin)
  p = get(opMeasFig, 'Pos');
  hi = sub(get(t, 'Extent'), 4)+xy(2);
  ypos = iff(p(4)==hi, p(2), max(0, p(2)+p(4)-hi));
  set(opMeasFig, 'Pos', [p(1) ypos p(3) hi])
end

figure(opFig);		% gram gets displayed next
popProp(opFig, prev);
return
%#ok<*MAXES>

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is old code.

    opMeasureEnb{x0} = [0 0 1 1 1 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0]; %#ok<UNRCH>
    opMeasureSel     = [0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0];
    opMeasureGram    = [0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 0 0];
    opMeasureTime    = [0 0 1 0 0 0 1 1 0 0 0 0 0 0 0 1 0 1 0 0 0];

    amp = 20 / log(10);
    [nr,nc] = size(spect);
    if     i==1     , v = opNSamp / opSRate;            suf = 's'; % total len
    elseif i==2     , v = opSRate;                      suf = 'Hz';% samp. rate
    elseif i==3  & p, v = lc(1);                        suf = 's'; % time
    elseif i==4  & p, v = lc(2);                        suf = 'Hz';% frequency
    elseif i==5  & p,                                              % amplitude
      v = amp * opGetSpect(x0, lc(1),lc(1),lc(2),lc(2));suf = 'dB';
      if (~length(v)), v = 0; end
    elseif i==6  & p, v = round(lc(1)*opSRate);         suf = '';  % sample no.
    elseif i==7  & s, v = sel(1);                       suf = 's'; % start time
    elseif i==8  & s, v = sel(3);                       suf = 's'; % end time
    elseif i==9  & s, v = abs(sel(3)-sel(1));           suf = 's'; % duration
    elseif i==10 & s, v = sel(2);                       suf = 'Hz';% low freq
    elseif i==11 & s, v = sel(4);                       suf = 'Hz';% high freq
    elseif i==12 & s, v = abs(sel(4)-sel(2));           suf = 'Hz';% bandwidth
    elseif (i==13 | i==14) & s,                                 % energy, power
      d = iff(i==13, 1, nCols(spect));
      v = amp * log(sum(sum(exp(spect).^2)) / d * opHopSize / (1+opZeroPad));
      suf = 'dB';
    elseif i==15 & s,                                              % peak freq
      [dummy,v] = max(spect(:));
      v = (rem(v-1,nr)       + 0.5) / nr * (bx(4)-bx(2)) + bx(2); suf = 'Hz';
    elseif i==16 & s,                                              % peak time
      [dummy,v] = max(spect(:));
      v = (floor((v-1) / nr) + 0.5) / nc * (bx(3)-bx(1)) + bx(1); suf = 's';
    elseif i==17 & s, v = amp * max(max(spect));        suf = 'dB';% peak amp
    elseif i==18 & s,                                              % centr time
      n = nCols(spect);
      v = sum([zeros(1,n); exp(spect).^2]);             suf = 's';
      v = sum(v .* ((0.5:n) / n * (bx(3)-bx(1)) + bx(1))) / sum(v);
    elseif i==19 & s,                                              % centr freq
      n = nRows(spect);
      v = sum([zeros(n,1), exp(spect).^2]');            suf = 's';
      v = sum(v .* ((0.5:n) / n * (bx(4)-bx(2)) + bx(2))) / sum(v);
    elseif i==20, v = nRows(opLog);                     suf = '';  % # datalogs
    elseif i==21, v = opc;                              suf = '';  % channel #
    end
