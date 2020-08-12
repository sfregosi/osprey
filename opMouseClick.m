function opMouseClick
% opMouseClick
% This gets called when the user clicks in the window.  Left-click ('normal')
% starts a selection, and right-click ('alt') completes or extends it.
% Middle-click (or, on Windows, shift-click) ('extend') adds to the datalog.
% Double-click displays a spectrum.

global opc opMousePos opSelT0 opSelT1 opSelF0 opSelF1 opAxes opSRate opTMax
global opFig opDateFix opNChans opFreqDiv opSelSurf opStartMovePos 
global opMovingSurf opMovingSurfStart opMoveChan opMoveOffset

% Set opc to the index of the axes object the user clicked on.
% There must be a better way to do this.
obj = gcbo;
selobj = obj;
while (all(obj ~= opAxes))
  obj = get(obj, 'Parent');
  if (obj == 0 || obj == 1)
    return			% click was not on any opAxes; ignore it
  end
end
opc = find(opAxes == obj);	% set it!

pt = sub(get(opAxes(opc), 'CurrentPoint'), 1, 1:2);
pt = [pt(1)-opDateFix  pt(2)*opFreqDiv;];

switch(get(opFig, 'SelectionType'))
case 'normal'					% left mouse click
  % Check for user moving the selection in this channel.
  if (all(size(opSelSurf) > [0 0]) && any(selobj == opSelSurf(:,1)))
    opMovingSurf = selobj;
    opMovingSurfStart = [get(selobj, 'XData') get(selobj, 'YData')];  % 1x4 vec
    set(opFig, 'WindowButtonMotionFcn', @moveSel, 'WindowButtonUpFcn',@endMove)
    opStartMovePos = pt;
    opMoveChan = find(selobj == opSelSurf(:,1));
  else
    % Start a new selection.
    opMousePos = pt;
    opMeasure('newpt', opc, pt);
  end
    
case 'alt'					% right mouse click
  if (~isinf(opMousePos(1)))
    % Complete the selection.
    opSelT0(1:opNChans) = min(opMousePos(1), pt(1));
    opSelT1(1:opNChans) = max(opMousePos(1), pt(1));
    opSelF0(1:opNChans) = min(opMousePos(2), pt(2));
    opSelF1(1:opNChans) = max(opMousePos(2), pt(2));
    opMousePos = [Inf Inf];
    opMoveOffset = zeros(opNChans, 2);
    
  elseif (opSelect)
    % Extend the nearest corner of the existing selection.
    [t,f] = deal(pt(1), pt(2));
    if (abs(opSelT0(opc) - t) < abs(opSelT1(opc) - t)), opSelT0(1:opNChans)=t;
    else						opSelT1(1:opNChans)=t;
    end
    if (abs(opSelF0(opc) - f) < abs(opSelF1(opc) - f)), opSelF0(1:opNChans)=f;
    else						opSelF1(1:opNChans)=f;
    end
  end

  % Restrict selection to be within waveform.
  opSelT0(1:opNChans) = max(opSelT0(1:opNChans), 0);
  opSelT1(1:opNChans) = min(opSelT1(1:opNChans), opTMax);
  opSelF0(1:opNChans) = max(opSelF0(1:opNChans), 0);
  opSelF1(1:opNChans) = min(opSelF1(1:opNChans), opSRate/2);

  opMeasure('newsel', opc, pt);
  opRefresh;
  
  if (0)				% debug: display trimmed box
    global MLNS_values opAxes		%#ok<UNRCH>
    axes(ax)
    M = MLNS_values;
    line(M([1 1 1 2; 2 2 1 2]), M([3 4 3 3; 3 4 4 4]), 'Color', [1 0 0], ...
	'LineStyle', ':')
  end
  
case 'extend'				% middle/shift mouse click
  % Add point to data log.
  opDataLog('click', opc, pt);
  opMousePos = [inf inf];
  
case 'open'				% double-click
  % Show spectrum.
  opSpectrum('show', pt)
  opMousePos = [Inf Inf];		% this click doesn't start a selection
  figure(opFig)

end	% switch


function moveSel(src, event)					%#ok<INUSD>
% User clicked on the selection box and started moving mouse.  Move the box,
% but only horizontally.
global opStartMovePos opDateFix opFreqDiv opMovingSurf opMovingSurfStart 
global opMoveOffset opMoveChan
pt = sub(get(gca, 'CurrentPoint'), 1, 1:2);
pt = [pt(1)-opDateFix  pt(2)*opFreqDiv;];
opMoveOffset(opMoveChan,:) = [pt(1)-opStartMovePos(1)  0];	% move only in x
set(opMovingSurf, 'XData', ...					% no YData here
  opMovingSurfStart(1:2) + opMoveOffset(opMoveChan,1))


% Mouse button up.  Stop the move.
function endMove(src, event)					%#ok<INUSD>
global opFig opMoveOffset opSelT0 opSelT1 opSelF0 opSelF1
set(opFig, 'WindowButtonMotionFcn', '', 'WindowButtonUpFcn', '')
opSelT0 = opSelT0 + opMoveOffset(:,1).';
opSelT1 = opSelT1 + opMoveOffset(:,1).';
opSelF0 = opSelF0 + opMoveOffset(:,2).';
opSelF1 = opSelF1 + opMoveOffset(:,2).';
opMoveOffset(:) = 0;
