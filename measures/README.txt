
% How to make an Osprey measurement function:
%
% Define a function with seven input arguments and one output argument.  The
% first input arg to your function should be a string telling the function what
% to do; the later args depend on what this first arg is, as explained below.
% Place the m-file with your definition into the .../osprey/measures directory;
% Osprey will find it upon startup and use it.
%
% Here are the types of calls your function should handle.  'MyMeasure' is a
% dummy name, for which you should substitute your function name.
%
% y = MyMeasure('init')
%   Osprey makes this call when it starts up.  You should provide
%   information to Osprey about how to handle this measurement.  The
%   return value y should be a structure with these fields:
%	longName	(string) unique identifier; used internally, in the
%			    dialog box, and in preferences files
%	screenName	(string) the name the user sees on the screen; should
%			   be short (to fit in limited space) and lowercase
%	type		(string) 'simple', 'point', 'selection', or 'gramlet';
%			    see below.
%	fixTime		(bool) Is this a time measurement that is subject to
%			    adjustment for the starting time/date of the sound
%			    file?
%       unit		(string) name of unit; displayed after the value
%       sortIndex	(float) value used to order the measurements on screen;
%                           Osprey uses indices 1 through 19 in its main set,
%			    and 21 through 22 in its Acoustat set.
%       enabled		(bool; optional) should this measure be enabled when
%			    Osprey initially launches?
%
%   y may be a vector of structures (i.e., a 1xN structure array), in which
%   case it specifies that MyMeasure.m defines several measurements, one per
%   struct.  In later calls these are distinguished with the longName arg
%   below.
%
%   Osprey measurements are of four types:
%     'simple' measurements are those for which neither a point nor a selection
%	  (see below) are needed; examples are file length, channel number, and
%         sample rate.
%     'point' measurements are about a single point in the spectrogram, and are
%         what you get when you left-click with the mouse; examples are time,
%         frequency, and amplitude.
%     'selection' measurements are those for which a selection is needed, but
%	  the values of the spectrogram cells in the selection are irrelevant;
%         examples are start time, lower frequency, bandwidth, and duration.
%     'gramlet' measurements are those for which a selection is needed, and the
%	  values of the spectrogram cells in the selection DO matter; examples
%	  are peak time, center frequency, and energy.
%
% y = MyMeasure('measure', longName, clickTF, selTF, gramletTF, gramlet,params)
%   Calculate the measured value y.  longName is the name you gave in the
%   'init' call above, and in files that define more than one measurement, it
%   may be used to tell which measurement to make.  'clickTF' is the (T,F)
%   location the user last left-clicked on.  'selTF' has the T/F bounds of the
%   user selection, the precise points the user clicked on (which may be
%   fractions of gram cells), as [t0 f0 tEnd fEnd].  'gramletTF' has the T/F
%   bounds of the gramlet, which may be slightly larger than selTF because it
%   includes only whole spectrogram cells.  'gramlet' has spectrogram cells
%   that encompass the user selection, scaled with log().  (So to get power,
%   use exp(gramlet).^2 .) If there is currently no selection, then selTF,
%   gramletTF, and gramlet are all [].
%
%   'params' is a structure describing the spectrogram, with these fields:
%	sRate		sampling rate of time-series signal, samples/s (Hz)
%	frameRate	spectrogram frame rate, frames/s (Hz)
%	totalSamples	number of total samples in the whole file
%	frameSize	spectrogram frame size (samples of data per frame)
%	zeroPad		spectrogram zero pad size, as a fraction of frame size
%	FFTsize		equal to (frameSize + zeroPad*frameSize)
%	hopSize		spectrogram hop size, as a fraction of frame size; the
%                       overlap is (1 - hopSize)
%	winType		window function, e.g. 'Hann', 'Hamming', etc.
%	binBW		spectrogram bin bandwidth, Hz
%	channel		channel number within a multichannel file; starts at 1
%	nLogs		number of entries in datalog
%   All of these fields except winType are numeric.
%
%   The return value y is the value of this measurement (so far, all 
%   measurements are numeric; not sure if this will change).
%
% See also opMeasure, which calls this, and CentroidTime, which is an example.
% See also mainSet, which defines a large set of measures.
