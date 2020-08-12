function opScrollAmount(hv, amt)
% opScrollAmount(hv, amt)
%    Depending on whether hv is 'h' or 'v', set either opHScrollSkip or
%    opVScrollSkip to amt.
%
% opScrollAmount('s')
%    Set check-marks on menus.

global opHScrollSkip opVScrollSkip opHScrollMenu opVScrollMenu

if (hv == 'h')
  opHScrollSkip = amt;
  opSetSliders;

elseif (hv == 'v')
  opVScrollSkip = amt;
  opSetSliders;

elseif (hv == 's')
  hKids = get(opHScrollMenu, 'children');
  vKids = get(opVScrollMenu, 'children');
  for i = [hKids vKids]
    set(i, 'Checked', 'off'); 
  end
  set(hKids(length(hKids)-opHScrollSkip*4), 'Checked', 'on');
  set(vKids(length(vKids)-opVScrollSkip*4), 'Checked', 'on');

else
  error('Unknown first arg.')
end
