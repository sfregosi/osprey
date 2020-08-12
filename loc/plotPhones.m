function plotPhones(arr, limits)
%plotPhones	Plot hydrophone/microphone positions, adjust axis limits.
%
% plotPhones(arr, limits)
%    Plot the phone positions, set the axis limits to the values given,
%    turn hold on.  Arr is an array of N phone positions, sized 2xN.
%    Limits is [xMin xMax yMin yMax]; if it's missing or [], a default
%    is used.

if (nargin < 2), limits = []; end
if (isempty(limits))
  limits = defaultLimits(arr);
end

clf
plot(arr(1,:), arr(2,:), '*');
hold on

% Plot (0,0) point -- the ship, perch, etc.
plot(0, 0, 'or', 'LineWidth', 3)
axis(limits);
drawnow
