function opPrint(cmd)
% opPrint('wysiwyg')
%    Print the image the same size as it appears on the screen.
%
% opPrint('eps')
% opPrint('png')
% opPrint('tiff')
% opPrint('jpg')
%    Like wysiwyg, but saves a Postscript, PNG, TIFF, or JPEG file instead of
%    printing.
%
% See also print, printopt.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% How MATLAB works: In printing, the entire window is scaled so that if fills 
% up the figure's PaperPosition.  In making EPS/PNG/TIFF/JPG files, the entire 
% window is imaged, and the bounding box is (more or less) set to cover 
% everything; the PaperPosition is ignored.

global opContrastText opBrightnessText opFig opAxes opWvfAxes
global opDataSize opZeroPad opHopSize opShowWvf opChans opNChans
global opEpsDir opImageButtons opWindowAxes opPrintLabel
global opPrintPortrait opPrintRes 

labelOffset = [0.5 -0.2];		% inches from axes left-bottom to text

set(opFig,        'Units', 'inch', 'PaperUnits', 'inch')
set(opWindowAxes, 'Units', 'inch')
set(opAxes,       'Units', 'inch')
set(opWvfAxes,    'Units', 'inch')

lastAxes = iff(opShowWvf, opWvfAxes(opChans(end)), opAxes(opChans(end)));

if (opPrintLabel)
  % Construct label.
  chanstr = iff(opNChans==1, '', ['  [ch. ' num2str(opChans) ']']);
  str = sprintf('%s%s    %g/%gx/%g/%s', opFileName, chanstr, opDataSize, ...
      opZeroPad, opHopSize, opWinTypeF('name'));
  % Display label at correct position.
  axes(opWindowAxes);		% sometimes this resets opAxes units to pixels
  set(opAxes, 'Units', 'inch')
  txPos = sub(get(lastAxes, 'OuterPosition'), [1 2]) + labelOffset;
  tx = text('Interpreter', 'none', 'String', str, 'FontName', 'Times ', ...
      'FontSize', 10, 'Units', 'inch', 'Position', txPos);
  %bbox([2 4]) = bbox([2 4]) + [-1 1] * (textDrop + 0.1);         %#ok<NASGU>
end

set(opFig, 'PaperPositionMode', 'auto');	% print it screen size

% Hide stuff we don't want to appear.
meas = [findobj(0,'Tag','opMeasureNames') findobj(0,'Tag','opMeasureNums')];
set([meas opContrastText opBrightnessText opImageButtons], 'Visible', 'off')

if (strcmp(cmd, 'wysiwyg'))
  % Print figure centered on page.
  orient_save = get(opFig, 'PaperOrientation');
  orient(opFig, iff(opPrintPortrait, 'portrait', 'landscape'));
  print('-noui', opPrintRes);			% print it!
  orient(opFig, orient_save);
else
  % Print the figure to a file.
  % Note: opPlay('movie') also uses opEpsDir.
  if (isempty(opEpsDir))
    opEpsDir = pathDir(opFileName);
  end
  fstr = iff(strcmp(cmd, 'eps'),  'Encapsulated PostScript (.eps)', ...
      iff(   strcmp(cmd, 'png'),  'Portable Network Graphics (.png)', ...
      iff(   strcmp(cmd, 'tiff'), 'TIFF (.tiff)', ...
      'JPEG')));
  % Need filesep here for cases like C:\ . Also, cmd is used as the extension!
  [f,p] = uiputfile1([opEpsDir filesep pathRoot(pathFile(opFileName)) '.' cmd], ...
    ['Save ' fstr ' file as...']);
  if (ischar(f))		% not Cancel?
    opEpsDir = p;
    
    pArg = iff(strcmp(cmd,'eps'),  '-depsc', ...
	iff(   strcmp(cmd, 'png'), '-dpng', ...
	iff(   strcmp(cmd, 'tiff'),'-dtiff', ...
	'-djpeg90')));
    print('-noui', opPrintRes, pArg, [p filesep f]);	% '-r' is dpi
  end
end

% Restore original conditions.  Have to recalculate meas.
if (opPrintLabel), delete(tx); end
meas = [findobj(0,'Tag','opMeasureNames') findobj(0,'Tag','opMeasureNums')];
set([opContrastText opBrightnessText opImageButtons meas], 'Visible', 'on')

%#ok<*MAXES>

% Old code; may be used again to eliminate whitespace from printout.
% 
% Find outer bounding box of all visible axes, including gram and wvf axes.
% This bbox may get enlarged because of opPrintLabel below.
% bbox = [inf inf -inf -inf];
% for ch = opChans
%   p = get(opAxes(ch), 'OuterPosition');
%   bbox = [min(bbox(1:2), p(1:2)) max(bbox(1:2)+bbox(3:4), p(1:2)+p(3:4))];
%   if (opShowWvf)
%     p = get(opWvfAxes(ch), 'OuterPosition');
%     bbox = [min(bbox(1:2), p(1:2)) max(bbox(1:2)+bbox(3:4), p(1:2)+p(3:4))];
%   end
% end
