function spect = opComputeSpect(chans, fr0, fr1)
% spect = opComputeSpect(chand, fr0, fr1)
% Compute spectrogram frames fr0 to fr1 inclusive.
% fr0=0 corresponds the first vertical strip in the spectrogram.
% The channel number(s) are in chans.
%
% Reads the sound file and returns a block (rectangular array) of the 
% spectrogram.

global opSRate opDataSize opHopSize opZeroPad opFig

%printf('Computing spect frames %g to %g.', fr0, fr1);

sRate   = opSRate;			% sampling rate
data    = opDataSize;			% number of samples in each frame
hop     = round(opHopSize * data);	% hop size, in samples, between frames
fRate   = sRate / hop;			% frame rate
pad     = opZeroPad * data;		% number of zeros to append before FFT
height	= (data + pad) / 2;		% number of cells in returned array
win     = opWinTypeF(data);	 	% window function; column vec

% Figure out which samples to get from the sound file: s0 is the starting
% sample number, n is the total number of samples.
%s0	= round((fr0-1)*hop - data/2 + hop/2);	% adjust for warm-up time
s0 = round((fr0-1)*hop);
n = data + (fr1 - fr0) * hop;

% Read the sound samples.
sams = opSoundIn(max(s0,0), n, chans);	% size: nsam x nchan

% Adjust for warm-up time at the start of the sound file.
%if (s0 < 0), sams = [zeros(1,-s0), sams]; end	% adjust for warm-up time


% Compute the spectrogram.  
% First make an empty array for MATLAB speed.
spect = zeros(height, fr1-fr0+1, length(chans));

padSeq = zeros(pad, length(chans));
scale = sqrt(data / 256);		% intensity scaling factor
win1 = repmat(win, 1, length(chans));
for f = 0 : fr1-fr0
  x = sams(f*hop + 1 : f*hop + data, :);
  if (pad > 0), x = x - repmat(mean(x,1), nRows(x), 1); end
  res = fft([x.*win1; padSeq]) / scale;
  spect(:,f+1,:) = res(1:height,:);
end
s = warning('off', 'MATLAB:log:logOfZero');	% prevent 'log of 0' warnings
spect = log(abs(spect));
if (0)
  % Display graph of (sorted) cell intensity.
  figure(3)
  plot(linspace(0,100,numel(spect)), sort(spect(:)))    % noise percentiles
  xlabel('percentile')
  ylabel('spectrogram value')
  wysiwyg
  spect = max(0, spect - 1.333 * percentile(spect(:), 0.50));
end
warning(s)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spectrogram normalization.  All of the stuff below here is for various hacks
% that I've done to alter the normal Osprey display.  They can all be turned
% off.
global opNP opNorm
if (~gexist4('opNorm')), opNorm = 0; end
if (opNorm)
  if (1)
    % The usual cases.
    %outsuffix = 'fin-Q';  singerParams	 % get freqs, normp (=decay time)
    %outsuffix = 'blue-C'; singerParams	 % get freqs, normp (=decay time)
    %outsuffix = 'blue-I'; singerParams	 % get freqs, normp (=decay time)
    %outsuffix = 'blue-N'; singerParams	 % get freqs, normp (=decay time)
    %outsuffix = 'minke-C'; singerParams % get freqs, normp (=decay time)
    %outsuffix = 'Ptree-A'; singerParams % get freqs, normp (=decay time)
    %outsuffix = 'Pv-A'; singerParams	 % get normp (=decay time)

    % this one was active before the spermGoa one; for HSeal paper
    %outsuffix = 'Pv-C'; singerParams	 % get normp (=decay time)

    %outsuffix = 'RW-a'; singerParams    % get normp (several params)
    %outsuffix = 'RW-b'; singerParams    % get normp (several params)
    %outsuffix = 'RW-c'; singerParams    % get normp (several params)
    %outsuffix = 'sp1'; singerParams      % get normp etc.; for spermGoa paper
    %normp = 100;  freqs = [];  disp('Using special Pacific blue whale normp.')
    %normp = 200;  freqs = [];  disp('Using special minke normp.');
    %normp = 10;
    %normp = 0.5;	% for CommonDolphin
    %normp = 2;		% for bottlenose dolphin
    %normp = 0.5;	% for woodcocks
    %normp = 500;
    %normp = 20; 	% for blueNEP
    %normp = 10; 	% for Scotia RWs
    %normp = 0.5;	% for Ivory-billed Woodpecker double rap
    %normp = 1;		% orca whistles
    %normp = 0.001;	% Blainville's beaked whale clicks
    %normp = 0.0002;	% boings
    %normp = 3;	 	% for Kelly Newman's orcas
    %normp = 0.5; 	% for AUTEC sperm whales
    normp = 1.0;	% Grampus burst pulses
%     normp = [		% for orcas
% 	've'+0 1 0 0 200	% "vertical" noise removal, rate=200 Hz
% 	'e'+0 1 0 0 10.0 0];	% "horizontal" noise removal, rate = 10 sec
%     normp = [		% bottlenose click removal (palmyra092007FS192-070924-205305)
% 	've'+0 1 0 0 4000	% "vertical" noise removal
% 	'e'+0 1 0 0 2.0 0];	% "horizontal" noise removal
%     normp = [		% bottlenose whistle removal (palmyra092007FS192-070924-205305)
% 	'e'+0 1 0 0 0.01 0];	% "horizontal" noise removal, rate = 10 sec
    %normp = [		% for harbor seals (
	%'ve'+0 1 0 0 400	% "vertical" noise removal, rate=400 Hz
	%'e'+0 1 0 0 20.0 0	% "horizontal" noise removal, rate = 10 sec
	%];
%     normp = [		% for harbor seals (
% 	've'+0 1 0 0 1000	% "vertical" noise removal, rate=1000 Hz
% 	'e'+0 1 0 0 20.0 0	% "horizontal" noise removal, rate = 10 sec
% 	];
%     normp = [		% for right whales
% 	'p'+0 1 0 1000 0.19 NaN 1.73 NaN
% 	];

    if (length(normp) == 1)
      normp = ['e'+0 1 0 0 normp];	% use this when normp is just a scalar
    end

    if (nRows(spect) ~= nRows(opNP)), opNP = []; end	% new gram params?
    [spect1,opNP] = normGram(spect, sRate, fRate, normp, opNP);

    if (0)
      % Hack for testing normalization for RWs.
      global opBrightness opContrast
      %%%lolim = -3.9573; hilim = -1.6550;
      %[lolim, hilim] = opColorMap('getlimits')
      minnie = log(1e-1);			% min displayable value
      maxie  = log(1e9);			% max displayable value
      span = 0.8;
      
      spSub = spect1(round(nRows(spect1)/10) : end, :); 
      pct = percentile(spSub(:), [0.85  0.99]);
      white = pct(1);
      black = (pct(2) - pct(1)) * 2 + pct(1);
      black = pct(2);
      ret0 =     ((black + white) - 2*minnie) / (maxie - minnie) / 2;% brightness
      ret1 = 1 - ((black - white)           ) / (maxie - minnie) ;   % contrast
      
      wht = white; blk = black;
      
%       brt = opBrightness;
%       con = 1 - opContrast;
%       wht = (maxie - minnie) * (brt - con/2 * span) + minnie;
%       blk = (maxie - minnie) * (brt + con/2 * span) + minnie;
      %lolim = (log(1e9) - log(1e-1)) * (opBrightness - opContrast/2) + log(1e-1);
      %hilim = (log(1e9) - log(1e-1)) * (opBrightness + opContrast/2) + log(1e-1);
      
      sp2 = min(1, max(0, spect1 - wht) / (blk - wht));
      figure(2); clf; drawnow; pause(0.5)
      imagesc([0 3], [0 1000], sp2); 
      colormap(flipud(gray)); 
      set(gca,'YDir','normal', 'YLim', [50 300])
      figure(opFig)
    end
    
  else
    % Harbor seal test cases.
    disp('opComputeSpect: special deal for snapping shrimp noise reduction')
    
    % These are obsolete:
    %normp = ['vp'+0 1 NaN NaN 0.8 0.9];
    %normp = [normp 0; 've'+0 0 0 0 500]
    %normp = [normp 0 0; 'vp'+0 1 0 inf 0.4 0.9]
    %normp = ['ve'+0 1 0 0 500]
    %normp = ['p'+0 1 NaN NaN 0.5 1];
    
    % Choose one or more from menu below:
    if (1)
      %normp = ['p'+0 0 100 2000 0.2 NaN 1.2];disp('overall normPct+zeroing..')
      normp = ['p'+0 1 100 2000 0.2 NaN]; disp('per-freq normPct...')
      spect = normGram(spect, sRate, fRate, normp);
      z = (spect(:) < 0); spect(z) = zeros(sum(z), 1);	% zero out values < 0
    end
    if (0) 
      normp = ['s'+0 1500 3000 0.35];
      disp('normSub...')
      spect = normGram(spect, sRate, fRate, normp);
    end
    if (0)
      normp = ['m'+0 0.12 0.30];		% seems to work well
      %normp = ['m'+0 0.16 0.30];
      disp('normMedian...')
      spect = normGram(spect, sRate, fRate, normp);
    end
    if (0)
      normp = ['p'+0 0 100 800 NaN 0.96]; disp('normPct scaling...')
      spect = normGram(spect, sRate, fRate, normp);
      z = (spect(:) > 1); spect(z) = ones(sum(z), 1);	% force cells >1 to 1
    end
    if (1)
      disp('vertical normExping, with hacked gram...')
      normp = ['ve'+0 1 0 0 1000 NaN NaN NaN 1];
      hiBin = round(2500 / ((sRate/2)/nRows(spect)));	% MBARI hseal project
      %hiBin = round(3000 / ((sRate/2)/nRows(spect)));	% POMA paper
      s1 = spect(1 : hiBin, :);
      [s1,opNP] = normGram(s1, sRate, fRate, normp, opNP);
      s1(s1 < 0) = zeros(1, sum(sum(s1 < 0)));
      spect = [s1; spect(hiBin+1 : nRows(spect), :)];
    end
    if (1)
      disp('horizontal normMedian...')
      normp = ['m'+0 0.12 0.30];		% seems to work well
      %normp = ['m'+0 0.16 0.30];
      spect = normGram(spect, sRate, fRate, normp);
    end
    if (0)
      disp('vertical normMedian...')
      normp = ['vm'+0 150 0.30];
      spect = normGram(spect, sRate, fRate, normp);
    end
    global opSealSpect
    opSealSpect = spect;

    opNP = [];		% use non-warmed-up AGC every time
    
    if (0)
      disp('(B) special deal for snapping shrimp noise reduction')
      z = (spect(:) < 0); spect(z) = zeros(sum(z), 1);	% zero out values < 0
    end
    spect1 = spect;
    global opSpect
    opSpect = spect1;
  end
  
  if (bitand(opNorm,1))		% '1' bit means display normalized spect
    spect = spect1;
  end
  if (bitand(opNorm,2))		% '2' bit means call findetect
    eval('findetect(spect1, freqs, sRate, fRate);')
    figure(opFig);		% bring focus back to Opsrey window
  end
  if (bitand(opNorm,4))		% '4' bit means call sealsum
    disp('opComputeSpect: Energy sum...')
    eval('sealsum(spect1, sRate, fRate);')
    figure(opFig);		% bring focus back to Opsrey window
  end
end
