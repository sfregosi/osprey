function opEraseSelection
% opEraseSelection
%    Erase the selection and redisplay.

global opSelT0 opSelT1 opSelF0 opSelF1 opTMax opSRate opMousePos

% Make the selection negatively big so it never shows.
opSelT0(:) = opTMax;
opSelT1(:) = 0;
opSelF0(:) = opSRate / 2;
opSelF1(:) = 0;

opMousePos = [Inf Inf];
