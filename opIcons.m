function opIcons
% opIcons
%     Create op?CrunchIcon and op?ZoomIcon, the images for the hand-y icons.
%     The images were stolen from Canary.

global opHCrunchIcon opHZoomIcon opVCrunchIcon opVZoomIcon opIconColorMap
%global opPrevFileIcon opNextFileIcon

% The color codes are defined below.

% The crunch icon.
c = double([
    'lllllllllllllllllllllllllllllllllllllld'
    'llllllllllllllllllllllllllllllllllllldd'
    'llmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmbbmmbbbbbbbbbbbbbbbbmmmmmmmmmmmmmdd'
    'llmmbbmmbbbbbbbbbbbbbbbbmmmmmmmmmmmmmdd'
    'llmmbbmmbbbbbbbbbbbbbbbbmmmmmmmmmmmmmdd'
    'llmmbbmmmmmbwwwwwwwwwbmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmbbbbbbbbbbbmmmmmmmmmmmmmmmdd'
    'llmmbbmmmmmboooooooobbbbbbmmmmmmmmmmmdd'
    'llmmbbmmmmmboooooooooooooobbbbbbbbmmmdd'
    'llmmbbmmmmmbooooooobboooooooooooobmmmdd'
    'llmmbbmmmmmbooooooooobbbbbbbbbbbbbmmmdd'
    'llmmbbmmmmmmbbbbbbbboooobbbbbbbbbmmmmdd'
    'llmmbbmmmmmmbbwwwwwbbbbbbwwwwwwwbbmmmdd'
    'llmmbbmmmmmmbwwwwwwwwwwwwwwwbbwwwbmmmdd'
    'llmmbbmmmmmmbwwwbbbbbbbbbbbbbbwwwbmmmdd'
    'llmmbbmmmmmmbwwwbbwwwwwwwwwwwwwwwbmmmdd'
    'llmmbbmmmmmmbbwwwwwwwwwwwwwwwwwwbbmmmdd'
    'llmmbbmmmmmmmbbbbbbbbbbbbbbbbbbbbmmmmdd'
    'llmmbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbmmdd'
    'llmmbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbmmdd'
    'llmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llddddddddddddddddddddddddddddddddddddd'
    'ldddddddddddddddddddddddddddddddddddddd'
    ]);

% The zoom icon.
z = double([
    'lllllllllllllllllllllllllllllllllllllld'
    'llllllllllllllllllllllllllllllllllllldd'
    'llmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmmmmmmmmbbbbbbbbbbbbbbbbbbmmmmmmmmdd'
    'llmmmmmmmmmbbbbbbbbbbbbbbbbbbmmmmmmmmdd'
    'llmmbbmmmmmbbbbbbbbbbbbbbbbbbmmmmmmmmdd'
    'llmmbbmmmmmmmbwwwwwwwwwwwwbmmmmmmmmmmdd'
    'llmmbbmmmmmmmbbbbbbbbbbbbbbmmmmmmmmmmdd'
    'llmmbbmmmmmmmmboooooooooobbbbmmmmmmmmdd'
    'llmmbbmmmmmmmmboooooooooooobbbmmmmmmmdd'
    'llmmbbmmmmmmmmmbboooooooooooobmmmmmmmdd'
    'llmmbbmmmmmmmmmmboooobbbbbboobmmmmmmmdd'
    'llmmbbmmmmmmmmbbbooobbwwwwwbbbmmmmmmmdd'
    'llmmbbmmmmmmmbwwbooobwwwwwwwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwbooobwwwwwwwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwbooobwwwwwwwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwwbbbwwwwbbbwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwwwwwwwwwbbbwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwwwwwwwwwbbbwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwwwwwwwwwbbbwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwwwwwwwwwbbbwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwwwwwwwwwbbbwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwwbbbbbbbbbbwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwbbbbbbbbbbbwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwbbbbbbbbbbwwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwbbbwwwwwwwwwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwbbbwwwwwwwwwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwbbbwwwwwwwwwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwbbbwwwwwwwwwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwbbbwwwwwwwwwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwbbbwwwwwwwwwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwwwwwwwwwwwwwwbmmmmmmmdd'
    'llmmbbmmmmmmmbwwwwwwwwwwwwwwwbmmmmmmmdd'
    'llmmbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbmmdd'
    'llmmbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbmmdd'
    'llmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmdd'
    'llddddddddddddddddddddddddddddddddddddd'
    'ldddddddddddddddddddddddddddddddddddddd'
    ]);

opIconColorMap = [
    1	1	1		% white		'w'
    0.9	0.9	0.9		% light gray	'l'
    0.7	0.7	0.7		% medium gray	'm'
    0.5	0.5	0.5		% dark gray	'd'
    0	0	0		% black		'b'
    0.8	0.8	0.4		% tan/yellow	'o'
    ];

% Change the letters into gray (or yellow) values in both c and z.
base = opColorMap('geticonbase');	% colormap index of first icon color
c(c=='w') = base+0;		% white
z(z=='w') = base+0;
c(c=='l') = base+1;		% light gray
z(z=='l') = base+1;
c(c=='m') = base+2;		% medium gray
z(z=='m') = base+2;
c(c=='d') = base+3;		% dark gray
z(z=='d') = base+3;
c(c=='b') = base+4;		% black
z(z=='b') = base+4;
c(c=='o') = base+5;		% yellow
z(z=='o') = base+5;

opVCrunchIcon = c;
opVZoomIcon   = z;

% Make the horizontal ones.  Have to fix the borders -- shading is for light 
% source at upper left.
c = rot90(c.', 2);
c([1 2 38 39],:) = c([39 38 2 1],:);
c(:,[1 2 38 39]) = c(:,[39 38 2 1]);
opHCrunchIcon = c;

z = rot90(z.', 2);
z([1 2 38 39],:) = z([39 38 2 1],:);
z(:,[1 2 38 39]) = z(:,[39 38 2 1]);
opHZoomIcon = z;

%% Previous- and next-file icons.
% pngdata = importdata('opFilePrevIcon.png');
% opPrevFileIcon = base + pngdata.alpha / 255 * 3 + 1;	% rescale to fit colormap
% % Curiously only the prev-file icon was available, so we have to create the
% % next-file one by flipping the arrow.
% opNextFileIcon = opPrevFileIcon;
% opNextFileIcon(170:325, 220:350) = fliplr(opNextFileIcon(170:325, 220:350));
