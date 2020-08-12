function opEdit(cmd, inhibit)
% opEdit('copy' [,inhibitScreenMsg])
%    Copy the current selection and place it in the global variable 
%    opSelection.
%
% opEdit('saveAs')
%    Ask user for file name, then write the current selection as a sound file.
%
% opEdit('plot')
%    Plot the selection in the window whose Tag is ospreywaveform.

global opc opSelT0 opSelT1 opSRate opSelection opChans
global opT0 opT1 opNSamp opSaveSoundDir opNBits

if (strcmp(cmd, 'copy') || strcmp(cmd, 'saveAs') || strcmp(cmd, 'plot'))
  if (strcmp(cmd, 'saveAs'))
    % Save As -- check errors, then ask user for filename.
    if (~opSelect)
      warndlg('You must have a selection to save.');
      return
    end
    if (~ischar(opSaveSoundDir)), opSaveSoundDir = ''; end
    while (1)
      [f,p] = uiputfile1(fullfile(opSaveSoundDir, ...
	[pathRoot(pathFile(opFileName)) '@.' pathExt(opFileName)]), ...
	'Save selection as a sound file');
      if (isnumeric(f)), return; end               % user clicked Cancel
      if (strcmp(fullfile(p,f), opFileName))
	error('The file name to save must be different from the one you''re viewing.');
      end
      if (~strcmp('none', soundFileType([p f])))
        break		% it's a known file type
      end
      if (length(f) > 3 && (strcmp(pathExt(f), '*') || isempty(pathExt(f))))
	f = [pathRoot(f) '.wav'];
	break
      end
      ret = uiInput(str2mat('Unknown file extension', ...
	  ['I can''t tell what type of sound file that is.  Please ' 10 ...
	      'enter a file name whose extension is .wav, .au, .aif, ' 10 ...
	      'or one of the other known types of sound files.']), ...
	  'OK', ' ');
      set(ret(1), 'WindowStyle', 'modal'); uiwait;
    end		% end of while loop
    opSaveSoundDir = fullfile([p filesep]);
  end		% end of 'if (saveAs)'
  
  % Get the samples.
  t0 = iff(opSelect, opSelT0(opc), opT0);
  t1 = iff(opSelect, opSelT1(opc), opT1);
  s0 = max(0,        round(t0 * opSRate));
  s1 = min(opNSamp,  round(t1 * opSRate));
  x = opSoundIn(s0, s1-s0, opChans);

  if (strcmp(cmd, 'copy'))
    % Copy -- place in opSelection.
    opSelection = x;
    if (nargin < 2)
      warndlg(sprintf(['The current selection (%.1f s) is now ' ...
	      'in the global variable ''opSelection''.'], ...
	  length(opSelection) / opSRate));
    end

  else
    % Save As.  Save sound to a file.
    soundOut([p f], x, opSRate, 0, opNBits); % opNBits encoded as in soundOut.m
    printf('Saved %.1f s (%d samples) of sound in %s%s.', ...
	length(x) / opSRate, length(x), p, f);
  end
  
else
  error(['Osprey internal error: Unknown command ', cmd]);
  
end
