
% This is for calculating a location based on pinging a transponder from 
% several locations, and measuring the round-trip travel time of each
% ping.

pingdata = [
% latdeg latmin londeg lonmin rtTime
    44	  39.1   -124   53.0   1.2
    44	  39.3   -124   54.0   1.75
    ];

waterTempF = 55;	% degrees F
salinity = 35;		% parts per thousand
depth = 100;		% meters (used only for calculating speed of sound)
gridSize = 50;		% initial search grid size, km

%%%%%%%%%%%%%%%%%%%%%%%%%%% end configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%

N = nRows(pingdata);
kmPerDeg = 60 * 1.852;

% Convert data to kilometers (xyKm).
latD = pingdata(:,1) + (pingdata(:,2)/60 .* sign(pingdata(:,1)));
lonD = pingdata(:,3) + (pingdata(:,4)/60 .* sign(pingdata(:,3)));
centerLat = mean(latD,1);
centerLon = mean(lonD,1);
[~,xyKm] = orthoProjection(latD, lonD, centerLat, centerLon);
xKm = xyKm(:,1);		% [N,1] x-positions in km
yKm = xyKm(:,2);		% [N,1] y-positions in km

lonCorr = cos(centerLat * pi/180);	% correction for size of longitude deg
%lonCorr = 1; disp('Using debug value for lonCorr!')

% Get speed of sound in m/s, convert ping time to distance.
c = oceanSoundSpeed((waterTempF - 32)*5/9, salinity, depth, centerLat);
distKm = pingdata(:,5) * c/1000;	% [N,1] ping distance in km

% Everything is in km from now on, except when plotting/printing.

% Plot data, with a center point and circles.
figure(1)
clf
%axis equal
hold on
grid on
plot(lonD, latD, 'o')
%plot(xKm, yKm, 'o')
for iN = 1 : N
  xCircle = cos(linspace(0, 2*pi, 300)) * distKm(iN);
  yCircle = sin(linspace(0, 2*pi, 300)) * distKm(iN);
  plot(xCircle/kmPerDeg/lonCorr + lonD(iN), yCircle/kmPerDeg + latD(iN), 'b-')
  %plot(xCircle + xKm(iN), yCircle + yKm(iN), 'b-')
end

% Grid search with successively smaller grids. Calculate error at each 
% gridpoint, find smallest error in grid, shrink grid and re-center
% on the best point. 
nGrid = 11;
gs1 = gridSize;
xBest = mean(xKm);
yBest = mean(yKm);
for iter = 1 : 15
  xGrid = linspace(xBest - gs1/2, xBest + gs1/2, nGrid);
  yGrid = linspace(yBest - gs1/2, yBest + gs1/2, nGrid);
  
  errSq = zeros(length(xGrid), length(yGrid));
  for ix = 1 : length(xGrid)
    for iy = 1 : length(yGrid)
      for iN = 1 : N
	dst = sqrt((xGrid(ix) - xKm(iN))^2 + (yGrid(iy) - yKm(iN))^2);
	err = abs(dst - distKm(iN));
	errSq(ix,iy) = errSq(ix,iy) + err^2;
	if 0 && ((ix == 7 && iy == 6) || (ix == 3 && iy == 9))
	  printf('iter %d, ix(%d,%d), grid(%.4f,%.4f), xy(%.4f,%.4f), dst %.4f, distKm %.4f, err %.4f', ...
	    iter, ix, iy, xGrid(ix), yGrid(iy), xKm(iN), yKm(iN), dst, distKm(iN), err);
	end
      end
    end
  end
  
  [~,ix] = min(errSq(:));		% linear index of smallest error
  [ixX,ixY] = ind2sub(size(errSq), ix);	% row,col index of smallest error
  xBest = xGrid(ixX);
  yBest = yGrid(ixY);  
  gs1 = gs1 / 3;
  if 0 && (iter >= 3)
    [x,y] = meshgrid(xGrid,yGrid);
    h1 = plot(x/kmPerDeg/lonCorr + centerLon, y/kmPerDeg + centerLat, 'k.');
    h2 = plot(xBest/kmPerDeg/lonCorr + centerLon, yBest/kmPerDeg + centerLat, 'ro');
    %h1 = plot(x, y, 'k.');
    %h2 = plot(xBest, yBest, 'ro');
    %xlims(min(xGrid), max(xGrid)); ylims(min(yGrid), max(yGrid))
    delete(h1); delete(h2);
  end
end

% Convert (xBest,yBest) to lat/lon.
latBest = yBest / kmPerDeg           + centerLat;
lonBest = xBest / kmPerDeg / lonCorr + centerLon;

plot(lonBest, latBest, 'ro')
%plot(xBest, yBest, 'ro')
%printf('Best xy: (%.4f, %.4f)', xBest, yBest)
printf('Best latlon: (%.6f, %.6f)', latBest, lonBest)
latBestDeg = fix(latBest);
latBestMin = abs((latBest - latBestDeg) * 60);
lonBestDeg = fix(lonBest);
lonBestMin = abs((lonBest - lonBestDeg) * 60);
printf('...or as deg+min: (%d° %.2f'', %d° %.2f'')', ...
  latBestDeg, latBestMin, lonBestDeg, lonBestMin)
%[~,ansKm] = orthoProjection(latBest, lonBest, centerLat, centerLon)
