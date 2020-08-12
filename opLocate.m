function opLocate(cmd)
% opLocate('showDialog')
%   Display the dialog box for setting the phone array. 
%
%   Static arrays are text files with lines like this:
%		x1 y1
%		x2 y2
%		x3 y3
%		 ...
%   where each line specifies the position of one phone.  Positions should be
%   in meters relative to an origin point of your choosing. The Earth is
%   assumed to be flat. Positions can also be 3-D (i.e., x1 y1 z1).
%
%   Arrays can also be dynamic, i.e., the phones are moving. Currently this is
%   configured for SPOT tag data -- csv files with fields of (1) date/time,
%   (2) tag ID number/name, (3) line type (has to be 'UNLIMITED-TRACK' for me
%   to pay any attention), (4) latitude, and (5) longitude. There can be
%   additional columns, which are ignored. Lat and long are converted to
%   meters.
%
% opLocate('locate')
%	Locate the position of the current selection.

%% These are for the dialog box (mostly callbacks):
% opLocate('initControls')	initialize controls in dialog box
% opLocate('loadStatic')	show file-picking dialog box, load phone array
% opLocate('loadDynamic')	show file-picking dialog box, load phone array
% opLocate('sosEntered')	check speed-of-sound entry for valid value
% opLocate('showMapChecked')	display map and hyperbolas
% opLocate('enableMapSize')	display map and  hyperbolas
% opLocate('showXCorrChecked')	display/undisplay cross-correlation function
% opLocate('mapSizeEntered')	change the size of the displayed map
% opLocate('closeButtonClick')	close the dialog box, set up loc measures
% opLocate('originChanged')	user edited the origin point; read new values
% opLocate('spotIdsChanged')	user entered/changed some SPOT ID strings

% Note: opLocArray is a structure with one element per phone that can represent
% a static or dynamic phone array. If it's dynamic (a moving array), then the
% position of a phone, call it phone N, is specified at a bunch of successive
% times: opLocArray(N).time(i) specifies a time (in datenum format), and
% opLocArray(N).pos(i,:) specifies an [x y] or [x y z] position. We linearly
% interpolate to figure out the correct position for a given time t. So
% opLocArray(N).time is a vector of length T, where T is the number of times
% you want to specify the position of your array, and opLocArray(N).pos is a
% Tx2 or Tx3 array.
%
% If opLocArray is static, then again it has one element per phone. For a given
% phone N, opLocArray(N).time is empty, and opLocArray(N).pos is a 1x2 or 1x3
% array with the position of this phone. This matches the format of opLocArray
% for a dynamic phone with the exception that opLocArray(N).time is empty.

%%
global opc opLocArrayFile opLocArray opLastLoc opLastLocError opLocDialog
global opLocOrigin opLocSpotIDs opLocSpotIDsChanged
global opSoundSpeed opSRate opShowLocMap opLocMapSize opLastDelay
global opLastArray opLastC opLastM opShowXCorr opChans showXCorrCheckbox
global opSelT0 opSelT1 opSelF0 opSelF1 opNSamp opDateTime

if (isempty(opSoundSpeed)), opSoundSpeed = 1500; end
if (isempty(opLocArrayFile)), opLocArrayFile = ''; end

% Give names to all the GUI objects for ease of programming.
if (~strcmp(cmd, 'showDialog') && ~isempty(opLocDialog) && ishandle(opLocDialog))
  optimWarnText        = findobj(opLocDialog, 'Tag', 'optimWarnText');
  staticArrayTable     = findobj(opLocDialog, 'Tag', 'staticArrayTable');
  staticArrayText      = findobj(opLocDialog, 'Tag', 'staticArrayText'); %#ok<NASGU>
  currentStaticArrText = findobj(opLocDialog, 'Tag', 'currentStaticArrText');
  sosEdit              = findobj(opLocDialog, 'Tag', 'sosEdit');
  showMapCheckbox      = findobj(opLocDialog, 'Tag', 'showMapCheckbox');
  showXCorrCheckbox    = findobj(opLocDialog, 'Tag', 'showXCorrCheckbox');
  mapSizeText          = findobj(opLocDialog, 'Tag', 'mapSizeText');
  mapSizeEdit          = findobj(opLocDialog, 'Tag', 'mapSizeEdit');
  dynamicArrayTitleText= findobj(opLocDialog, 'Tag', 'dynamicArrayTitleText');
  dynamicArrayText     = findobj(opLocDialog, 'Tag', 'dynamicArrayText');
  originText	       = findobj(opLocDialog, 'Tag', 'originText');
  originEdit	       = findobj(opLocDialog, 'Tag', 'originEdit');
  spotIdText	       = findobj(opLocDialog, 'Tag', 'spotIdText');
  spotIdEdit	       = findobj(opLocDialog, 'Tag', 'spotIdEdit');
end

% These are useful for making controls appear enabled/disabled.
black = [0 0 0]; gray = [0.5 0.5 0.5];

switch(cmd)
case 'showDialog'
  if (isempty(opLocDialog) || ~isvalid(opLocDialog))
    opLocSpotIDsChanged = false;
  end
  opLocDialog = opLocInfo;      % create (if needed) and display dialog box
  opLocate('initControls')
  
case 'initControls'
  % Set all of the controls in the dialog box to current values.
  set(optimWarnText, 'Visible', ...   %display warning about optim toolbox?
      iff(exist('lsqnonlin', 'file') == 2, 'off', 'on'));
  if (isempty(opLocArray))		% first time opening dialog box
    set(staticArrayTable, 'Data', []);
  elseif (isempty(opLocArray(1).time))	% static phone array?
    set(staticArrayTable, 'Data', opLocArray(1).pos);
  else					% dynamic phone array
    set(staticArrayTable, 'Data', []);
  end
  set(sosEdit, 'String', num2str(opSoundSpeed));
  set(showMapCheckbox, 'Value', opShowLocMap);
  set(showXCorrCheckbox, 'Value', opShowXCorr);
  set(mapSizeEdit, 'String', sprintf('%g ', opLocMapSize))
  set(originEdit, 'String', sprintf('%f  ', opLocOrigin))
  opLocate('enableMapSize')

case {'loadStatic' 'loadDynamic'}
  % Display file-picking dialog box for static array, check for 'Cancel'.
  %fspec = iff(isempty(opLocArrayFile), '*.txt|*.arr', opLocArrayFile);
  exts = {'*.txt;*.arr;*.csv;*.xls;*.xlsx'};
  defaultFile = opLocArrayFile;
  if (iscell(defaultFile)), defaultFile = defaultFile{1}; end
  [arrfile,arrpath] = uigetfile(exts, 'Choose array file', defaultFile, ...
      'MultiSelect', iff(strcmp(cmd, 'loadStatic'), 'off', 'on'));
  if (isnumeric(arrfile) && arrfile == 0), return; end	% Cancel      

  % Load array and check it; if okay, install it. Have to handle cases of a
  % static array file (just a list of phone positions) or dynamic array
  % file in SPOT tag format or multiple-file format in xls-readable files.
  if (iscell(arrfile))
    arrayfilename = cell(1,length(arrfile));
    for i = 1 : length(arrfile)
      arrayfilename{i} = [arrpath arrfile{i}];
    end
  else
    arrayfilename = [arrpath filesep arrfile];
  end
  if (strcmp(cmd, 'loadStatic'))
    set(currentStaticArrText,  'ForegroundColor', black);
    set(staticArrayTable,      'Enable', 'on');
    set(spotIdText,            'ForegroundColor', gray);
    set(spotIdEdit,            'Enable', 'off');
    set(originText,            'ForegroundColor', gray);
    set(originEdit,            'Enable', 'off');
    set(dynamicArrayTitleText, 'ForegroundColor', gray);
    set(dynamicArrayText,      'ForegroundColor', gray);
    arr = loadascii(arrayfilename);
    checkStaticArray(arr);			% bombs if arr is no good
    opLocArrayFile = arrayfilename;		% file is good; keep it
    set(staticArrayTable, 'Data', arr);		% put phone posns in dialog box
    set(dynamicArrayText, 'String', '(none)');
    % Put arr into opLocArray, making .time(:) empty to indicate static array.
    opLocArray = struct('time', [], 'pos', cell(1,nRows(arr)));
    for i = 1 : nRows(arr)
      opLocArray(i).pos = arr(i,:);
    end
  elseif (strcmp(cmd, 'loadDynamic'))
    if (iscell(arrayfilename))
      testfile = arrayfilename{1};
      set(spotIdEdit, 'Enable', 'off');
    else
      testfile = arrayfilename;
      set(spotIdEdit, 'Enable', 'on');
    end
    if (isempty(xlsfinfo(testfile)))
      error(['I can only handle dynamic array files in formats acceptable' 10 ...
        'to MS Excel. This includes .csv, .xls, and .xlsx.'])
    end
    if (iscell(arrfile))
      [opLocArray,opLocOrigin] = ...
        loadDynamicArrayXls(arrayfilename, opLocOrigin);
      set(currentStaticArrText,  'ForegroundColor', gray);
      set(staticArrayTable,      'Enable', 'off');
      set(spotIdText,            'ForegroundColor', gray);
      set(spotIdEdit,            'Enable', 'off');
      set(originText,            'ForegroundColor', black);
      set(originEdit,            'Enable', 'on');
      set(dynamicArrayTitleText, 'ForegroundColor', black);
      set(dynamicArrayText,      'ForegroundColor', black);
    else
      [opLocArray,opLocOrigin] = ...
        loadDynamicArraySpotID(arrayfilename, opLocOrigin, opLocSpotIDs);
      set(currentStaticArrText,  'ForegroundColor', gray);
      set(staticArrayTable,      'Enable', 'off');
      set(spotIdText,            'ForegroundColor', black);
      set(spotIdEdit,            'Enable', 'on');
      set(originText,            'ForegroundColor', black);
      set(originEdit,            'Enable', 'on');
      set(dynamicArrayTitleText, 'ForegroundColor', black);
      set(dynamicArrayText,      'ForegroundColor', black);
    end
    opLocArrayFile = arrayfilename;		% file is good; keep it
    txt = arrayfilename; 
    if (iscell(txt)), txt = sprintf('%s   and %d more', txt{1}, length(txt)-1); end
    set(dynamicArrayText, 'String', txt);
    set(staticArrayTable, 'Data', []);		% clear phone posns in dlog box
    set(originEdit, 'String', sprintf('%.6f  ', opLocOrigin));
    opLocSpotIDsChanged = false;
  end
  
case 'originChanged'
  x = sscanf(get(originEdit, 'String'), '%f');
  if (length(x) == 2 || length(x) == 3)
    opLocOrigin = x;
  end

case 'spotIdsChanged'
  x = strtrim(get(spotIdEdit, 'String'));  % strtrim removes lead/trail blanks
  if (ischar(x)), x = cellstr(x); end
  IDs = {};
  for i = 1 : length(x)
    strs = regexp(x{i}, '[ ,;\f\n\r\t\v]+', 'split');
    for j = 1 : length(strs)
      if (~isempty(strs{j}))	% 'noemptymatch' in regexp doesn't seem to work
	IDs = [IDs strs(j)];		%#ok<AGROW>
      end
    end
  end
  opLocSpotIDsChanged = ...
    (length(opLocSpotIDs) ~= length(IDs) || ~all(strcmp(opLocSpotIDs, IDs)));
  opLocSpotIDs = IDs;
    
case 'sosEntered'
  c = str2double(get(sosEdit, 'String'));
  if (~isnumeric(c) || isempty(c) || isnan(c) || c <= 0 || isinf(c))
    warndlg('The sound speed must be a positive real number.', ...
	'Bad sound speed');
    return
  end
  opSoundSpeed = c;

case {'showMapChecked' 'enableMapSize'}
  opShowLocMap = get(showMapCheckbox, 'Value');
  set([mapSizeText mapSizeEdit], 'Enable', iff(opShowLocMap, 'on', 'off'));
  opLocate('plotLastLocHyp');		% if there is an extant loc, plot it
  
case 'showXCorrChecked'
  opShowXCorr = get(showXCorrCheckbox, 'Value');
  
case 'mapSizeEntered'
  sz = str2num(['[' get(mapSizeEdit, 'String') ']']);		%#ok<ST2NM>
  if (~isnumeric(sz) || isempty(sz) || length(sz) > 2 || any(isnan(sz)) || ...
      any(sz <= 0) || any(isinf(sz)))
    warndlg('The map size must be 1 or 2 positive real numbers.', ...
	'Bad map size');
  end
  opLocMapSize = sz;
  opLocate('plotLastLocHyp');		% if there is an extant loc, plot it
  
case 'closeButtonClick'
  opMeasure('enableMeasure', 'x location');
  opMeasure('enableMeasure', 'y location');
  opMeasure('enableMeasure', 'z location', (nCols(opLocArray(1).pos) > 2));
  set(opLocDialog, 'Visible', 'off');			% make it disappear
  if (opLocSpotIDsChanged)
    opLocSpotIDsChanged = false;
    printf('Re-loading the dynamic array file because the set of SPOT IDs changed.')
    opLocArray = loadDynamicArraySpotID(opLocArrayFile, opLocOrigin, opLocSpotIDs);
  end

case 'locate'
  % Locate the selection, optionally display it on the map.
  if (~opSelect)
    uiwait(msgbox('You must have a selection to locate.', 'modal'))
    return
  end
  
% This used to check opUseDateTime, but that's just about how the axes are
% labeled....
%   arr = getArrayForTime(mean([opSelT0 opSelT1]) / secPerDay + ...
%     iff(opUseDateTime, opDateTime, 0));
  arr = getArrayForTime(mean([opSelT0 opSelT1]) / secPerDay + opDateTime);

  % Get the samples.
  s0 = max(round(opSelT0 * opSRate), 0);	% opSelT0/T1 is per-channel
  s1 = min(round(opSelT1 * opSRate), opNSamp);
  sDur = min(s1 - s0);     % use min since s1-s0 can have off-by-1 differences
  if (any(diff(s0)))
    % User has moved a selection box, so samples aren't all from the same times.
    % Get data channel-by-channel.
    x = zeros(sDur, length(opChans));
    for chIx = 1:length(opChans)
      ch = opChans(chIx);
      x(:,chIx) = opSoundIn(s0(ch), sDur, ch);
    end
  else
    % Start- & end-times are same in all channels.  Get all sound data at once.
    x = opSoundIn(s0(1), sDur, opChans);
  end

  if (0)
    % Use a subset of the channels.
    disp('opLocate: USING A SUBSET OF CHANNELS!')                %#ok<UNRCH>
    whichChan = [0 1 2] + 1;
    opLastArray = opLocArray(whichChan, :);
    whichX = x(:, whichChan);
  else
    if (nCols(x) ~= length(opChans))
      error('Your phone array and sound file are incompatible.\n%s\n%s\n%s', ...
	['Your array file has ' num2str(nRows(arr)) ' rows and ' ...
	'your sound has ' num2str(nCols(x)) ' channel(s).'], ...
	'These numbers should be the same. Do "Locate->Localization options"', ...
	'and choose an appropriate array file.')
    end
    opLastArray = arr(opChans,:);
    whichX = x;
  end
  
  % Get max time delay, then time delays, then use them in the location.
  [m1,m2] = allPairs(nRows(opLastArray));
  maxDelay = sqrt(sum((opLastArray(m1,:) - opLastArray(m2,:)).^2, 2)) / ...
      opSoundSpeed;
  freqs = [opSelF0(opc) opSelF1(opc)];
  if (0)
    [~,m1,m2,xc] = delayFromSound(whichX, opSRate, freqs, maxDelay, ...
      opShowXCorr, opSelT0(opChans)); %#ok<UNRCH>
    normxc = xc;
    delta = CalcCorrErrors([0;0],opLastArray.',m1,m2,normxc,opSRate,opSoundSpeed);
  end
  
  opLastDelay = delayFromSound(whichX, opSRate, freqs, maxDelay, opShowXCorr,...
    opSelT0(opChans));
  ix = ~isnan(opLastDelay);
  opLastDelay = opLastDelay(ix);
  m1 = m1(ix); m2 = m2(ix);
  [pos,~,~,err] = bestFit(m1, m2, opLastDelay, opLastArray',[],[],opSoundSpeed);
  opLastLoc = pos;
  opLastLocError = sqrt(norm(err));
  opLastM = [m1 m2];
  opLastC = opSoundSpeed;
  opMeasure('newsel', opc);		% display results on screen
  opLocate('plotLastLocHyp')
  
case 'plotLastLocHyp'			% plot hyperbolas from most recent loc
  fig = findobj(0, 'Tag', 'opLocMap');
  if (~opShowLocMap)
    if (~isempty(fig)), set(fig, 'Visible', 'off'); end
    return
  end
  if (isempty(opLastLoc)), return; end		% check for an existing loc
  %midpt = mean(reshape(minmax([opLastArray(:,1:2); opLastLoc(1:2).']), 2,2).');
  midpt = mean(reshape(minmax(opLastArray(:,1:2)), 2, 2).');
  lims = [(midpt(1) + opLocMapSize(1)   * [-0.5 0.5]) ...
          (midpt(2) + opLocMapSize(end) * [-0.5 0.5])];
  if (isempty(fig))
    fig = figure('Name', 'Location', 'Tag', 'opLocMap', 'NumberTitle', 'off'); 
  end
  figure(fig)
  PlotHyperbolas(opLastDelay, 0, opLastArray.', opLastM(:,1), opLastM(:,2), ...
    opLastC, lims);
  line(opLastLoc(1), opLastLoc(2), ...				% plot the loc
    'Color', 'r', 'Marker', '.', 'MarkerSize', 20)
  title(sprintf('Location: (%.1f, %.1f)   Loc error: %g', ...
    opLastLoc(1), opLastLoc(2), opLastLocError))
  xlabel('X, meters'); ylabel('Y, meters')
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkStaticArray(arr)
% Check that the data in arr is valid for a static array.
if (isempty(arr))
  errordlg('You must first specify an array with ''Locate->Localization options''.','Please specify array');
  error('Specify an array with ''Locate->Localization options''.');
elseif ((nCols(arr) ~= 2 && nCols(arr) ~= 3) || nRows(arr) < 2)
  error('\n%s\n%s\n%s\n%s\n', ...
      '!!! The array file should be a text file with 2 or 3 columns of', ...
      '!!! numbers. Each row specifies a phone position as (x,y) or (x,y,z).',...
      '!!! There should be as many rows as there are channels in your data.',...
      '!!! There also need to be at least 3 rows (3 channels).');
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function arr = getArrayForTime(tm)
% Given a time offset into the current file, find the corresponding phone
% positions. The array may be static (opLocArray(:).time is empty) or dynamic
% (opLocArray(:).time is non-empty).

global opLocArray	% struct with fields .time, .pos

arr = zeros(length(opLocArray), nCols(opLocArray(1).pos));
for i = 1 : nRows(arr)
  if (isempty(opLocArray(i).time))	% check for static phone array
    arr(i,:) = opLocArray(i).pos;	% pos might be 3 cols
  else
    % interp1('linear') doesn't extrapolate, so check for that here.
    if     (tm <= min(opLocArray( 1 ).time)), arr(i,:) = opLocArray( 1 ).pos(1,:);
    elseif (tm >= min(opLocArray(end).time)), arr(i,:) = opLocArray(end).pos(end,:);
    else
      arr(i,:) = interp1(opLocArray(i).time, opLocArray(i).pos, tm, ...
	'linear');			% pos might be 3 cols
    end
  end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [la,origin] = loadDynamicArrayXls(arrayfiles, origin)
% Load several files readable using xlsread (.xls, .csv, .txt, etc.). Each
% represents data for one phone, and should have the first three columns as
% [time latitude longitude]. The return value 'la' has as many elements as
% there are phones, and has fields of .time (an Nx1 vector in datenum
% encoding, where N is the number of lat/lons in that phone's data file)
% and .pos (an Nx2 array with [lat lon] in the columns).

% These specify the format of the Excel (or .csv) file by indicating what is in
% which column:
colDate = 1;    	% column number with the date/time
colLat  = 2;            % column number with the latitude
colLon  = 3;            % column number with the longitude
filenameIdPos = 1:2;    % position of phone identifier in the filename

if (nargin < 2), origin = []; end

la = struct('ID', {}, 'time', {}, 'pos', {});	% output arg
for fi = 1 : length(arrayfiles)
  % Load the data.
  [~,~,xlRaw] = xlsread(arrayfiles{fi});
  filepart = pathFile(arrayfiles{fi});
  ID = filepart(filenameIdPos);
  
  % Walk through the spreadsheet, collecting from rows with good data. If any
  % entries (namely time and lat/lon) are bad, leave ixGood false for that row.
  ixGood = false(nRows(xlRaw),1);
  tim    = zeros(nRows(xlRaw),1);
  lat    = zeros(nRows(xlRaw),1);
  lon    = zeros(nRows(xlRaw),1);
  for i = 1 : nRows(xlRaw)
    % Convert the date to datenum format, but if conversion fails, just
    % skip this line in xlRaw.
    try
      tim(i) = datenum(xlRaw{i, colDate});
      % Excel counts days from 1900-Jan-0, MATLAB from 0000-Jan-1. Fix.
      if (isnumeric(xlRaw{i, colDate}))
	tim(i) = tim(i) + datenum(1900,1,0) - 1;  % don't know why -1 is needed
      end
    catch ME
      if (strcmp(ME.identifier, 'MATLAB:datenum:ConvertDateString'))
        continue          % skip this row in Excel file, go on to next
      end
      rethrow(ME);
    end
    % Check the lat and lon. If either one fails, skip this line in xlRaw.
    lat(i) = xlRaw{i, colLat};
    lon(i) = xlRaw{i, colLon};
    if (~isnumeric(lat(i)) || ~isnumeric(lon(i)) || ...
        lat(i) < -90 || lat(i) > 90 || lon(i) < -360 || lon(i) > 360)
      continue
    end
    
    % This row in xlRaw looks good. Add it to the list of valid rows.
    ixGood(i) = true;
  end
  % Keep only the lines in the Excel file that were good.
  tim = tim(ixGood);
  lat = lat(ixGood);
  lon = lon(ixGood);
  
  % Add the data to la. 
  la(end+1).ID = ID;					%#ok<AGROW>
  la(end).time = tim;
  
  % Change lat/lon to meters away from origin, remove duplicate times.
  [la(end),origin] = preprocessPhone(la(end), lat, lon, origin);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [la,origin] = loadDynamicArraySpotID(arrayfile, origin, goodSpotIDs)
% Load a dynamic array and return it formatted for opLocArray. If origin is
% specified and non-empty, use it; otherwise, calculate it and return it.
% The return value 'la' has fields of .time, .pos (a 2-element vector),
% and .ID (a SPOT identifier).

% These specify the format of the Excel (or .csv) file by indicating what is in
% which column. Only some rows are used, as specified by colTest/strTest.
colID	= 2;			% column number with the phone ID
colDate	= 1;			% column number with the date/time code
colTest	= 3;			% column number with the string to test
strTest	= 'UNLIMITED-TRACK';	% test string; column colTest must match this 
				%    or else this row is ignored
colLat	= 4;			% column number with the latitude
colLon	= 5;			% column number with the longitude

if (nargin < 2), origin = []; end

% Load the data.
[~,~,xlRaw] = xlsread(arrayfile);
    
la = struct('ID', {}, 'time', {}, 'pos', {});
ixTest = strcmp(strTest, xlRaw(:,colTest));
for i = 1 : nRows(xlRaw)
  % Choose only rows with strTest in column colTest.
  if (~ixTest(i)), continue; end			% wrong type
  % Each phone has an ID, which is specified in column colID of xlRaw. If we've
  % already processed this ID, skip it.
  spotID = xlRaw(i,colID);
  if (any(strcmp(spotID, [la.ID]))), continue; end	% already did this ID
  % If user has specified SPOT IDs, then this one must match one of them.
  if (~isempty(goodSpotIDs) && ~any(strcmp(spotID, goodSpotIDs))), continue; end
  % New ID. Add it to the list of processed IDs, then process all rows in
  % xlRaw that have this ID.
  la(end+1).ID = spotID;				%#ok<AGROW>
  N = length(la);					% phone index
  ixID = strcmp(spotID, xlRaw(:,colID));		% indices w/this ID
  ix = find(ixID & ixTest);	% indices must both have right ID & pass test
  % Parse the date. 
  if (ischar(xlRaw{ix(1),colDate}))		% if string, use datenum on it
    la(N).time = datenum(xlRaw(ix,colDate));	% get dates for this ID
  elseif (isnumeric(xlRaw{ix(1),colDate}))	% if number, assume Excel format
    % Convert Excel datenum to MATLAB datenum. They use different reference
    % dates: Jan. 1, 1900 for Excel and Jan. 0, 0000 for MATLAB.
    la(N).time = xlRaw{ix,colDate} - datenum(1900,1,1) + datenum(0,1,0);
  end

  % Change lat/lon to meters away from origin, remove duplicate times.
  [la(N),origin] = preprocessPhone(la(N), ...
    [xlRaw{ix, colLat}], [xlRaw{ix, colLon}], origin);
end
printf('%d phone tracks loaded.', length(la))

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [laN,origin] = preprocessPhone(laN, lat, lon, origin)
% Given the spreadsheet, a list of relevant rows (ix) in it, and the time of
% each row (laN.time), order the points in ascending order, calculate the
% origin if needed, and get the positions in meters relative to the origin.

% Order the points (times, lats, and lons) in ascending time order, and
% remove duplicates to keep interp1 happy.
[laN.time,ixSort] = sort(laN.time);	% ascending order
dups = find(diff(laN.time) == 0) + 1;	% +1 removes 2nd one of each dup
laN.time(dups) = [];			% remove dups in time()...
lat = lat(ixSort); lat(dups) = [];	% ...in lat()
lon = lon(ixSort); lon(dups) = [];	% ...in lon()

% Calculate an origin from the position of the first phone. On later phones, 
% the input origin is already set, so the origin doesn't change.
if (isempty(origin))		% calc origin only if it doesn't exist yet
  % Find average position of first phone.
  origin = [median(lat) median(lon)];
  printf('Origin of coordinate system: [%.4f  %.4f]', origin(1), origin(2))
end

% Convert lat/lons to X-Ys (in meters).
laN.pos = latlong2meters(lat, lon, origin);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [m1,m2] = allPairs(n)
m1 = zeros(n*(n-1)/2,1);
m2 = zeros(n*(n-1)/2,1);
mi = 1;
for i = 1 : n
  for j = i+1 : n
    m1(mi) = i;
    m2(mi) = j;
    mi = mi + 1;
  end
end
