function y = opExists
% y = opExists
%   Return
%	0 if opFig doesn't exist,
%	1 if it exists but the axes aren't there,
%       2 if it exists and has the axes.

global opFig opAxes opChans

y = 0;
if (gexist4('opFig'))
  if (~isempty(opFig))
    if (matlabver <= 4)
      if (any(get(0, 'Children') == opFig)), y = 1; end
    else
      if (ishandle(opFig)), 
        if (strcmp(get(opFig, 'Tag'), 'Osprey'))
          y = 1;
        end
      end
    end
    if (y)
      if (~isempty(opAxes) && any(get(opFig, 'Children') == opAxes(opChans(1))))
	y = 2;
      end
    end
  end
end
