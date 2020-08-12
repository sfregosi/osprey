function opPointer(ptype)
% opPointer(ptype)
% Check MATLAB's vetsion number, change the mouse cursor if appropriate.

global opFig

if (matlabver >= 4 & ~strcmp(version, '4.0a'))
  set(opFig, 'Pointer', ptype);
  drawnow;
end
