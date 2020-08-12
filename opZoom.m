function opZoom(typ)
% All of these commands erase the selection and redisplay.
% 
% opZoom('sel')
%     Zoom to the current selection.
% 
% opZoom('sel-h')
%     Zoom to selection in the horizontal direction.
%
% opZoom('sel-v')
%     ... only in the vertical direction.
%
% opZoom('all')
%     Zoom to the whole sound.

global opSelT0 opSelT1 opSelF0 opSelF1 opT0 opT1 opF0 opF1 opc opTMax opSRate

issel = opSelect;			% is there a selection?

if (strcmp(typ, 'sel') & issel)
  opT0 = opSelT0(opc);
  opT1 = opSelT1(opc);
  opF0 = opSelF0(opc);
  opF1 = opSelF1(opc);
  opEraseSelection;

elseif (strcmp(typ, 'sel-h') & issel)
  opT0 = opSelT0(opc);
  opT1 = opSelT1(opc);
  opEraseSelection;

elseif (strcmp(typ, 'sel-v') & issel)
  opF0 = opSelF0(opc);
  opF1 = opSelF1(opc);
  opEraseSelection;

elseif (strcmp(typ, 'all'))
  opF0 = 0;
  opF1 = opSRate / 2;
  opT0 = 0;
  opT1 = opTMax;

end

opRefresh;
