function opNextFile(direction)
% Go to the next or previous file in the current directory. 'direction' is
% either 'next' or 'prev'.

global uiInputButton opT0 opT1 opF0 opF1 opTMax opSRate		%#ok<GVMIS> 

% Get the list 'f' of files in this directory.
dirr = pathDir(opFileName);
f = dir(dirr);
f = f(~cellfun('isempty', {f.date}));	% remove invalid entries (bad symlinks)
% Remove . and ..
while (strcmp(f(1).name, '.') || strcmp(f(1).name, '..'))
  f(1) = [];
end

% Sort names into alphabetical order.
[~,alphaIx] = sort({f.name});
f = f(alphaIx);

% Find index of current file, so we can skip to the one after it.
ix = find(strcmp({f.name}, pathFile(opFileName)));
if (length(ix) ~= 1)
  error('Something strange happened: There are %d files named\n"%s" in the directory %s', ...
    length(ix), dirr);
end
  
% Get next/previous sound file.
incr = iff(strcmp(direction, 'next'), 1, -1);
while (1)
  ix = ix + incr;		% number of next/previous file in f
  if (ix < 1 || ix > length(f))
    window = uiInput({['You''ve reached the ' iff(ix<1, 'start', 'end') ...
      ' of the directory list.']
	['Wrap around to the ' iff(ix<1, 'end', 'start') '?']}, ...
	'Yes|No|Cancel', 'uiresume');
    set(window(1), 'WindowStyle', 'modal');
    uiwait(window(1))
    switch(uiInputButton)
      case 1	% yes
	ix = iff(ix < 1, length(f), 1);
      case {2 3}	% no, cancel
	return
    end
  end
  nextname = fullfile(dirr, f(ix).name);
  
  typ = soundFileType(nextname);
  if (~strcmp(typ, 'none'))
    break
  end
end

% Open next/prev file, preserving the duration currently visible in the window
% and the frequency bounds as well as possible. For 'next', go to the start of
% the new file; for 'prev', go to the end.
dur = opT1 - opT0; f0 = opF0; f1 = opF1;
[~,newSRate,newLeft] = soundIn(nextname, 0, 0);
newTMax = newLeft / newSRate;

newT0 = max(0,      iff(strcmp(direction, 'next'), 0, newTMax - dur));
newT1 = min(opTMax, iff(strcmp(direction, 'next'), newT0 + dur, newTMax));
newF1 = min(f1, newSRate/2);
newF0 = max(0, newF1 - (f1 - f0));	% preserve freq spread if now above nyq

osprey(nextname, [newT0 newT1 newF0 newF1])
% opT0 = max(0,      iff(strcmp(direction, 'next'), 0, opTMax - dur));
% opT1 = min(opTMax, iff(strcmp(direction, 'next'), opT0 + dur, opTMax));
% opF1 = min(f1, opSRate/2);
% opF0 = max(0, opF1 - (f1 - f0));	% preserve freq spread if now above nyq
% opRefresh(0,1)
