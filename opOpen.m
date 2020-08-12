function opOpen(cmd)
% opOpen('open')
% Put up a dialog box for opening a new file, get a response, 
% (re-)open an osprey window for the file.
%
% opOpen('quit')
% Close the current Osprey window.

global opFig opc

if (strcmp(cmd, 'open'))
  dir = pwd;
  if (gexist4('opc') && opc > 0)
    dir = pathDir(opFileName('getsound'));
  end
  [f,p] = uigetfile1([dir filesep '*.*'], 'Osprey');
  if ((~ischar(f)) || ~min(size(f))), return; end		% Cancel
  osprey([p f]);

elseif (strcmp(cmd, 'quit'))
  delete(opFig);
  opFig = 0;
  
else
  error(['Internal error: Unknown command ''', cmd, '''.']);
end
