function opNormalize(cmd, x0, x1, x2)
% 

if (strcmp(cmd, 'show'))		% display the window
  opNFig = figure;
  leftbot = [300 200];			% position of figure
  size = [450 250];			% size of figure
  left = 50;				% left side of text
  boxwid = 100;
  left1 = left + 30 + boxwid/2;		% left size of left type-in box
  left2 = 30 + size(1)/2 + boxwid/2;	% left size of right type-in box
  leftindent = left + 30;		% left size of popups

  top = size(2) - 30;
  set(opNFig, 'Pos', [leftbot size], 'Name', 'Normalization', ...
      'NumberTitle', 'off', 'Resize', 'off');
  axes('Units', 'pix', 'Position', [0 0 size], 'Visible', 'off', ...
      'Xlim', [0 size(1)], 'YLim', [0 size(2)]);
  text(left, top, 'Normalization', 'FontSize', 16);
  top = top - 40;
  
  text(left, top, 'Type of processing:', 'FontSize', 12);
  top = top - 15;
  uicontrol('Style', 'popup', 'Pos', [leftindent top-20 300 20], ...
      'String', 'Time-decay|Time-decay plus division');
  top = top - 40;
  
  text(left, top, 'Frequency spread:', 'FontSize', 12);
  top = top - 15;
  uicontrol('Style', 'popup', 'Pos', [leftindent top-20 300 20], ...
      'String', 'Single-channel|Whole spectrogram');
  top = top - 40;

  top = top - 10;
  text(left1, top, 'Decay time (1/e), sec:', 'FontSize', 12, 'Horiz', 'center');
  text(left2, top, 'Decay time of divisor:', 'FontSize', 12, 'Horiz', 'center');
  top = top - 15;
  uicontrol('Style', 'edit', 'Pos', [left1-boxwid/2 top-20 boxwid 20], ...
      'String', '10')
  uicontrol('Style', 'edit', 'Pos', [left2-boxwid/2 top-20 boxwid 20], ...
      'String', '10')
  top = top - 40;

end
