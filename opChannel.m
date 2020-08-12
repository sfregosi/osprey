function opChannel(cmd, x0)
% opChannel('makemenu')
%    Fix up opChannelMenu's children to match the current number of channels
%    and the currently selected one.
%
% opChannel('set', c)
%    Set c to be the currently selected channel.  Recompute and update the
%    display accordingly.

global opNChans opChans opChannelMenu

if (strcmp(cmd, 'makemenu'))
  delete(get(opChannelMenu, 'Children'));
  for i = 1 : opNChans
    uimenu(opChannelMenu, 'Label', ['channel '  num2str(i)], ...
	'Callback', ['opChannel(''set'', '  num2str(i)  ');']);
  end
  opChannel('setmenu');
  
elseif (strcmp(cmd, 'setmenu'))
  % Un-check existing menu items, check the right one(s).
  kids = get(opChannelMenu, 'Children');
  for k = kids
    set(k, 'Checked', 'off');
  end
  set(kids(length(kids) - opChans + 1), 'Checked', 'on');
  
elseif (strcmp(cmd, 'set'))
  if (any(opChans == x0))
    if (length(opChans) == 1), return; end	% don't remove last one
    opChans(opChans == x0) = [];		% remove this channel
  else
    opChans = sort([opChans x0]);		% add this channel
  end
  opChannel('setmenu');
  opPositionControls;
  opRefresh(1);

else
  error('Osprey internal error: Unknown cmd arg passed to opChannel.');
end
