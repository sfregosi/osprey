 function opRefChan(chans, setbc)
% opRefChan(chans)
%    Repaint channel image(s) and their axes.
%
% opRefChan(chans, setbc)
%    As above, but calculate brightness and contrast values from the gram
%    (or the selection, if there is one) and set the sliders.  If setbc is
%    2, ignore the selection and use the gram to calculate good
%    brightness/contrast values.
%
% opRefChan('StartAt0')
%    Like opRefChan(<all available channels>), but does so with the time axis
%    starting at t=0. This is useful for making figures.

% Note that this is also called from opPrint, which messes with opAxes.
% opPrint depends on this guy not changing the axes.

global opAxes opT0 opT1 opF0 opF1 opSelT0 opSelT1 opSelF0 opSelF1 opChans
global opBrightnessSlider opContrastSlider opBrightness opContrast
global opBrightReverse opBackgroundColor opColorDepth opLogFreq
global opFig opImages opUseDateTime opDateFix opFreqDiv
global opShowUnits opShowTime opShowFreq opShowWvf opWvfAxes
global opInhibitDisp opLog opAmpCalib opControls opSelSurf

% Handle commands. (Currently there's only one possibility, 'StartAt0'.)
tempStartAt0 = false;
if (ischar(chans))
  switch (chans)
    case 'StartAt0'
      tempStartAt0 = true;
      chans = opChans;		% display all of them
    otherwise
      error('Unknown command string passed to %s: %s', mfilename, chans);
  end
end

if (nargin < 2), setbc = 0; end

t0 = opT0;  t1 = opT1;
f0 = opF0;  f1 = opF1;

% Get the spectrogram cells to display.  Includes the selection highlight.
% Don't re-read wvf if we don't have to, since this can be slow.
% selbox and selpixbox are 4 x length(opChans), with rows of [t0 f0 t1 f1].
selbox = [opSelT0(chans);  opSelF0(chans);  opSelT1(chans);  opSelF1(chans)];
if (opShowWvf)
  [bits,selpixbox,realbox,wvf,wvfbox] = opGetSpect(chans,t0,t1,f0,f1,selbox);
  wvfbox = wvfbox + opDateFix;	   % adjust for real time read from a Harufile
else
  [bits,selpixbox,realbox]            = opGetSpect(chans,t0,t1,f0,f1,selbox);
end

% Adjust for real time read from a Harufile.
realbox([1 3]) = realbox([1 3]) + opDateFix;

% Correct NaN and +-Inf values (which probably came from 0's in the gram).
%i = find(isnan(bits) | bits <= 0);	% doesn't work w/normalization
ix = find(isnan(bits) | isinf(bits));
bits(ix) = 1e-35 * ones(1,length(ix));	% 1e-35 is detected in opBitsToPix

if (setbc)
  % Set brightness & contrast sliders to best-guess values.  When using whole
  % screenful (no selection), remove bottom 1/10 of box to elide DC offset pix.
  % To use selbox, at least 1/4 of selpixbox must be visible; p is part visible.
  q = [min(selpixbox(1,:,:),3) max(selpixbox(2,:,:),3) ...
       min(selpixbox(3,:,:),3) max(selpixbox(4,:,:),3)];
  p = [max(q([1 2]),1) min(q([3 4]), [nCols(bits) nRows(bits)])];
  if (setbc ~= 2 && opSelect && all(p([3 4]) > p([1 2])) && ...
      prod(p([3 4]) - p([1 2])) >= 1/4 * prod(q([3 4]) - q([1 2])))
    bt = bits(p(2):p(4), p(1):p(3), :);
  else
    bt = bits(round(iff(f0 == 0, nRows(bits)/10, 0))+1 : end, :, :);
  end
  [opBrightness,opContrast] = opColorMap('setbc', bt);
end

if (opInhibitDisp)
  return
end

% Delete old image(s).
for i = 1 : length(opAxes)
  if (ishghandle(opAxes(i)))
    delete(get(opAxes(i), 'children'));
  end
end

% Convert gram values to pixel values.
[pix, dBLims] = opBitsToPix(bits, opBrightness, opContrast);

% Draw dB colorbar.
dbAxes = opControls(20);
delete(get(dbAxes, 'Children'));		% delete old colorbar
if (~isnan(opAmpCalib))
  [~,~,ncolor] = opColorMap('getlimits');
  h = pcolor(dbAxes, [0 1], linspace(dBLims(1), dBLims(2), ncolor), ...
    [1:ncolor; 1:ncolor].');
  set(h, 'CDataMapping', 'direct', 'LineStyle', 'none');
  set(dbAxes, 'XTick', [], 'YAxisLocation', 'right', 'TickDir', 'out');
  title(dbAxes, 'dB')
end

%% Display new image(s).
set(opFig, 'HandleVis', 'on');
opSelSurf = zeros(length(opChans), 1);
for i = 1 : length(opChans)
  ch = opChans(i);
  ax = opAxes(ch);
  axes(ax);

  if (0)
    % Easy old way, doesn't work for log freq scaling (image() can't do it).
    opImages(chans) = image(realbox([1 3]), realbox([2 4]), pix, ...
	'ButtonDownFcn','opMouseClick');			%#ok<UNRCH>
  else
    % realbox has pixel centers; pcolor needs pixel edges.
    xWid = (realbox(3) - realbox(1)) / (nCols(pix) - 1);
    yHi  = (realbox(4) - realbox(2)) / (nRows(pix) - 1);
    realbox1 = realbox + [-xWid -yHi +xWid +yHi]/2;
    if (realbox1(2) <= 0), realbox1(2) = min(1, realbox1(4)/4); end
    pix1 = pix(:,:,i);
    % Grow pix 1 bigger in each dimension since pcolor ignores last row & col.
    pix1(nRows(pix1)+1, nCols(pix1)+1) = 0;
    imT = linspace(realbox1(1), realbox1(3), nCols(pix1));
    f   = linspace(realbox1(2), realbox1(4), nRows(pix1));
    [imF,prefix,opFreqDiv] = metricPrefix(f, 5);
    opImages(ch) = pcolor(imT, imF, pix1);
    set(opImages(ch), 'ButtonDownFcn', 'opMouseClick', 'LineStyle', 'none', ...
	'CDataMapping', 'direct');
    % Setting yscale to logarithmic messes with tick marks.
    ytix = get(ax, 'YTick');
    set(ax, 'YScale', iff(opLogFreq, 'log', 'linear'));
    set(ax, 'YTick', ytix);
  end

  % Handle opDateFix on X-axis, logscale on Y-axis, etc.
  yl = [iff(f0 > 0, f0, min(1, f1/4)) f1] / opFreqDiv;
  set(ax, 'XLim', [t0 t1] + opDateFix, 'YLim', yl, 'YDir', 'normal', ...
      'Box', 'off', 'TickDir', 'out', 'Color', opBackgroundColor);
  xlabel('')				% may get changed below
  if (i ~= length(opChans) || opShowWvf)
    set(ax, 'XTickLabel', {});
  end
  % Do Y label.
  if (opShowFreq && i == floor((length(opChans)+1) / 2))
    h = ylabel(['frequency, ' prefix 'Hz']);
    pos = get(h, 'Position');
    if (i == length(opChans)/2)		% even number of channels?
      set(h, 'Position', [pos(1) sub(get(ax, 'YLim'), 1) pos(3)]);
    end
  end
  
  % Display yellow rectangles for selection box and log entries. Requires the
  % the necessary measurements be enabled.  First get ix=on-screen indices of
  % opLog.
  c = opMeasure('getlogcol',{'start time' 'end time' 'low freq' 'high freq'},...
    'datalog');
  % Get ix, the indices of opLog to draw selection boxes for.
  if (isempty(opLog) || any(isnan(c))), ix = [];  % need log, certain msmts
  else
    ix = find(opLog(:,c(1)) < opT1 & opLog(:,c(2)) > opT0 & ...
      opLog(:,c(3)) < opF1 & opLog(:,c(4)) > opF0);
  end
  cIx = opColorMap('getselindex');
  for z = length(ix) : -1 : 0		% backwards so that selection is on top
    if (z == 0)				% z=0 is special case: the selection
      if (~opSelect), continue; end	% no selection?
      bx = selbox([1 3 2 4], i).';	% show selectn; dotted line added below
    else
      bx = opLog(ix(z), c);
    end
    if (nCols(bx) == 1), bx = bx.'; end	% bx should be row vec; sometimes isn't

    % Display selection (w/dotted line) or log entry (w/o line) rectangle.
    opSelSurf(ch,z+1) = surface(bx(1:2) + opDateFix, bx(3:4) / opFreqDiv, cIx*[1 1;1 1], ...
      'CDataMapping',  'direct', 'FaceAlpha', opColorDepth, ...
      'ButtonDownFcn', 'opMouseClick', 'LineStyle', iff(z==0, ':', 'none'), ...
      'EdgeColor', iff(opBrightReverse, 'w', 'k'));
  end
  
  % Show waveform.
  if (opShowWvf)
    ax = opWvfAxes(ch);
    axes(ax);
    delete(get(ax, 'Children'));
    %wvf = wvf - mean(wvf);	% make zero-mean (for published figures)
    cal = iff(isnan(opAmpCalib), 1.0, opAmpCalib);
    % Draw the signal waveform.
    line(linspace(wvfbox(1), wvfbox(2), length(wvf)), wvf(:,i) / cal);
    set(ax, 'XLim', [t0 t1] + opDateFix, 'TickDir', 'out', ...
      'Box', 'off', 'XTickMode', 'auto', 'XTickLabelMode', 'auto');
    xlabel('')				% may get changed below
    if (i ~= opChans(end))		% remove XTickLabels except at bottom
      set(ax, 'XTickLabel', {});
    end
    % Do Y label.
    if (opShowFreq && i == floor((length(opChans)+1) / 2))
      h = ylabel(iff(isnan(opAmpCalib), 'amplitude', 'amplitude, {\mu}Pa'));
      set(h, 'Interpreter', 'tex');
      pos = get(h, 'Position');
      if (i == length(opChans)/2)		% even number of channels?
	set(h, 'Position', [pos(1) sub(get(ax, 'YLim'), 1) pos(3)]);
      end
    end
  end
end

opRedraw('yaxislabels');   % fix exponential notation in Y-axes

axes(ax)
if (opShowTime), xlabel(iff(opUseDateTime, 'time', 'time, s')); end

% Fix X-axis to not have exponential notation.  This is the waveform axis
% if it's showing, else the gram axis.
tx = get(ax, 'XTick');
txOff = iff(tempStartAt0, opT0, 0);
if (tempStartAt0)
  tx = 0 : diff(tx(1:2)) : opT1-opT0;
  set(ax, 'XTick', tx + txOff);
end
% Calculate number of digits of precision, dig.
if (length(tx) > 1), dig = max(0, -floor(log10(abs(1.01 * diff(tx(1:2))))));
else dig = 3;
end
for i = 1 : length(tx)
  t = tx(i);
  % If desired, use hr:min:sec instead of seconds.
  if (opUseDateTime)
    % Get hours:minutes:seconds. Seconds have leading 0, maybe a decimal point.
    s = mod(t,60);
    str = [sprintf('%d:%02d:', ...
	floor(mod(t, 24*3600) / 3600), floor(mod(t, 3600) / 60)) ...
	iff(dig==0, sprintf('%02d',s), sprintf('%0*.*f',dig+3,dig,s))];
  else
    % Get seconds without or with a decimal point.
    str = iff(dig==0, sprintf('%d',t), sprintf('%*.*f',dig+3,dig,t));
  end
  
  if (i == 1), newtx = str; else newtx = char(newtx, str); end
end
set(ax, 'XTickLabel', newtx);

% Re-set tick marks to exclude last time tick and upper freq tick, so
% they don't crash into 'Hz' and 's'.
xt = get(ax, 'XTick');
if (length(xt) > 2 && opShowUnits)
  set(ax, 'XTick', xt(1 : length(xt)-1));
end
ax1 = opAxes(opChans(1));		% the top-most axes
yt = get(ax1, 'YTick');
if (length(yt) > 2 && opShowUnits)
  set(ax1, 'YTick', yt(1 : length(yt)-1));
end

% Set scroll bars and play button.
opSetSliders;
b = iff(opBrightReverse, 1 - opBrightness, opBrightness);
set(opBrightnessSlider, 'Value', min(1, max(0, b)));
set(opContrastSlider,   'Value', min(1, max(0, opContrast)));
opPlay('disptext');

% Make it so user won't accidentally clobber the image.
set(opFig, 'HandleVis', 'callback');

% Update time bounds of linked figures.
opView('dolink');

%#ok<*LAXES>
%#ok<*MAXES>
