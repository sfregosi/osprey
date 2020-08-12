fname = 'C:\IshExtras\ScottVeirs-BeamReachExample\tone10019m_extract.aif';

[s,fs] = soundIn(fname);

t = (0:length(s)) / fs;
corrT = [-fliplr(t(1:end-1)) t(2:end-1)];
c12 = corr(s(:,1), s(:,2)).';
c13 = corr(s(:,1), s(:,3)).';
c14 = corr(s(:,1), s(:,4)).';
c23 = corr(s(:,2), s(:,3)).';
c24 = corr(s(:,2), s(:,4)).';
c34 = corr(s(:,3), s(:,4)).';

% Pick which one to use.
cor = c34;

corHilb = hilbert(cor);		% analytic signal: cor + i*hilbert(cor)
subplot(211); plot(corrT*1000, cor);       xlims(-10, 10)
subplot(212); plot(corrT*1000, abs(corHilb)); xlims(-10, 10)

[mx, maxI] = max(corHilb);
xlabel(sprintf('seconds; max is at %.6f ms (%d samples)', corrT(maxI)*1000, ...
    maxI - length(s)))
