function [points,obj] = PlotHyp(x1,y1,x2,y2,a,minX,maxX,minY,maxY,color)

% function PlotHyp(x1,y1,x2,y2,a,minX,maxX,minY,maxY,color)
%
% Plot a hyperbola whose foci are (x1,y1) and (x2,y2),
%  and whose semi-major axis is 'a'

% Desired resolution
n = 200;

% Translate to standard coordinates
orgX = (x1+x2)/2;
orgY = (y1+y2)/2;

% Focal length
c = sqrt((x1-orgX)*(x1-orgX) + (y1-orgY)*(y1-orgY));

% Semi-minor axis
b = sqrt(c*c - a*a);

% Rotate to standard coordinates
sTheta = (y1-orgY)/c;
cTheta = (x1-orgX)/c;
invRot = [cTheta -sTheta  orgX; 
          sTheta  cTheta  orgY;
             0       0     1];
rot = inv(invRot);

% Calculate rotated minX, minY;
A = [minX; minY; 1];
B = [maxX; minY; 1];
C = [maxX; maxY; 1];
D = [minX; maxY; 1];
A = rot*A;
B = rot*B;
C = rot*C;
D = rot*D;

minY1 = min([A(2),B(2),C(2),D(2)]);
maxY1 = max([A(2),B(2),C(2),D(2)]);

y = linspace(minY1,maxY1,n);
x = real (a * sqrt ((y .* y) / (b*b) + 1));

points = invRot * [x; y; ones(size(x))];

points = points(1:2,:);
obj = plot(points(1,:),points(2,:),color);
axis image
axis([minX maxX minY maxY])
