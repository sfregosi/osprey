% This is an example of making measurements in Osprey automatically, i.e.,
% from a list of start- and end-times and frequency bounds at which the
% measurements should be made.
%
% To use this, start up Osprey and set it up with the measurements you want to
% make (see Preferences->Measurements). Fix the configuration part of the code
% below and then run the code.
%
% The result is written to the text file named by outputLog, and is also in the
% variable 'measurements'. It represents the current set of Osprey measurements
% made on the list of times in timesToMeasure.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configuration                                                         %
%    The configuration section needs to set these variables:
%       inputSound -- the name of the sound file to measure
%       outputLog  -- the name of the file to write the result to
%       timesToMeasure -- a 2-column array with start- & end-times of calls
%       freqToMeasure  -- a 2-column array the same size as timesToMeasure with
%                         low & high frequencies of calls
%
% Note that freqsToMeasure can also be a 2-element vector of frequencies, in 
% which case these frequencies are used for measuring all calls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (1)			% use "if (1)" to enable this part, "if (0)" to disable
  % Here's an example if reading an existing log file to get times and freqs.
  inputSound     = 'C:\deleteMe\test.wav';
  inputLog       = [pathRoot(inputSound) '.txt'];	% C:\deleteMe\test.txt
  outputLog      = [pathRoot(inputSound) '_NEW.txt'];
  x              = loadascii(inputLog);
  freqsToMeasure = x(:,3:4);  % assumes start- and end-freqs are columns 3 and 4
  timesToMeasure = x(:,1:2);  % assumes start- and end-times are columns 1 and 2
else
  % Here's an example where times and frequencies are listed here manually.
  inputSound     = 'C:\deleteMe\test.wav';
  outputLog      = [pathRoot(inputSound) '_LOG.txt'];
  timesToMeasure = [
      2      3.3
      5.5    9
      8.9    9.8
      12.1   13.20
      ];
  freqsToMeasure = [800 1500];	% these bounds are used for measuring all calls
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        end of configuration                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Now make the measurements and save them in outputLog.
% First open the sound file in Osprey.
osprey(inputSound)

% Make the measurements.
measurements = opMeasure('measure', timesToMeasure, freqsToMeasure);
printf('Re-measured %d calls.', nRows(measurements))

% Save the result in the outputLog text file.
printf('Saving.')
fd = fopen(outputLog, 'wt');
fprintf(fd, '%%');		% make it easy for MATLAB to re-read outputLog
opDataLog('showheader', fd)	% write measurement names to outputLog
for i = 1 : nRows(measurements)
    fprintf(fd, '%s\n', sprintf('%15.5f\t', measurements(i,:)));
end
fclose(fd);
