
% Declare all of the global variables.  This is useful when debugging:
% just type opGlobals to make them all accessible.

% Comments starting with () mean the variable is a vector or N-D array,
% with one value per channel.
% 

global opc		% current selected channel number           
global opAxes		% () axes objects for grams (invisible? see opChans)
global opBackgroundColor% color of 'gram near t=0 or f=Nyquist
global opBrightness	% current setting of the brightness slider
global opBrightReverse	% in colormap, are low values bright (0) or dark (1)?
global opAmpCalib	% time-series sample amplitude scaling, uPa/count
global opChans		% () channel number(s) currently displayed (sorted)
global opColor 		% highlight color
global opColorDepth	% depth of highlighting
global opColorMapName	% function name for generating colormap, e.g. 'gray'
global opContrast	% current setting of the contrast slider
global opControls	% vector of control objects (buttons, sliders, etc.)
global opDataSize	% samples per spect frame
global opDateTime	% date/time of file start, datenum format
global opDateFix        % == iff(opUseDateTime, mod(opDateTime,1)*secPerDay, 0)
global opDefaultWinPos	% size of brand-new windows, [left bot wide high]
global opEpsDir		% dir to save EPS files in
global opEpsMargin	% print margin around EPS images
global opF0 opT0	% portion of the signal on-screen
global opF1 opT1
global opFileMenu       % menu-bar 'File' menu (to test existence of menus)
global opFixedButtons % have fixed non-painting button faces? opRefChan.m
global opFreqDiv	% amount Y-axis ticks were divided by for metric prefix
global opGramFrac	% fraction of avail. image area used by gram (vs. wvf)
global opHCrunchIcon	% that image of a hand squashing the Z
global opHiLimit	% max value displayable via colormap hacks
global opHopSize	% hop size factor, default 1/2
global opHScrollSkip	% amount of image motion for click in h scroll bar
global opHZoomIcon	% that image of a hand stretching the Z
global opIconColorMap	% six-element colormap for the zoom/crunch hand icon
global opImageButtons	% horz/vert buttons for zoom/crunch
global opInhibitRedraw  % prevents circularity in opMenus.m
global opLastClick	% last point clicked with mouse, [x y]
global opLog		% data log values
global opLogFreq	% display logarithmic frequency axis?
global opLogPrev	% set of measures for current values in data log
global opLogChanged	% 1 if log has changed since last save
global opLoLimit	% min value displayable via colormap hacks
global opMeas		% struct vector of measures for currently selected chan
global opMeasurePos	% vector of [left top] values for display
global opMousePos	% position of last left-mouse click, as [t f]
global opNBits		% bits of precision in input file; neg means floating
global opNChans		% number of channels in sound file
global opNonSelCount	% number of non-datalog right clicks in a row
global opNorm		% normalize? must be set by hand; see opComputeSpect
global opNSamp		% number of smaples in the sound
global opOspreyDir	% full path of the directory osprey.m was launched from
global opPlayCorrection % correction factor to fix Matlab/soundcard interface bug
global opPlayRate	% playback rate number (popup choice - 1)
global opPlayOthers	% extra user-specified play rate factors, initially []
global opPrefDir	% directory prefs were last saved/loaded in
global opPrintLabel	% print a label below the spectrogram?
global opPrintMargin	% size of margin (inches) around edges of printed page
global opPsType		% prefSave: window size/duration/scaling interactions
global opPsWin		% the 'save prefs' dialog box
global opPsWinPos	% position of former opPsWin
global opPsButton	% buttons on the 'save prefs' dialog box
global opPsName		% names for the opPsButtons
global opPsValue	% values (0 or 1) to initialize opPsButtons with
global opSelT0 opSelF0	% selection box
global opSelT1 opSelF1
global opShowFreq	% show 'frequency, Hz' on Y-axis?
global opShowTime	% show 'time, s' on X-axis?
global opShowUnits	% show 'Hz' and 's' at ends of axes?
global opShowWvf	% flag: show the waveform?
global opSignal		% for showing sample vector instead of file of samples
global opSoundFile1	% chan 1 sound file name; also opSoundFile2, 3, ..., 8
global opSpectVec	% last spectrum displayed
global opSpectFreqs	% frequency of each corresponding point in opSpectVec
global opSRate		% sampling rate, samples/s
global opTextExt	% extension to use for text log files (opDataLog.m)
global opTimedLocArray	% structure for moving phone arrays
global opTitlePrefix	% gets prepended to name of window
global opTMax		% the end of time for the current file
global opUseDateTime	% show time/date on axes (1) or seconds after SOF (0) ?
global opVCrunchIcon	% that image of a hand squashing the Z
global opVScrollSkip	% amount of image motion for click in v scroll bar
global opVZoomIcon	% that image of a hand stretching the Z
global opWinType	% 1=kaiser, 2=bartlett, etc.  See opWinTypeF.
global opWvfAxes	% axis object for waveform
global opZeroPad	% zero pad factor, default 0
global opZoomIcon	% that image of hand stretching the Z (qv opCrunchIcon)

% User interface objects.
global opDataSizePopup opHopSizePopup opZeroPadPopup opWinTypePopup
global opHScrollBar opVScrollBar opContrastSlider opBrightnessSlider
global opFig opPlayBut opContrastText opBrightnessText opSliderValues
global opPlayRateMenu opMeasureTexts opMeasureNums opWindowAxes
global opHScrollMenu opVScrollMenu opPrefMenus opDataLogMenu opImages
global opChannelMenu						%#ok<*NUSED>
