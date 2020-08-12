function opInitialFrame
% opInitialFrame
% This sets the time bounds to be 5 seconds or the whole file
% (whichever is shorter), and the frequency bounds to be the whole range.

global opF0 opF1 opT0 opT1 opTMax opSRate opHopSize opZeroPad opDataSize

opF0 = 0;
opF1 = opSRate / 2;
opT0 = 0;
% Aim for initial gram to have ~40000 cells total.
t1a = 40000 / (opSRate * opHopSize) / (opZeroPad+1);
% This max() makes sure gram has >=2 cols. This prevents breakage later.
t1b = max(t1a, opDataSize * (1 + opHopSize) / opSRate);
opT1 = min(opTMax, t1b);
