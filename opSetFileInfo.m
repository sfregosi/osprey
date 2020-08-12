function opSetFileInfo(filename, srate)
% opSetFileInfo(filename [,sRate])
%    For the given file, find out the sampling rate, the number of samples,
%    and the file type.
%
%    The filename may optionally be a 2-row array, with the second row
%    containing the sampling rate as a binary-file 'b' extension.
%    See osprey.m or soundIn.m for further explanation.
%
%    If the 'filename' is really a vector of samples, squirrel them away for
%    later use (see opSoundIn).  In this case the sampling rate must be 
%    specified as the second argument.
%
% See also opSoundIn.

global opSRate opNSamp opChans opTMax opNChans opSignal opNBits
global opDateTime opUseDateTime opDateFix opSelT0 opSelT1 opSelF0 opSelF1

if (~ischar(filename))
  if (length(filename) < 64)
    error('You need to use either a file name or a reasonably long vector of samples.');
  end

  % User handed in a signal, rather than a file name.
  opSignal = filename;
  
  % Make sure it's columnar.
  if (nRows(opSignal) < nCols(opSignal))
    opSignal = opSignal.';
  end
  
  opFileName('setsound', '');		% blank filename means use opSignal
  opSRate  = srate;
  opNSamp  = nRows(opSignal);
  opTMax   = opNSamp / opSRate;
  opNChans = nCols(opSignal);
  
  % Set up opNBits.
  m = max(abs(opSignal));
  opNBits = 8 * ceil((log2(m) + 1) / 8);	% +1 handles positive/negative
  if (opNBits > 32)
    opNBits = -32;				% negative: floating-point
  end

else
  % File name.  Set up params.
  [~,opSRate,opNSamp,opNChans,opDateTime,opNBits] = soundIn(filename, 0, 0);
  if (isempty(opDateTime)), opDateTime = 0; end
  opDateFix = iff(opUseDateTime, mod(opDateTime, 1) * secPerDay, 0);
  opTMax = opNSamp / opSRate;
  valid = (opSRate > 0);
  opFileName('setsound', iff(valid, filename, ''));
  
  if (valid == 0)
    error('Sound file %s has a bad sample rate of %f', filename(1,:), opSRate);
  end
end

opChans  = 1 : opNChans;		% display all channels to start with
[opSelT0,opSelF0] = deal(zeros(1,opNChans));
[opSelT1,opSelF1] = deal(-ones(1,opNChans));
