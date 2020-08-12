function y = MLNSmeasures(cmd, name, clickTF, selTF, gramletTF, gramlet,params)
%MLNSmeasures	Osprey measures for the Macaulay Library of Natural Sounds
%
%   This function implements the set of measures for the Macaulay Library 
%   of Natural Sounds.  These measures, based on Acoustat (see AcoustatSet.m), 
%   are designed to be relatively independent of the background noise level, 
%   so that clear and faint vocalizations will tend to have similar
%   measurement values.  Many of the measurements here are based on
%   weighting spectrogram cells by the intensity of the sound present.
%
%   See README.txt in this directory for the calling convention and args.
%   See also AcoustatSet.m.
%
%   Note: In adding these to Osprey, I changed ./mainSet.m so that the
%   'enabled' field is initialized to all 0's, and also changed 
%   opPositionControls just after the 'Brightness and contrast sliders'
%   comment so that left has 82 added instead of 52; also changed the
%   calculation and later adjustment of s0 in opComputeSpect.
%
% Dave Mellinger
% 4/2006

global MLNS_params MLNS_values MLcache MLNS_UseLegacyMethod

switch(cmd)
case 'init'
  % The init structure is a global for later access.
  MLNS_params = struct(...
      'longName',{	'M1 Start Time'				...
      			'M2 End Time'				...
      			'M3 Lower Frequency'			...
      			'M4 Upper Frequency'			...
      			'M5 Duration'				...
      			'M6 Bandwidth'				...
      			'M7 Median Time'			...
      			'M8 Temporal Interquartile Range'	...
      			'M9 Temporal Concentration'		...
      			'M10 Temporal Asymmetry'		...
      			'M11 Median Frequency'			...
      			'M12 Spectral Interquartile Range'	...
      			'M13 Spectral Concentration'		...
      			'M14 Spectral Asymmetry'		...
      			'M15 Time of Peak Cell Intensity'	...
      			'M16 Relative Time of Peak Cell Intensity'	...
      			'M17 Time of Peak Overall Intensity'	...
      			'M18 Relative Time of Peak Overall Intensity'	...
      			'M19 Frequency of Peak Cell Intensity'	...
      			'M20 Frequency of Peak Overall Intensity'	...
      			'M21 Amplitude Modulation Rate'		...
      			'M22 Variation in AM Rate'		...
      			'M23 Frequency Modulation Rate'		...
      			'M24 Variation in FM Rate'		...
      			'M25 Average Cepstrum Peak Width'	...
      			'M26 Overall Entropy'			...
      			'M27 Upsweep Mean'			...
      			'M28 Upsweep Fraction'			...
      			'M29 Signal-to-Noise Ratio'		...
	      }, ...
      'screenName',{	'Start Time'		...
      			'End Time'		...
      			'Lower Freq'		...
      			'Upper Freq'		...
      			'Duration'		...
      			'Bandwidth'		...
      			'Median Time'		...
      			'Time Quart.'		...
      			'Time Concent.'		...
      			'Time Asymm.'		...
      			'Median Freq'		...
      			'Freq. Quart.'		...
      			'Freq. Concent.'	...
      			'Freq. Asymm.'		...
      			'Pk Cell T'		...
      			'Pk Cell Rel T'		...
      			'Pk Overall T'		...
      			'Pk Overall Rel T'	...
      			'Pk Cell F'		...
      			'Pk Overall F'		...
      			'AM Rate'		...
      			'AM Rate Var.'		...
      			'FM Rate'		...
      			'FM Rate Var.'		...
      			'Cepstrum Width'	...
      			'Entropy'		...
      			'Upsweep Mean'		...
      			'Upsweep Frac'		...
			'MSNR'			...
	      }, ...
      'unit', { 's'		's'		'Hz'		'Hz'...
		's'		'Hz'		's'		's'...
		's'		''		'Hz'		'Hz'...
		'Hz'		''		's'		'%'...
		's'		'%'		'Hz'		'Hz'...
		'Hz'		'?'		'Hz'		'?'...
		'Hz'		'Hz'		'Hz'		'%'...
		'dB'
              }, ...
      'type', {	'gramlet'	'gramlet'	'gramlet'	'gramlet' ...
      		'gramlet'	'gramlet'	'gramlet'	'gramlet' ...
      		'gramlet'	'gramlet'	'gramlet'	'gramlet' ...
      		'gramlet'	'gramlet'	'gramlet'	'gramlet' ...
      		'gramlet'	'gramlet'	'gramlet'	'gramlet' ...
      		'gramlet'	'gramlet'	'gramlet'	'gramlet' ...
      		'gramlet'	'gramlet'	'gramlet'	'gramlet' ...
      		'gramlet' ...
	      }, ...
      'needSel',   num2cell('11111111111111111111111111111' - '0'), ...
      'needGram',  num2cell('11111111111111111111111111111' - '0'), ...
      'fixTime',   num2cell('00000000000000000000000000000' - '0'), ...
      'enabled',   num2cell('00000000000000000000000000000' - '0'), ...
      ...%'enabled',   num2cell('11111111111111111111111111111' - '0'), ...
      'sortIndex', num2cell(100:128) );

  y = MLNS_params;		% return value

case 'measure'
  % Osprey calls this routine one time for each measurement.  But this code
  % makes all of the measurements at once.  To prevent it from calculating all
  % the measurements multiple times, we cache the measurements the first time,
  % and then on successive measurements, just retrieve the cached values.
  %
  % Note that ALL of the measurements are cached, even if the user is 
  % displaying only some of them.  This is somewhat inefficient.

  % First check to see if this is the same measurement as last time by 
  % comparing some of the parameters to cached values.
  c = { selTF, size(gramlet), ...
	  gramlet(1 : min(nRows(gramlet), 30), 1 : min(nCols(gramlet), 30)) };
  if (~isempty(MLcache) && all(c{1}==MLcache{1}) && all(c{2}==MLcache{2}) &&...
    all(all(c{3} == MLcache{3})))
    % We're measuring the same T/F box as last time.  Use saved values.
    M = MLNS_values;
  else
    % A new measurement is asked for.  Calculate measures.

    % First set up cache index so we know when the same T/F box is measured.
    MLcache = c;

    % Noise removal: Calculate backgroun noise as the 10th-percentile value of
    % all cells in gramlet. dnGramlet is de-noised gramlet.
    dnGramlet = gramlet - percentile(gramlet(:), 0.10);  % 0.10=10th pctile
    
    % Give things short names to keep code relatively compact.
    bx = gramletTF;
    lc = clickTF;
    amp = 20 / log(10);
    sel = selTF;
    if (~isempty(MLNS_UseLegacyMethod) && MLNS_UseLegacyMethod)
      gpow = exp(gramlet).^2;		% old way
    else
      gpow = exp(dnGramlet).^2;		% new, correct way (per Mellinger+Bradbury)
    end
    envT = sum(gpow, 1);		% time envelope
    envF = sum(gpow, 2);	  	% freq envelope (spectrum)
    binDur = 1 / params.frameRate;
    binBW  = params.binBW;
    theta = 0.90;			% threshold of energy in box
    
    M = zeros(1, length(MLNS_params));	% all measurements wanted
    
    % M1 Start Time, M2 End Time.
    [t1,ix] = sort(envT, 'descend');
    x = find(cumsum(t1) >= sum(envT) * theta);
    minTI = min(ix(1:x(1)));		% minimum index of cells in Feature Box
    maxTI = max(ix(1:x(1)));		% maximum index of cells in Feature Box
    M([1 2]) = ([minTI-1.5 maxTI-0.5]) * binDur + bx(1);	% convert to s
    
    if (0 && strcmp(name, 'M1 Start Time'))   % debug plots; use w/plots below
      figure(2); clf; subplot(211); hold on
      q=1:length(t1); plot(q,t1,'g', q,envT,'.', q,envT,'b')
      xlims fit; xlabel('time points')
      plot(xlims,t1(x(1))*[1 1],'g', [minTI minTI],ylims,'r', ...
	  [maxTI maxTI],ylims,'r')
    end
    
    % M3 Lower Frequency, M4 Upper Frequency.
    envF = max(envF, 0);			% positive entries in envF
    [f1,ix] = sort(envF, 'descend');
    x = find(cumsum(f1) >= sum(envF) * theta);
    minFI = min(ix(1:x(1)));		% minimum index of cells in Feature Box
    maxFI = max(ix(1:x(1)));		% maximum index of cells in Feature Box
    M([3 4]) = ([minFI-1.5 maxFI-0.5]) * binBW + bx(2);	% convert to Hz
    
    % NB: To show a line around the trimmed box in Osprey, enable the
    % debugging code in opMouseClick.  If we try to show the box here, it
    % gets wiped out by other Osprey redisplay.

    if (0 && strcmp(name, 'M3 Lower Frequency'))   % debug plots; use w/above
      subplot(212); hold on
      q=1:length(f1); plot(q,f1,'g', q,envF,'.', q,envF,'b')
      xlims fit; xlabel('freq points')
      plot(xlims,f1(x(1))*[1 1],'g', [minFI minFI],ylims,'r', ...
	  [maxFI maxFI],ylims,'r')
    end
    
    % M5 Duration, M6 Bandwidth.
    M([5 6]) = M([2 4]) - M([1 3]);
    
    % Now that we have the T/F box, trim to that size; also make trimmed
    % envelopes. tr stands for 'trimmed'.
    trGram = gpow(minFI : maxFI, minTI : maxTI);	% trimmed gram
    [trM,trN] = size(trGram);
    trEnvT = sum(trGram, 1);		% trimmed time envelope, row vector
    trEnvF = sum(trGram, 2);		% trimmed freq envelope, col vector
    trBx = [bx(1)+(minTI-1)*binDur bx(2)+(minFI-1)*binBW ...  % [t0 f0 t1 f1]
	    bx(1)+(maxTI-1)*binDur bx(2)+(maxFI-1)*binBW];
    
    % M7 Median Time.  qT has the quartiles for time.
    qT = cumFrac(trEnvT.', [0.25 0.50 0.75], trBx([1 3]));
    M(7) = qT(2);
    
    % M8 Temporal Interquartile Range.
    M(8) = qT(3) - qT(1);
    
    % M9 Temporal Concentration.
    [sortT,ixTsort] = sort(trEnvT);		% row vectors
    ixT = cumFrac(sortT.', 0.50);
    ixTMin = min(ixTsort(ceil(ixT) : end));
    ixTMax = max(ixTsort(ceil(ixT) : end));
    M(9) = (ixTMax - ixTMin) * binDur;
    
    % M10 Temporal Asymmetry
    M(10) = (qT(1) + qT(3) - 2*qT(2)) / (qT(1) + qT(3));
    
    % M11 Median Frequency.  qF has the quartiles for frequency.
    qF = cumFrac(trEnvF, [0.25 0.50 0.75], trBx([2 4]));
    M(11) = qF(2);
    
    % M12 Spectral Interquartile Range.
    M(12) = qF(3) - qF(1);
    
    % M13 Spectral Concentration.
    [sortF,ixFsort] = sort(trEnvF);		% col vectors
    ixF = cumFrac(sortF, 0.50);
    ixFMin = min(ixFsort(ceil(ixF) : end));
    ixFMax = max(ixFsort(ceil(ixF) : end));
    %M(13) = (ixFMax - ixFMin) * binDur; 	% OLD, BAD method!
    M(13) = (ixFMax - ixFMin) * binBW;
    
    % M14 Spectral Asymmetry.
    M(14) = (qF(1) + qF(3) - 2*qF(2)) / (qF(1) + qF(3));
    
    % M15 Time of Peak Cell Intensity.
    [dummy,peakIx] = max(trGram(:));
    peakOffsetT = floor((peakIx-1) / nRows(trGram)) * binDur;
    M(15) = peakOffsetT + trBx(1);
    
    % M16 Relative Time of Peak Cell Intensity
    M(16) = peakOffsetT / (trBx(3) - trBx(1)) * 100;
    
    % M17 Time of Peak Overall Intensity.
    [dummy,peakIxEnvT] = max(trEnvT);
    M(17) = (peakIxEnvT-1) * binDur + trBx(1);
    
    % M18 Relative Time of Peak Overall Intensity.
    M(18) = (peakIxEnvT-1) * binDur / (trBx(3) - trBx(1)) * 100;
    
    % M19 Frequency of Peak Cell Intensity.
    peakOffsetF = rem(peakIx-1, nRows(trGram)) * binBW;
    M(19) = peakOffsetF + trBx(2);
    
    % M20 Frequency of Peak Overall Intensity.
    [dummy,peakIxEnvF] = max(trEnvF);
    M(20) = (peakIxEnvF-1) * binBW + trBx(2);
    
    % M21 Amplitude Modulation Rate, M22 Variation in AM Rate.
    [M(21),M(22)] = spectrumPeak(trEnvT, binDur);
    
    % M23 Frequency Modulation Rate, M24 Variation in FM Rate.
    % First calculate median frequency fMed and weighted offset oMed.
    fMed = cumFrac(trGram, 0.5, trBx([2 4]));     % row vector
    oMed = (fMed - mean(fMed)) .* trEnvT.^(1/4);
    [M(23),M(24)] = spectrumPeak(oMed, binDur);
    if (0)			% debugging plots
      figure(2); subplot(211); plot(fMed); subplot(212); plot(oMed); figure(1)
    end

    % M25 Average Cepstrum Peak Width.
    x = ifft(trGram,[],1);		% make ifft() operate columnwise
    absx = abs(x).^2;			% squared magnitude (power cepstrum)
    cepsWidth = zeros(1, trN);
    for i = 1 : trN
       [~,cepsWidth(i)] = spectrumPeak(absx(2:floor(nRows(absx)/2),i).', binBW);
    end
    M(25) = mean(cepsWidth);

%     % M25 Average Cepstrum Peak Width (original).
%     x = fft(trGram,[],1);		% make fft() operate columnwise
%     cepsWidth = zeros(1, trN);
%     for i = 1 : trN
%        [~,cepsWidth(i)] = spectrumPeak(x(:,i).', binBW);
%     end
%     M(25) = mean(cepsWidth);
    
    % M26 Overall Entropy.
    sortgram = sort(trGram, 1, 'descend');
    M(26) = mean(cumFrac(sortgram, 0.5)) * binBW;

    % M27 Upsweep Mean.
    sumT2end = sum(trEnvT(2:end));
    M(27) = sum((fMed(2 : end) - fMed(1 : end-1)) .* trEnvT(2:end) / sumT2end);

    % M28 Upsweep Fraction.
    M(28) = sum((fMed(2:end) > fMed(1:end-1)) .* trEnvT(2:end) / sumT2end) ...
      * 100;            % the 100 is to make a percentage
    
    % M29 Signal-to-Noise Ratio.
    y = percentile(gpow(:), [0.25 1]);
    M(29) = 10 * log10(y(2) / y(1)) / 2;
    
    MLNS_values = M;			% for cache
  end					% ...of test for cache
  
  % Find which value of M() to return.
  y = M(strmatch(name, {MLNS_params.longName}));

end	% main switch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function z = cumFrac(seq, frac, bounds)
%    Find, for instance, the point where 50% (for frac=0.5) of the energy has 
%    accumulated in the column vector (!) seq.  The 2-element vector 'bounds'
%    gives the scaled indices of the first and last elements in seq; if
%    omitted, the indices are not scaled but instead go from 1 to the length of
%    seq.  If the 50% point occurs in between two elements, interpolation is
%    done.  frac should be in the range [0,1].  Also, frac may be a vector, in
%    which case the result is a column vector of the same length.
%
%    seq may also be a matrix, in which case cumFrac operates columnwise.  
%    Then z has multiple columns, one per column of seq.

if (nargin < 3)
  bounds = [1 nRows(seq)];
end
Y = linspace(bounds(1), bounds(2), nRows(seq));

x = sum(seq, 1);
z = zeros(length(frac), nCols(seq));
for j = 1 : nCols(seq)
  % Test whether frac is before the very first point.  (There is an up/down
  % asymmetry error here.  Need to fix it!)
  ix = (frac(:) < (seq(1,j) / x(j)));
  z(ix,j) = Y(1);
  z(~ix,j) = interp1(cumsum(seq(:,j)) / x(j), Y, frac(~ix));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rate,width] = spectrumPeak(seq, period)
% Given a sequence 'seq', find the position of the peak of its power spectrum.
% 'period' is the spacing of elements in seq.  Also find 'width', the width of
% the peak 3 dB (a factor of 0.5) down from the peak.

n = length(seq);
if (n <= 3)
  rate = 0; width = 0;
  return
end
x = abs(fft(seq)) .^ 2;
x1 = x(2 : floor(n/2));	% positive freqs only; also ignore DC at x(1)
[pk,pkIx] = max(x1);	% pkIx is off by one because of ignoring DC
rate = pkIx/n/period;	% want pkIx+1 because of ignoring DC, but -1 for MATLAB
			%    1-based indexing; these cancel

if (0)
  % Summed autocorrelation test.
  [ac,sac,sacw] = sumautocorr(seq, 1, length(seq), [0 1]);
  figure(2); 
  subplot(411); plot(seq)
  subplot(412); plot(x1)
  subplot(413); plot(2:length(ac), ac(2:end))
  subplot(414); plot(sacw)
  figure(1)
  %disp([length(seq) period])
end

% Find width of peak 3 dB down from peak.
thresh = pk / (10^(3/10));		% 3 dB down
% i0 has guard value at start (and i1 at end) in case find() returns [].
i0 = [0  (find(x(1:pkIx) < thresh))];
i1 = [(find(x(pkIx : end) < thresh)+pkIx-1)  length(x)+1];
width = (i1(1) - i0(end) + 1) * period;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yi = limInterp1(x,y,xi)
% y = limInterp1(x,y,xi)
%   "Put limits on the interpolation table."  Like interp1, but if xi < x(1),
%   then uses y(1), and if xi > x(end), uses x(end).

lo = (xi < x(1));
hi =(xi > x(end));

yi = zeros(size(xi));
yi(lo) = y(1);
yi(hi) = y(end);
yi(~(lo | hi)) = interp1(x, y, xi(~(lo | hi)));
