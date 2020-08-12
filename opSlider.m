function opSlider(which)
% opSlider(which)
% Read a value from a slider and repaint accordingly.  The arg 'which'
% is either b, c, h, or v, depending on the slider that was changed 
% (brightness, contrast, horizontal scroll, vertical scroll).
% 
% If the user clicks on the H or V scroll bar either outside the button or
% on the arrow, detect that and scroll by the appropriate amount rather
% than the amount MATLAB wants to move the slider.

global opBrightness opContrast
global opTMax opSRate opT0 opT1 opF0 opF1 uiSliderClick opBrightReverse

drawnow;				% repaint slider in correct position
obj = gcbo;

if (which == 'h' || which == 'v');
  if (which == 'h')			% h scrollbar; obj is opHScrollBar
    wid = opT1 - opT0;
    opT0 = max(0, min(opTMax, get(obj, 'Value')));
    opT1 = max(0, min(opTMax, opT0 + wid));
  else					% v scrollbar; obj is opVScrollBar
    wid = opF1 - opF0;
    opF0 = max(0, min(opSRate/2, get(obj, 'Value')));
    opF1 = max(0, min(opSRate/2, opF0 + wid));
  end
  opRefresh;
  return
end

% Only brightness and contrast sliders after this.

% Figure out previous scrollbar values, and long and short scroll sizes.
if (which == 'b')
  prev = iff(opBrightReverse, 1 - opBrightness, opBrightness);
else               
  prev = opContrast;
end
long  = 0.100;				% amount to move on click in bar
short = 0.005;				% amount to move on click on arrow

if     (strcmp(uiSliderClick, 'upsmall')),  now = prev + short;
elseif (strcmp(uiSliderClick, 'downsmall')),now = prev - short;
elseif (strcmp(uiSliderClick, 'upbig')),    now = prev + long;
elseif (strcmp(uiSliderClick, 'downbig')),  now = prev - long;
else                                        now = get(obj,'Value'); %no change
end

now = min(1, max(0, now));

if (which == 'b'), opBrightness = iff(opBrightReverse, 1 - now, now);
else               opContrast   = now;
end

% Try diddling the colormap; if it works, just return.
%if (opColorMap('install', opBrightness, opContrast))
%  if   (which == 'b'), uiSlider(opBrightnessSlider, 'Value', now);
%  else                 uiSlider(opContrastSlider,   'Value', now);
%  end
%  return;
%end
% otherwise fall through and repaint the image
  
opRefresh;		% fixes scrollbars and brightness and contrast sliders
