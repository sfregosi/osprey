function opNextFile(direction)
% Go to the next or previous file in the current directory. 'direction' is
% either 'next' or 'prev'.

global uiInputButton

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
  ix = ix + incr;
  if (ix < 1 || ix > length(f))
    
    f = uiInput({['You''ve reached the ' iff(ix<1, 'start', 'end') ' of the directory list.']
	['Wrap around to the ' iff(ix<1, 'end', 'start') '?']}, ...
	'Yes|No|Cancel', 'uiresume');
    set(f(1), 'WindowStyle', 'modal');
    uiwait(f(1))
    switch(uiInputButton)
      case 1	% yes
	ix = iff(ix < 1, length(f), 1);
      case 2	% no
	return
      case 3	% cancel
	return
    end
  end
  nextname = fullfile(dirr, f(ix).name);
  
  typ = soundFileType(nextname);
  if (~strcmp(typ, 'none'))
    break
  end
end

osprey(nextname)
