function z = opFileName(cmd, x)
% opFileName('setsound', name)
%    Set the sound file name for the given channel.  If name is '', it
%    means either that we're still in the initialization stage and no
%    file name has been set yet, or that the user started up with a sound
%    signal instead of a sound file name; this is stored in opSignal.
%
% name = opFileName
% name = opFileName('getsound')
%    Return the sound file name.  This does NOT include the optional
%    second line containing the sampling rate.  If the name returned
%    is '', then the user started up with a signal instead of a file 
%    name, and the signal is in opSignal.
%
% name = opFileName('getsound', 1)
%    Return the sound file name set by opFileName('setsound', ...).
%    This includes both lines of the file name, if present (see osprey.m
%    or soundIn.m).

global opSoundFile1

if (nargin < 1), cmd = 'getsound'; end

if (strcmp(cmd, 'setsound'))
  opSoundFile1 = x;

elseif (strcmp(cmd, 'getsound'))
  z = opSoundFile1;
  if (~isempty(z) && (nargin < 2 || x==1))	% watch out for empty z
    z = z(1,:);					% first line only
  end

else
  error(['Unknown command: ' cmd]);
end
