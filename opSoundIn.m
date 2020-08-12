function sig = opSoundIn(start, n, chans)
% samples = opSoundIn(start, n, channelnum)
%    Return n samples from the given channel(s) starting at the specified 
%    sample.  Sample numbering starts at 0 for the first sample in the file.
%    Channel numbering starts at 1.
%
% See also opSetFileInfo.

global opSignal

if (strcmp(opFileName('getsound'), ''))
  sig = opSignal(start+1 : start+n, chans);
else
  sig = soundIn(opFileName('getsound',1), start, n, chans-1);
end
