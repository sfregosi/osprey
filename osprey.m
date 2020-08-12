function osprey(varargin)
%OSPREY      Display and measure spectrograms of sound files
%
% This is Osprey version 1.8, dated 10-May-2013.
%
% Osprey is a spectrogram viewer that allows manipulation of a sound 
% spectrogram in various ways.  A more detailed explanation, including 
% where to get it, how to run it, and how to troubleshoot it, is found in
% the file "0sprey Documentation - READ ME.txt" in the osprey directory.
% Type 'osprey help' at the MATLAB command prompt to see this file.
%
% There are several ways to start up Osprey:
%
%    osprey
%    osprey help                           this opens the documentation
%    osprey filename.ext
%    osprey('filename.ext')
%    osprey('"filename.ext"')		   Osprey will remove the double quotes
%    osprey('filename', 'type')            where 'type' is 'WAV', 'AIF', etc.
%    osprey('filename', samplingrate)
%    osprey(samplevector, samplingrate)
%    osprey('filename', [T0 T1])           show time in file from T0 to T1 (sec)
%    osprey('filename', [T0 T1 F0 F1])     also set frequency bounds F0,F1 (Hz)
%    osprey('filename', [T0 T1 F0 F1 sT0 sT1 sF0 sF1])     also show a selection
%                                          with those time/frequency bounds
%
% The simplest way to start Osprey is just to type "osprey" at a MATLAB prompt,
% then pick a sound file in the dialog box that shows up.  You can also type
% "osprey filename.ext" to start it up looking at a file named filename.ext.
%
% Osprey determines the sound file type from the file extension. If your file
% name does not have an extension, you start Osprey with two arguments: the
% first is the file name, and the second is an extension specifying the file
% type.  For instance, "osprey('myfile','aif')" would start up Osprey on the
% AIFF file 'myfile'.  The case of the extension doesn't matter.
%
% If you use binary files of linear 16-bit mono samples, then you can
% type "osprey('filename', samplingRate)" to specify the file name and
% sampling rate of the file.  For example, "osprey('myfile', 800)"
% will start up Osprey with a binary file sampled at 800 Hz.
%
% Finally, you can start up Osprey on a vector of samples.  In this case,
% the second argument passed in must be the sampling rate, like this:
%           osprey(samplevector, samplingrate)
%
% For more extensive help, please type 'osprey help' at the MATLAB command
% prompt.

global opOspreyDir opT0 opT1 opF0 opF1 opSelT0 opSelT1 opSelF0 opSelF1

opOspreyDir = fileparts(mfilename('fullpath'));		% Osprey directory
udir = fullfile(opOspreyDir, 'utils');
if (~exist('nRows.m', 'file') && exist(udir, 'dir')), addpath(udir); end
ldir = fullfile(opOspreyDir, 'loc');
if (~exist('allPairs.m', 'file') && exist(ldir, 'dir')), addpath(ldir); end

if (~exist('gexist4.m','file'))
  disp(' ')
  disp('Osprey cannot access its "utils" directory.  Make sure that this')
  disp('directory is installed and accessible; it''s typically in the osprey')
  disp('directory.')
  return
end

if (nargin < 1)
  opOpen('open');
  return
end

newZoom = [];
arg1 = varargin{1};

if (ischar(arg1) && strcmp(arg1, 'help'))
  fprintf(1, '\n\n======================================================\n\n');
  help osprey/osprey
  edit('0sprey Documentation - READ ME.txt')
  return
end

if (~ischar(arg1))
  % User passed in a signal as arg1. Second arg (sample rate) is required.
  signal = arg1;
  if (nargin < 2)
    disp(' ')
    disp('When passing a signal for osprey to display, you must also specify')
    disp('the sampling rate in samples/s.  Like this:  osprey(myvector, 44100)')
    disp(' ')
    return
  end
  srate = varargin{2};
else
  % User passed in a filename as arg1.
  filename = arg1;
  
  if (nargin >= 2)
    arg2 = varargin{2};
    if (ischar(arg2))
      % Handle multiple input args coming from space(s) in filename. But DON'T
      % do this if arg2 is a sound file type like 'WAV'.
      isExt = ~any(arg2=='.') && ~strcmp(soundFileType(['.' arg2]), 'none');
      if (nargin >= 3 || ~isExt)
	for i = 2 : nargin
	  filename = [filename ' ' varargin{i}];		%#ok<AGROW>
	end
      else
	ext = ['type=' arg2];		% second arg is extension
	filename = char(string(filename), string(ext));% makes 2-row char array
      end
    elseif (isnumeric(arg2) && isscalar(arg2))
      % Second arg is sample rate.
      srate = arg2;
      r = rem(srate, 100);
      ext = sprintf(['type=b%d' iff(r > 0, '_%d', '')], floor(srate/100), r);
      filename = char(string(filename), string(ext)); % makes 2-row char array
    elseif (isnumeric(arg2))
      % Second arg is vector with [T0 T1], optional [F0 F1], and optional
      % [selT0 selT1 selF0 selF1]. Zoom to it.
      doZoom = true;
      newZoom = arg2;
    end
  end
  
  % Remove any double-quote marks from start and end of filename.  This is here
  % because Windows has a nice "Copy as path name" feature (shift-rightclick on
  % a file in Windows Explorer) which is useful for copying a sound file name
  % into the MATLAB command window, but Windows adds these quote marks.
  if (filename(1,1) == '"' && filename(1,end) == '"')
    filename(1, 1:end-2) = filename(1, 2:end-1);
    filename = filename(:, 1:end-2);
  end
end

if (~opMultiLog('checknewfile'))
  return
end

opMeasure('init');			% initialize the measurements
opNewSignal;				% initialize most parameters
if (ischar(arg1))
  opSetFileInfo(filename);		% set file info (name,srate,len,...)
else
  opSetFileInfo(signal, srate);	% set signal info (name,srate,len,...)
end
f = opFileName('getsound');		% get filename, or '' for sample vector

% Start up display
opInitialFrame;				% initial time and freq bounds
opRedraw('repaint', f, 1);		% compute spect, paint window
opPlay('setratetext');			% set up popup

% Set the popups to the current settings.
opDataSizeF('setpopup');
opZeroPadF('setpopup');
opHopSizeF('setpopup');
opWinTypeF('setpopup');
opChannel('makemenu');

if (~isempty(newZoom))
  opT0 = newZoom(1); opT1 = newZoom(2);
  if (length(newZoom) >= 4), opF0 = newZoom(3); opF1 = newZoom(4); end
  if (length(newZoom) >= 8)
    opSelT0 = newZoom(5); opSelT1 = newZoom(6);
    opSelF0 = newZoom(7); opSelF1 = newZoom(8);
  end
  opRefChan(1,1);
else
  opPrefSave('doautoload')
end
