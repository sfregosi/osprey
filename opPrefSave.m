function opPrefSave(cmd, x0, x1);
% opPrefs('save')
%    Put up a dialog box for saving preferences.  When done, call 
%    with 'save-file'.
%
% opPrefs('save-file', okay)
%    Read the check-boxes from the dialog box.  Get a file name to save
%    the preferences in, and save them.
%
% opPrefs('load')
%    Ask the user for a file to load, call load-file.
%
% opPrefs('load-file', filename)
%    Internal callback: Load preferences from the specified file.
%    Users can also use this programmatically.
%
% opPrefs('click', okay)
%    Process a user click.  This is necessary only for interaction between
%    window size, start/end time/freq, and window time/freq scaling.

% Version history (note that these version numbers are different from Osprey
% version numbers in osprey.m):
%    1	 9/14/94  first version created
%    2	10/??/94  opMeas changed (added #datalogs and maybe more)
%    3	11/10/94  datasize_ changed from samples to seconds
%    4	11/17/94  added channel number to opMeas
%    5	12/13/94  added centroid time, centroid freq
%    6	?
%    7  10/13/04  made measurement names be textual, not numeric

global opBrightness opContrast opDataSize opF0 opF1 opFig
global opHScrollSkip opHopSize opSepMeasWin
global opPsButton opPsName opPsValue opPsWin opPsWinPos opPsType
global opSRate opT0 opT1 opTMax opVScrollSkip opWinType opZeroPad
global opPrefDir opPrefAutoFile opColorMapName opDataSizePopup
global opUseDateTime opDateTime opDateFix
global opPrintLabel opPrintPortrait opPrintPos opLogFreq

version = 7;	% FIX opMeasure('setmeasures') WHEN THIS IS CHANGED!!!!!!!!!!!!

if (~gexist4('opPsName'))
  opPsName = char(...
      '-Window information',...
      'sound file name',...
      'window size/position',...		% type 1; see 'click'
      'window start/end time', ...		% type 2
      'time scaling (sec/cm)',...		% type 3
      'window low/high frequency',...		% type 4
      'frequency scaling (Hz/cm)',...		% type 5
      '-Spectrogram computation',...
      'frame size, hop size, etc.',...
      '-Display information',...
      'brightness and contrast',...
      'measurements',...
      'number/names of logs',...
      'h/v slider scroll amount',...
      'color map' );
  opPsValue = [0 1 0 1 1 0 1 0 1 0 0 0];	% initially checked?
  opPsType  = [0 1 2 3 4 5 0 0 0 0 0 0];	% see above; also 'click'
  opPsWin = [];
  opPsWinPos = [];
end

if (strcmp(cmd, 'save'))
  color = [1 1 1] * 0.702;		% about 3/4 grey

  % remove any existing Prefs window
  if (~isempty(opPsWin)), if (any(get(0, 'Children') == opPsWin)),
    delete(opPsWin); 
  end; end
  
  x1 = 0.2;				% left margin: "Choose Preferences..."
  x2 = 0.3;				% left margin: section titles
  x3 = 0.5;				% left margin: checkboxes
  high = 0.25;				% inter-checkbox vertical increment
  if (isempty(opPsWinPos))
    set(0, 'Units', 'inches');
    p = get(0, 'ScreenSize');
    w = 3.3;
    h = nRows(opPsName) * (high + 0.2) - length(opPsValue) * 0.1 + 1.2;
    opPsWinPos = [(p(3)-w)/2 (p(4)-h)/2 w h];
  end
  opPsWin = figure('Units', 'inch', 'Pos', opPsWinPos, 'Color', color,...
      'Resize', 'off', 'NumberTitle', 'off', 'Name', 'Save Preferences');
  if (matlabver >= 5), set(opPsWin, 'MenuBar', 'none'); end
  fpos = get(opPsWin, 'Pos');
  y    = fpos(4) - 0.4;
  wide = fpos(3) - x3 - x2;
  opPsButton = [];
  j = 0;
  axes('Units','inches','Pos', [0 0 fpos(3:4)], 'Visible', 'off');
  text(x1, y, 'Choose preferences to save:', 'FontWeight', 'bold', ...
      'Color', [0 0 0], 'FontSize', 14, 'Units', 'inches', 'Pos', [x1 y]);
  y = y - 0.35;
  for i = 1:nRows(opPsName)
    if (opPsName(i,1) == '-')
      text(x2, y, opPsName(i,2:nCols(opPsName)), 'FontWeight', 'bold', ...
	  'Color', [0 0 0], 'Units', 'inches', 'Pos', [x2 y]);
      y = y - high - 0.2;
    else
      j = j + 1;
      opPsButton(j) = uicontrol('Style','checkbox', 'String', opPsName(i,:),...
	  'Units', 'inches', 'Pos', [x3 y wide high],...
	  'Value',opPsValue(j), 'Background', color, 'Horiz', 'left', ...
	  'Callback', 'opPrefSave(''click'');');		    %#ok<AGROW>
      y = y - high - 0.1;
    end
  end
  y = y - 0.2;
  uicontrol('Style', 'pushb', 'String', 'OK...',     'Units', 'inches', ...
      'Pos', [x3      y 1 0.3], 'Callback', 'opPrefSave(''save-file'', 1)');
  uicontrol('Style', 'pushb', 'String', 'Cancel', 'Units', 'inches',...
      'Pos', [x3+1.25 y 1 0.3], 'Callback', 'opPrefSave(''save-file'', 0)');

elseif (strcmp(cmd, 'click'))
  % User clicked a button; see if we need to un-click any other buttons.
  % This is for handling window size/duration/scaling interactions.
  winsize   = opPsButton(find(opPsType == 1));
  startend  = opPsButton(find(opPsType == 2));
  timescale = opPsButton(find(opPsType == 3));
  lowhigh   = opPsButton(find(opPsType == 4));
  freqscale = opPsButton(find(opPsType == 5));

  o = gcbo;				% handle of button that was clicked
  if (get(winsize, 'Value') && get(startend,'Value') && get(timescale,'Value'))
    if (o == startend)
      set(timescale, 'Value', 0);
    else
      set(startend, 'Value', 0);
    end
  end
  if (get(winsize, 'Value') && get(lowhigh, 'Value') && get(freqscale,'Value'))
    if (o == lowhigh)
      set(freqscale, 'Value', 0);
    else
      set(lowhigh, 'Value', 0);
    end
  end

elseif (strcmp(cmd, 'save-file'))		% callback from dialog box
  opPsWinPos = get(opPsWin, 'Position');
  okay = x0;
  if (okay)					
    for i = 1:length(opPsButton)
      opPsValue(i) = get(opPsButton(i), 'Value');
    end
  end
  delete(opPsWin);
  opPsWin = [];
  if (~okay), return; end
  set(0, 'Units', 'pixels');
  opPointer('watch');
  if (~gexist4('opPrefDir')), opPrefDir = pathDir(opFileName); end
  [f,d] = uiputfile1([opPrefDir filesep '*.opref'],'Save preferences as...');
  opPointer('crosshair');
  if (~ischar(f)), return; end			% user picked Cancel
  opPrefDir = d;
  if (~strcmp(pathExt(f), 'opref')), f = [f '.opref']; end
  
  filename = [d,f];
  [fd,msg] = fopen(filename, 'wt+');
  if (fd < 0)
    error('Osprey: Can''t open file ''%s'', %s \n     ''%s''', ...
       filename, 'error message was', msg);
  end

  % write header
  d = clock;
  fprintf(fd, '%% Osprey preferences file, created %s %g:%02g:%02g.\n\n', ...
      date, d(4), d(5), floor(d(6)));
  fprintf(fd, 'prefversion_ = %g;\n', version);

  v = opPsValue;
  %ch = opc;
  n = 0;
  n=n+1; if v(n),					% file name
    fprintf(fd,'filename_ = ''%s'';\n', opFileName);
  end; n=n+1; if v(n)					% window size/pos
    set(opFig, 'Units', 'inches');
    fprintf(fd, 'pos_ = [%s];        %% inches\n', ...
	sprintf('%g ', get(opFig, 'Pos')));
  end; n=n+1; if v(n)					% window start/end time
    if (v(n+1))
      % dopos = 1;
    else
      fprintf(fd, 't0_ = %g;              %% s\n', opT0);
      fprintf(fd, 't1_ = %g;              %% s\n', opT1);
    end
  end; n=n+1; if v(n)					% time scaling (s/pix)
    fprintf(fd, 'timescale_ = %g;       %% s/inch\n', ...
	sub(opRedraw('curscale'), 1));
  end; n=n+1; if v(n)					%#ok<*ALIGN> % window low/high freq
    fprintf(fd, 'f0_ = %g;              %% Hz\n', opF0);
    fprintf(fd, 'f1_ = %g;              %% Hz\n', opF1);
  end; n=n+1; if v(n)					% freq scaling (Hz/pix)
    fprintf(fd, 'freqscale_ = %g;       %% Hz/inch\n', ...
	sub(opRedraw('curscale'), 2));
  end; n=n+1; if v(n)					% gram params
    fprintf(fd, 'datasize_ = %g;        %% s\n', opDataSize / opSRate);
    fprintf(fd, 'zeropad_ = %g;\n', opZeroPad);
    fprintf(fd, 'hopsize_ = %g;\n', opHopSize);
    fprintf(fd, 'wintype_ = %g;       %% %s\n', ...
	opWinType, opWinTypeF('name'));
  end; n=n+1; if v(n)					% brightness/contrast
    fprintf(fd, 'brightness_ = %g;\n', opBrightness);
    fprintf(fd, 'contrast_ = %g;\n', opContrast);
  end; n=n+1; if v(n)					% measurements
    m = opMeasure('getlogname', inf, 'long');
    fprintf(fd, 'measures_ = {');
    for i = 1 : length(m); fprintf(fd, ' ''%s'' ', m{i}); end
    fprintf(fd, '};\n');
  end; n=n+1; if v(n)					% number/names of logs
    fprintf(fd, 'lognames_ = %s;\n', opMultiLog('getloginfo'));
  end; n=n+1; if v(n)					% h/v slider scroll
    fprintf(fd, 'hscrollskip_ = %g;\n', opHScrollSkip);
    fprintf(fd, 'vscrollskip_ = %g;\n', opVScrollSkip);
  end; n=n+1; if v(n)					% colormap
    fprintf(fd, 'colormap_ = ''%s'';\n', opColorMapName);
  end
  % Always do these ones.
  fprintf(fd, 'usedatetime_ = %g;\n',   opUseDateTime);
  fprintf(fd, 'sepmeasurewin_ = %g;\n', opSepMeasWin);
  fprintf(fd, 'printlabel_ = %g;\n',    opPrintLabel);
  fprintf(fd, 'printportrait_ = %g;\n', opPrintPortrait);
  fprintf(fd, 'printposition_ = {''%s'' ''%s''};\n', opPrintPos{:});
  fprintf(fd, 'logarithmicfreq_ = %g;\n', opLogFreq);

  fclose(fd);

elseif (strcmp(cmd, 'load') || strcmp(cmd, 'autoload'))
  isauto = strcmp(cmd, 'autoload');
  opPointer('watch');
  if (isauto && gexist4('opPrefAutoFile'))
    pd = pathDir(opPrefAutoFile);
  elseif (gexist4('opPrefDir'))
    pd = opPrefDir;
  else
    pd = pathDir(opFileName);
  end
  [f,d] = uigetfile1([pd filesep '*.opref'], iff(~isauto,'Load preferences',...
      'Preferences file to load after every new file is opened'));
  opPointer('crosshair');
  if (~ischar(f) || nCols(f) == 0)			% f can be size [1 0]!
    if (isauto), opPrefAutoFile = ''; end    % cancel autoload
    return
  end
  opPrefDir = d;
  if (isauto), opPrefAutoFile = [d f]; end
  opPrefSave('load-file', [d f]);
  
elseif (strcmp(cmd, 'doautoload'))
  if (~gexist4('opPrefAutoFile')), return; end
  opPrefSave('load-file', opPrefAutoFile);

elseif (strcmp(cmd, 'load-file'))
  eval_file_name = x0;
  % Execute the script line-by-line, which sets prefs variables.
  % This used to be run(eval_file_name), but it doesn't work anymore.
  fd = fopen(eval_file_name, 'rt');
  if (fd < 0), error('File not found: %s', eval_file_name); end
  while (1)
    ln = fgetl(fd);
    if (isnumeric(ln)), break; end
    eval(ln);
  end
  fclose(fd);
  
  % Parse the variable values stored in the file; figure out along the
  % way how much re-computing and re-displaying is necessary.

  repaint   = 0;			% repaint whole window?
  flush     = 0;			% flush cache and reimage?
  reimage   = 0;			% redisplay gram?
  remeasure = 0;			% redisplay measurements?

  if (exist('filename_', 'var') && strcmp(filename_, opFileName))
    opSetFileInfo(filename_);		% set Srate, Nsamp, TMax, opFileName
    opInitialFrame;			% set up opT0/1, opF0/1
    repaint = 1; flush = 1;
  end;

  % oldpos is the original figure position, and newpos where it should move to.
  % newpos can get changed by both pos_ and timescale_/freqscale_ .
  figure(opFig);
  set(opFig, 'Units', 'inches');
  oldpos = get(opFig, 'pos');
  newpos = oldpos;

  if (exist('pos_', 'var'))
    newpos = pos_;			% repainting taken care of below
  end

  if (exist('t0_', 'var') && (t0_ ~= opT0 || t1_ ~= opT1))
    opT0 = max(0, min(min(t0_,t1_), opTMax));
    opT1 = max(0, min(max(t0_,t1_), opTMax));
    reimage = 1;
  end;
  if (exist('f0_', 'var') && (f0_ ~= opF0 || f1_ ~= opF1))
    opF0 = max(0, min(min(f0_,f1_), opSRate/2));
    opF1 = max(0, min(max(f0_,f1_), opSRate/2));
    reimage = 1;
  end;

  if (exist('timescale_', 'var') || exist('freqscale_', 'var'))
    cur = opRedraw('curscale');		% get current scaling
    if (exist('timescale_', 'var') && timescale_ ~= cur(1))
      [opT0,opT1,x] = opRescale(opT0, opT1, opTMax, timescale_, 1, newpos(3:4));
      if (x), newpos(3) = x; end
    end;
    if (exist('freqscale_', 'var') && freqscale_ ~= cur(2))
      [opF0,opF1,x] = opRescale(opF0, opF1, opSRate/2, ...
                                                 freqscale_, 2, newpos(3:4));
      if (x), newpos(4) = x; end
    end;
    reimage = 1;			% below, might decide to repaint too
  end

  if (exist('datasize_', 'var'))
    if (prefversion_ >= 3)
      % Change datasize to samples, ensuring it's no less than what's on popup.
      datasize_ = max(2 ^ round(log2(datasize_ * opSRate)), ...
	str2double(sub(get(opDataSizePopup, 'String'), 2, 0)));	    %#ok<NODEF>
    end
    if (datasize_ ~= opDataSize)
      opDataSize = datasize_;
      flush = 1;
    end
  end
  
  if (exist('zeropad_', 'var') && zeropad_ ~= opZeroPad)
    opZeroPad = zeropad_;
    flush = 1;
  end;
  if (exist('hopsize_', 'var') && hopsize_ ~= opHopSize)
    opHopSize = hopsize_;
    flush = 1;
  end;
  if (exist('wintype_', 'var') && wintype_ ~= opWinType)
    opWinType = wintype_;
    flush = 1;
  end;
  if (exist('brightness_', 'var') && brightness_ ~= opBrightness)
    opBrightness = min(1, max(0, brightness_));
    reimage = 1;
  end;
  if (exist('contrast_', 'var') && contrast_ ~= opContrast)
    opContrast = min(1, max(0, contrast_));
    reimage = 1;
  end;
  if (exist('measures_', 'var')),
    opMeasure('setmeasures', measures_, prefversion_);
    remeasure = 1;
  end
  if (exist('lognames_', 'var'))
    opMultiLog('setloginfo', lognames_);
  end
  if (exist('hscrollskip_', 'var')),
    opHScrollSkip = hscrollskip_;
  end
  if (exist('vscrollskip_', 'var')),
    opVScrollSkip = vscrollskip_;
  end
  if (exist('colormap_', 'var')),
    opColorMapName = colormap_;
    reimage = 1;
  end
  if (exist('printlabel_', 'var')),
    opPrintLabel = printlabel_;
  end
  if (exist('printportrait_', 'var')),
    opPrintPortrait = printportrait_;
  end
  if (exist('printposition_', 'var')),
    opPrintPos = printposition_;
  end
  if (exist('usedatetime_', 'var')),
    opUseDateTime = usedatetime_;
    opDateFix = iff(opUseDateTime, mod(opDateTime, 1) * secPerDay, 0);
    reimage = 1;
  end
  if (exist('sepmeasurewin_', 'var')),
    opSepMeasWin = sepmeasurewin_;
    reimage = 1;
  end
  if (exist('logarithmicfreq_', 'var')),
    opLogFreq = logarithmicfreq_;
  end
  
  % Do any redrawing necessary.
  if (any(oldpos ~= newpos))
    if (any(1e-4 < abs(oldpos(3:4) - newpos(3:4))))
      opInitFigure(opFileName);		% get rid of menus before re-sizing
      set(opFig, 'Units', 'inch', 'Pos', newpos);
      repaint = 1;
    else
      set(opFig, 'Pos', newpos);
      reimage = 1;
    end
  end
  if (flush)
    opCache('clear');
    % Display current values on the pulldowns.
    opDataSizeF('setpopup');
    opZeroPadF('setpopup');
    opHopSizeF('setpopup');
    opWinTypeF('setpopup');
  end
  if (repaint)
    opEraseSelection;
    opRedraw('repaint');
    flush = 0; reimage = 0; remeasure = 0;
  end
  if (flush)
    opEraseSelection;
    opRefresh(1);
    reimage = 0;
  end
  if (reimage)
    opRefresh(0);
  end
  if (remeasure)
    opMeasure('painttext');
  end

end
