
% locAccuracy.m
% Given arr (a set of phone positions as a 2 x N array), calculate and plot
% the accuracy of locations calculated with the time-delay estimation method.
% Accuracies are plotted only in a relative sense.
%
% This works only for 2-dimensional locations.
%
% For example, this one looks pretty:
%   arr = [0 0; 0 1; 1 1; 1 0]' - 0.5 + rand(2,4)/1e5; locAccuracy
% Another one:
%   arr = [0 0; 0 1; 3 -1]' - 0.5 + rand(2,3)/1e5; locAccuracy
% Used in chapter for "Listening in the Ocean":
%   arr = [.5 -.5; -1.5 -2.5; -3.5 0.5; -0.5 4.5]' + rand(2,4)/1e5; locAccuracy
% plotScale = 3.8
%
% Dave Mellinger

if (size(arr,1) == 3)
  error('Sorry, this routine works only for 2-dimensional locations.');
end

if (~exist('plotScale', 'var')), plotScale = 3; end   % plot size rel. to array

usecolor = true;		% color, or black and white?

ncolor = 17;			% number of contours

% res = number of points that are plotted in x and y; use (prime number)+1
res = 600;			% most accurate
%res = 200;			% pretty good
%res = 102;			% intermediate
%res = 60;			% most speedy

n = size(arr,2);		% number of phones
lim = defaultLimits(arr, plotScale);

x = linspace(lim(1), lim(2), res);
y = linspace(lim(3), lim(4), res);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate location accuracy on grid defined by x and y [and z].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (1)				% change this 1 into 0 to avoid recalculation

  [h1,h2] = timesToDelays(1:n);		% all pairs of phones (O(n^2) of them)
  [j1,j2] = timesToDelays(1:length(h1));% all pairs of pairs (O(n^4) of them!)

  fprintf(2, '%d dots:\n', length(x))
  d = zeros(res,res);
  for i = 1:length(x)
    for j = 1:length(y)
      jac = CalcDeltaJacobian([x(i);y(j)], arr, h1, h2, h1);
      if (1)
	% This is the way it was before 3/12/04.
	d(j,i) = loccond(jac, j1,j2);
      else
	if (i == 1 & j == 1), disp('Using alternative cond method.'); end
	d(j,i) = cond(jac);
      end
    end
    fprintf(1,'.'); if (rem(i,60) == 0), fprintf(1,'\n'); end
  end
  disp(' ');
else
  disp('Skipping re-calculation because you already did it.')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf
hold on

if (0)
  % old way
  if (1), d1 = -d;		% linear color mapping
  else d1 = -log(d);		% logarithmic color mapping
  end
else
  d1 = d;
end

% Plot it as a color image.
if (usecolor)
  xcorrection = diff(x(1:2))/4;	    % not clear why this is needed, but it is
  d2 = d1/min(min(abs(d1)));
  imagesc(x + xcorrection, y, d2);
  cmap = hot(round(ncolor * 1.1));
  colormap(flipud(cmap(size(cmap,1) - ncolor + 1 : size(cmap,1), :)))
  set(gca, 'CLim', [min(min(d2)) max(max(d2))]);
  contour(x, y, d2, ncolor-1, 'k')
else
  % Manually scale d1 to fit the number of colors.
  d2 = d1 - min(min(d1));
  d2 = d2 / max(max(d2));
  
  xcorrection = diff(x(1:2))/4;	    % not clear why this is needed, but it is
  image(x + xcorrection, y, round(d2 * ncolor + 0.4999));
  contour(x, y, d2, ncolor-1, 'k')
  cmap = gray(round(ncolor * 1.4));
  colormap(cmap(size(cmap,1) - ncolor + 1 : size(cmap,1), :))
end

colorbar('vert')

if (usecolor)
  set(plot(arr(1,:), arr(2,:), 'bo'), 'LineWidth', 4)	% blue dots
else
  set(plot(arr(1,:), arr(2,:), 'wo'), 'LineWidth', 3)	% white dots
  set(plot(arr(1,:), arr(2,:), 'k.'), 'LineWidth', 1)	% black centers
end
hold off
axis(lim)
title('Relative location accuracy')

v = version;
if (str2num(v(1:2)) >= 6), axis image
else                       axis equal
end

if (0)
  % For book plot:
  xlim([-13 11.5]); ylim([-8.5 10.5]); set(gca, 'tickdir', 'out');
  axis equal; set(sub(get(gcf, 'ch'), 1), 'TickDir', 'out');
  rectangle('Pos', [min(xlim) min(ylim) diff(xlim) diff(ylim)])
  set(gca, 'XTick', -50:2:50); title('')
  print -dtiff -r600 D:\Dave\00writing\chapter-ListeningInTheOcean\figures\locAccuracy.tif
end
