function opView(cmd)
% opView('link')
%    Put up a dialog box for the user to enter linked windows.
%
% opView('linkcallback')
%    Callback after user clicks OK or Cancel in dialog box.

global opLinkedFigs uiInputButton uiInput1 opFig opT0 opT1

if (strcmp(cmd, 'link'))
  z = [];
  figs = get(0, 'Children');	% list of all visible figures
  figs((figs.' == opFig) | strncmp({figs.Name}, 'Spectrum', 7) | ...
    strncmp({figs.Name}, 'Measurements', 12)) = [];	% remove Osprey windows
  for i = 1 : length(figs)
    nm = get(figs(i), 'Name');
    if (isempty(nm))
      z = char(z, sprintf('      %d   %s', figs(i).Number, ...
	  iff(length(nm), nm, ['Figure No. ' num2str(figs(i).Number)])));
    end
  end
  lab = '    The current figures that exist, and their names, are';
  z = iff(~isempty(z), char(lab, z, ' '), '');
  
  uiInput(char('Set up linked windows', ...
    'When you link a window to Osprey, scrolling left and right', ...
    'in Osprey will make graph(s) in the linked window scroll to the same',...
    'span of time.  Which window numbers do you want to link?', ...
    ' ', z), ...
    'OK|Cancel', 'opView(''linkcallback'')', 500, ...
    'Enter a list of window (figure) numbers, separated by spaces.', ...
    num2str(opLinkedFigs));
  return	% execution continues immediately below upon user input
  
elseif (strcmp(cmd, 'linkcallback'))
  if (uiInputButton == 2), return; end			% Cancel
  x = str2double(uiInput1);
  if (~isempty(x) || all(uiInput1 == ' ' | uiInput1 == 9))  % numbers or blank
    opLinkedFigs = x;
    opView('dolink')
  else
    warning(['Sorry, I am unable to parse your list of window\10' ... 
	    'numbers. Please try again, or click Cancel']);
  end

elseif (strcmp(cmd, 'dolink'))
  % Update time bounds of linked figures.  Do all axes found.
  for lf = opLinkedFigs            % some of these may be 0; that's okay
    if (any(lf == get(0, 'Children')))   % figure still exists?
      set(findobj(lf, 'Type', 'axes'), 'XLim', [opT0 opT1])
    end
  end
  figure(opFig)

end
