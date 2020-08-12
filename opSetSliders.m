function opSetSliders
% opSetSliders		set up the horz., vert., brightness, & contrast bars

global opTMax opT0 opT1 opSRate opF0 opF1 opHScrollBar opVScrollBar
global opHScrollSkip opVScrollSkip

setslider(opHScrollBar, 0, opTMax,    opT0, opT1, opHScrollSkip);
setslider(opVScrollBar, 0, opSRate/2, opF0, opF1, opVScrollSkip);

%set(opBrightnessSlider, 'Value', min(1, max(0, opBrightness)));
%set(opContrastSlider,   'Value', min(1, max(0, opContrast)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setslider(h, xMin, xMax, x0, x1, step)
% [xMin,xMax] is the total allowable range.
% [x0,x1] is what's on the screen now.
% step is how far to step, as a fraction of what's on the screen now.

wid = x1 - x0;
if (xMax - wid > xMin)
  set(h, 'Min', xMin, 'Max', xMax - wid, 'Enable', 'on', 'Value', x0);

  % Matlab bug workaround: Setting 'SliderStep' to its current value fails.
  step1 = min([1 inf], (step*wid / (xMax - xMin - wid)) * [0.05 1]);
  if (max(abs((step1 - get(h, 'SliderStep')))) > 1e-6)
    set(h, 'SliderStep', step1)
  end
else
  set(h, 'Min', xMin, 'Max', xMax, 'Value', xMin, ...
      'SliderStep', [1 inf], 'Enable', 'off');
end
