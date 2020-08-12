function [x0,x1,newsize] = opRescale(x0, x1, xMax, new, dim, fsize)
% [x0,x1,newsize] = opRescale(x0, x1, xMax, new, dimm fsize)
%    Rescale the dimensions of opAxes to fit the given size.  If the
%    sound is too short for the new size, force it -- resize the
%    window to make it fit.  The current figure is not used except 
%    to determine the size of the non-image part of the window.
%   
%    If the figure needs resizing, newsize is returned non-zero and
%    is the new size of this dimension in inches; otherwise it's 0.
%
%    Input arguments:
%	x0	  old (and new returned value) start
%	x1	  old ( " ) end
%	xMax	  maximum along this dimension; minimum is assumed to be 0
%	new	  new s/in or Hz/in
%	dim	  1 for x-dim or 2 for y-dim
%	fsize	  desired [x y] figure size, in inches

global opAxes opFig opc

% z is the size of the non-image part of the window.
set(opFig,  'Units', 'inches');
set(opAxes, 'Units', 'inches');
set(opFig,  'Units', 'inches');
z = sub(get(opFig,'Pos') - get(opAxes(opc),'Pos'), dim+2);

asize   = fsize(dim) - z;		% desired axes size
scale   = new / ((x1 - x0) / asize);
x1      = x0 + asize*new;
newsize = 0;

if (x1 > xMax)
  x0 = x0 - (x1 - xMax);
  x1 = xMax;
  if (x0 < 0)
    % Image is too big at new scale; have to resize the window.
    newsize = ((fsize(dim)-z)*(x1/(x1-x0))+z);
    x0 = 0;
  end
end
