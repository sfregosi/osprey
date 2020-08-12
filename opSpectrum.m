function opSpectrum(cmd, pt)
% opSpectrum('show', chan, pt)
%   Show the spectrum of the currently selected channel (opc).  If
%   there is a selection, it defines the time range; otherwise it's a
%   single-point spectrum.  The spectrum is calculated by averaging the
%   relevant spectrogram frames.
%
% opSpectrum('info')
%   Show an informational message in the spectrum window.

global opc opSRate opSelT0 opSelT1 opSelF0 opSelF1 opSpectVec opSpectFreqs

opSpecFig = findobj(0, 'Tag', 'OspreySpectrum');
if (isempty(opSpecFig))
  opSpecFig = figure('Tag', 'OspreySpectrum', 'NumberTitle', 'off', ...
      'Toolbar', 'figure');	% sometimes the toolbar is absent
end

set(opSpecFig, 'HandleVis', 'on');

switch(cmd)
case 'show'
  if (opSelect)
    sel = [opSelT0(opc); opSelF0(opc); opSelT1(opc); opSelF1(opc)]; 
    figname = sprintf('Spectrum of %.3f - %.3f seconds', ...
	opSelT0(opc), opSelT1(opc));
  else
    sel = [pt(1); 0; pt(1); opSRate/2];
    figname = sprintf('Spectrum at %.3f seconds', pt(1));
  end
  
  spect = opGetSpect(opc, sel(1), sel(3), sel(2), sel(4), sel);

  %v = amp * log(sum(sum(exp(spect).^2))/d * opHopSize /(1+opZeroPad));
  opSpectVec = 10 * log10(mean(exp(spect).^2, 2)).';
  opSpectFreqs = linspace(sel(2), sel(4), length(opSpectVec));
  [plotFreqs,plotPrefix] = metricPrefix(opSpectFreqs);
  figure(opSpecFig)
  clf
  set(opSpecFig, 'Name', [figname ' in ' pathFile(opFileName)]);
  set(plot(plotFreqs, opSpectVec), 'LineWidth', 1)
  %set(plot(plotFreqs, opSpectVec), 'LineWidth', 2)
  xlims fit
  xlabel(['frequency, ' plotPrefix 'Hz'])
  ylabel('dB, unreferenced')
  %wysiwyg; print(opSpecFig, '-dpng', 'C:\dave\01talks\Det+Loc15-SanDiego\MellingerTalk\figs\finSpectrum-FN14AHHZ.20111217T000000@15951s.png')

case 'info'
  figure(opSpecFig)
  clf
  set(opSpecFig, 'Name', 'Spectrum')
  axes('Units', 'normalized', 'Position', [0 0 1 1], 'Visible', 'off')
  text(0.5, 0.5, {'To display a spectrum, double-click on the spectrogram.'
      'If there is a selection, its spectrum will be displayed; if not,'
      'the spectrum is of the spectrogram slice you double-click on.'
      ''
      'Spectrum levels are unreferenced (uncalibrated).  This means the'
      'spectrum levels are useful relative to each other, but are not'
      'measured to any standard decibel level like 20 {\mu}Pa.'}, ...
      'HorizontalAlign', 'center');

end	% switch

set(opSpecFig, 'HandleVis', 'Callback');
