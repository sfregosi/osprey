function d = dist(a,b)
%DIST		Euclidean distance between points in R^n
%
% d = dist(a,b)
%     Return the Euclidean distance d between points a and b in R^n.

d = norm(a-b);
