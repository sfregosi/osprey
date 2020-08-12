function opNewSignal
% opNewSignal
%    Initialize things for a new file or signal, and make it
%    the current one.  Nothing is known about the new sound yet.

global opc opChans opF0 opF1 opT0 opT1 opSRate opNSamp opMousePos
global opSelT0 opSelT1 opSelF0 opSelF1 
global opBrightness opContrast opBrightReverse opLoLimit opHiLimit
global opHScrollSkip opVScrollSkip opLastClick opEpsMargin opPrintRes
global opColorDepth opColor opPrintMargin opTMax opPlayRate
global opDefaultWinPos opColorMapName opPrintLabel opPlayCorrection
global opDateTime opUseDateTime opDateFix opShowUnits opShowTime opShowFreq
global opShowWvf opGramFrac opLinkedFigs opSepMeasWin opTabDelimitLogs
global opPrintPos opPrintPortrait opLogFreq opInhibitDisp opAmpCalib
global opShowLocMap opLocMapSize opLastLoc opShowXCorr opTimedLocArray

%opMultiLog('clearall!');       % sets opLog=[], opLogChanged = 0;

opc = 1;
opChans = 1;			% this gets fixed later on

% Set the popup data to the default values.
if (opExists < 2)
  opHopSizeF('default');
  opWinTypeF('default');
  opDataSizeF('default');
  opZeroPadF('default');
end

% assume new channel number is previous one plus 1
opFileName('setsound','');
opF0		= 0;  opF1 = 100;
opT0		= 0;  opT1 = 100;
opSelF0		= 0;  opSelF1 = -1;
opSelT0		= 0;  opSelT1 = -1;
opSRate		= 100;
opNSamp		= 100;
opTMax		= 1;
opContrast	= 0.5;
opBrightness	= 0.5;
opBrightReverse = 0;
opLoLimit	= 0;
opHiLimit	= 0;
if (~gexist4('opPlayRate')), opPlayRate = 5; end
opMousePos = [Inf Inf];				% flag value: no click yet
opCache('clear');
if (~gexist4('opHScrollSkip')),	opHScrollSkip = 0.75;		 end
if (~gexist4('opVScrollSkip')),	opVScrollSkip = 0.5;		 end
if (~gexist4('opColor')), 	opColor = [1 1 0];		 end
if (~gexist4('opColorDepth')),	opColorDepth  = 0.4;		 end
if (~gexist4('opColorMapName')),opColorMapName='hot(n)';	 end
if (~gexist4('opPrintMargin')),	opPrintMargin = [1.0 1.0 .5 .5]; end  % L,B,R,T
if (~gexist4('opPrintPos')),	opPrintPos = {'center' 'middle'};end
if (~gexist4('opPrintPortrait')),opPrintPortrait = false;	 end
if (~gexist4('opEpsMargin')),	opEpsMargin = [0.8 0.4 0 0];	 end  % L,B,R,T
if (~gexist4('opPrintRes')),	opPrintRes = '-r600';		 end  % dpi
if (~gexist4('opPrintLabel')),	opPrintLabel = 1;		 end
if (~gexist4('opShowUnits')),	opShowUnits = 0;		 end
if (~gexist4('opShowTime')),	opShowTime = 1;			 end
if (~gexist4('opShowFreq')),	opShowFreq = 1;			 end
if (~gexist4('opUseDateTime')),	opUseDateTime = 0;		 end
if (~gexist4('opPlayCorrection')), opPlayCorrection = opGetPcCorrection; end
if (~gexist4('opShowWvf')),	opShowWvf = 0;			 end
if (~gexist4('opGramFrac')),	opGramFrac = 0.7;		 end
if (~gexist4('opLinkedFigs')),	opLinkedFigs = [];		 end
if (~gexist4('opSepMeasWin')),	opSepMeasWin = 0;		 end
if (~gexist4('opTabDelimitLogs')), opTabDelimitLogs = 1;	 end
if (~gexist4('opLogFreq')),     opLogFreq = 0;			 end
if (~gexist4('opInhibitDisp')), opInhibitDisp = 0;		 end
if (~gexist4('opAmpCalib')),	opAmpCalib = nan;		 end
if (~gexist4('opShowLocMap')),  opShowLocMap = false;		 end
if (~gexist4('opLocMapSize')),  opLocMapSize = 10000;		 end  % m
if (~gexist4('opShowXCorr')),	opShowXCorr = false;		 end
if (~gexist4('opTimedLocArray')), opTimedLocArray = struct('enabled', 'false'); end

opLastClick     = [];
opDefaultWinPos = [30 100 800 400];		% size of brand-new window
opDateTime      = 0;
opDateFix       = 0;
opLastLoc	= [];
