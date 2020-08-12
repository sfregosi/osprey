function opPrint(cmd, np)
% opPrint('wysiwyg')
%    Print the image the same size as it appears on the screen.
%
% opPrint('eps')  or  opPrint('png')  or  opPrint('jpg')
%    Like wysiwyg, but saves a Postscript, PNG, or JPEG file instead of
%    printing.
%
% opPrint('fullpage')
%    Print the image so it fills up a page.
%
% opPrint('manypages' [,np])
%    Several pages (np of them) of the gram are printed.  The printed images 
%    are the same scaling as the screen, as well as the same height, but are 
%    wide enough to fill up the page.  If np is not supplied the user is asked.
%
%    Page margins are given by opPrintMargin, which is set in opNewSignal.
%
% See also print, printopt.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% How MATLAB works: In printing, the entire window is scaled so that if fills 
% up the figure's PaperPosition.  In making EPS/PNG/JPG files, the entire 
% window is imaged, and the bounding box is (more or less) set to cover 
% everything; the PaperPosition is ignored.

global opPrintMargin opContrastText opBrightnessText opc opFig opAxes opWvfAxes
global opT0 opT1 opF0 opF1 opTMax opDataSize opZeroPad opHopSize
global uiInput1 uiInputButton opMeasureTexts opMeasureNums opShowWvf
global opEpsDir opEpsMargin opImageButtons opWindowAxes opPrintLabel
global opPrintPortrait opPrintPos

if (nargin < 1), cmd = 'wysiwyg'; end

if (strcmp(cmd, 'manypages') && nargin < 2)
  uiInput('Print several pages','OK|Cancel','opPrint(''manypages'',-1)', ...
      [0 0], ['How many pages to print?', 10, ...
          '(enter Inf to print to the end of the sound)'], '');
  return
end

opPrintPos = lower(opPrintPos);

filecmd = strcmp(cmd, 'eps') | strcmp(cmd, 'png') | strcmp(cmd, 'jpg');
portrait = opPrintPortrait || filecmd;
mar = iff(filecmd, opEpsMargin + [0 iff(opPrintLabel, 0.25, 0) 0 0], ...
    iff(opPrintPortrait, opPrintMargin([2 1 4 3]), opPrintMargin));

fig      = opFig; 
ax       = opAxes;  	
wax      = opWvfAxes;
maxT     = opTMax;
textDrop = 0.56;                 % inches from image bottom to text middle

% Save everything...
orient_save = get(fig, 'PaperOrientation');
orient(iff(portrait, 'portrait', 'landscape'));
aunit_save = get(ax(opc),  'Units');   % string
apos_save  = get(ax,  'Position');     % Nx1 cell array of 1x4 position vectors
wunit_save = get(wax(opc), 'Units');   % string
wpos_save  = get(wax, 'Position');     % Nx1 cell array of 1x4 position vectors
punit_save = get(fig, 'PaperUnits');   % string
ppos_save  = get(fig, 'PaperPosition');% 1x4 position vector
for i = [opBrightnessText opContrastText ...
	  opMeasureTexts opMeasureNums opImageButtons];
  set(i, 'Visible' ,'off'); 
end
set(findobj(0, 'Tag', 'opMeasureTexts'), 'Visible', 'off')
set(findobj(0, 'Tag', 'opMeasureNums'),  'Visible', 'off')
sav = [opT0 opT1 opF0 opF1];

% Get size of source figure (figsize) and size/position of source axes.
set(fig, 'Units', 'inches');
figsize = sub(get(fig, 'Pos'), 3:4);
set(fig, 'PaperUnits', 'inches');
papersize = get(fig, 'PaperSize');                              % inches

set(ax,  'Units', 'inches');  axpos  = get(ax,  'Position');
set(wax, 'Units', 'inches');  waxpos = get(wax, 'Position');
srcpos  = axpos(1:2);
srcsize = axpos(3:4);
if (opShowWvf)
  srcsize(2) = axpos(2) + axpos(4) - waxpos(2);
  srcpos(2)  = waxpos(2);
end

if (strcmp(cmd, 'fullpage'))
  destsize = papersize - mar(1:2) - mar(3:4);                   % inches
  destpos = mar(1:2);                                           % inches
  np = 1;                                                       % # of pages
elseif (strcmp(cmd, 'wysiwyg') || filecmd)
  destsize = srcsize;                                           % inches
  destpos = [iff(filecmd || opPrintPos{1}(1)=='l', mar(1), ...
      iff(opPrintPos{1}(1)=='c', (papersize(1)- srcsize(1))/2, ...
      papersize(1) - srcsize(1) - mar(3))) ...
      iff(filecmd || opPrintPos{2}(1)=='b', mar(2), ...
      iff(opPrintPos{2}(1)=='m', (papersize(2) - srcsize(2))/2, ...
      papersize(2) - srcsize(2) - mar(4)))];
  np = 1;
elseif (strcmp(cmd, 'manypages'))
  % Already put up the dialog box; this gets called after user input.
  if (np == -1)
    np = str2num(uiInput1);
    if (uiInputButton ~= 1 || length(np) ~= 1), return; end
    if (np < 1 || np ~= floor(np)), return; end
  end

  destsize = [(papersize(1) - mar(1) - mar(3)), srcsize(2)];    % inches
  destpos = [mar(1) (papersize(2) - srcsize(2))/2];
  sPerInch = (opT1 - opT0) / srcsize(1);
else 
  error(['Internal error: Unknown command argument for opPrint: ', cmd]);
end

chanstr = iff(opNChans==1, '', [' ch. ' num2str(opChans)]);
str = sprintf('%s%s    %g/%gx/%g/%s', opFileName, chanstr, opDataSize, ...
    opZeroPad, opHopSize, opWinTypeF('name'));

while (np > 0)
  if (strcmp(cmd, 'manypages'))
    opT1 = opT0 + destsize(1)*sPerInch;
    if (opT1 > maxT),              % this happens once at end of sound
      destsize(1) = destsize(1) / ((opT1-opT0) / (maxT-opT0));
      opT1 = maxT;
    end
    set(ax, 'Units', aunit_save, 'Position', apos_save);
    opRefresh; drawnow;
  end
  newpos = destpos - iff(filecmd, 0, destsize ./ srcsize .* srcpos);
  newsize = destsize ./ srcsize .* figsize;
  set(fig, 'PaperPosition', [newpos newsize]);

  if (opPrintLabel)
    txX = sub(get(ax, 'Xlim'), 1);
    drop = textDrop + iff(opShowWvf, axpos(2) - waxpos(2), 0);
    yl = get(ax, 'YLim');
    txY = yl(1) - drop * diff(yl) / destsize(2) * srcsize(2)/axpos(4);
    axes(ax)
    tx = text('Interpreter', 'none', 'String', str, 'FontName', 'Times ', ...
      'FontSize', 10, 'Position', [txX txY], 'Visible', 'on');
    if (matlabver >= 5), set(tx, 'Interpreter', 'none'); end  % inhibit TeX
    %printf('text label pos: %.1f (%s)', get(tx, 'pos'), get(tx, 'units'))
  end

  opPointer('watch');
  if (filecmd)
    % Note: opPlay('movie') also uses opEpsDir.
    if (~gexist4('opEpsDir'))
      opEpsDir = pathDir(opFileName);
    end
    fstr = iff(strcmp(cmd, 'eps'), 'Encapsulated PostScript (.eps)', ...
	iff(strcmp(cmd, 'png'), 'Portable Network Graphics (.png)', 'JPEG'));
    % Need filesep here for cases like C:\ .
    [f,p] = uiputfile1([opEpsDir filesep], ['Save ' fstr ' file as...']);
    if (ischar(f))
      opEpsDir = p;
      
      % Have to shift all axes to lower left corner so margins work right.
      shift = srcpos - destpos;                 % amount to shift, inches
      set(ax,  'Units', 'inches', 'Pos', axpos  - [shift 0 0]);
      set(wax, 'Units', 'inches', 'Pos', waxpos - [shift 0 0]);
      
      set(opWindowAxes, 'Units', 'inches');
      w = get(opWindowAxes, 'Pos');                     % for 'Hz' and 's'
      set(opWindowAxes, 'Pos', w - [shift 0 0]);
      
      pArg = iff(strcmp(cmd,'eps'), '-depsc', ...
	iff(strcmp(cmd, 'png'), '-dpng', '-djpeg90'));
      s = warning('off', 'MATLAB:Print:CustomResizeFcnInPrint');
      print('-noui', pArg, [p filesep f]);
      warning(s);
      
      set(opWindowAxes, 'Pos', w);
    end
  else
    set(ax,           'Units', 'norm');        % as of MATLAB 4.1, must do this
    set(wax,          'Units', 'norm');
    set(opWindowAxes, 'Units', 'norm');
    s = warning('off', 'MATLAB:Print:CustomResizeFcnInPrint');
    if (matlabver >= 5), print('-noui');
    else print;
    end
    warning(s);
  end
  
  if (opPrintLabel)
    delete(tx)
  end
  opT0 = opT1;        % for next page
  if (abs(opT0 - maxT) < 1e-10), break; end
  np = np - 1;
end
opPointer('crosshair');

% Restore everything...
opT0=sav(1); opT1=sav(2); opF0=sav(3); opF1=sav(4);
set(ax,  'Units',            aunit_save);
set(ax,  'Position',         apos_save);
set(wax, 'Units',            wunit_save);
set(wax, 'Position',         wpos_save);
set(fig, 'PaperUnits',       punit_save);
set(fig, 'PaperPosition',    ppos_save);
set(fig, 'PaperOrientation', orient_save);
set([opBrightnessText opContrastText ...
	  opMeasureTexts opMeasureNums opImageButtons], 'Visible' ,'on'); 
if (strcmp(cmd, 'manypages')), opRefresh; end

%#ok<*ST2NM>
%#ok<*LAXES>
