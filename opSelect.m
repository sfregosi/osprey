function x = opSelect(typ)
% bool = opSelect
%    Return 1 if there is currently a selection, 0 otherwise.
%
% opSelect('win-h')
%    Extend selection to the current window in the time direction.
%
% opSelect('win-v')
%    Extend selection to the current window in the frequency direction.
%
% opSelect('all-h')
%    Extend selection to the whole sound in the time direction.
%
% opSelect('all-v')
%    Extend selection to the whole sound in the frequency direction.
%
% opSelect('none')
%    Erase selection.

global opc opT0 opT1 opF0 opF1 opSelT0 opSelT1 opSelF0 opSelF1 opTMax opSRate

if (nargin < 1)
  x = (opSelT0(opc) <= opSelT1(opc)) & (opSelF0(opc) <= opSelF1(opc));
  return
end

if (strcmp(typ, 'win-h'))
  opSelT0(:) = opT0;
  opSelT1(:) = opT1;
end
if (strcmp(typ, 'win-v'))
  opSelF0(:) = opF0;
  opSelF1(:) = opF1;
end
if (strcmp(typ, 'all-h') || strcmp(typ, 'all'))
  opSelT0(:) = 0;
  opSelT1(:) = opTMax;
end
if (strcmp(typ, 'all-v') || strcmp(typ, 'all'))
  opSelF0(:) = 0;
  opSelF1(:) = opSRate / 2;
end
if (strcmp(typ, 'none'))
  opEraseSelection
end

opMeasure('newsel', opc);
opRefresh;
