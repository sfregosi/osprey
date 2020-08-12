function rmkdir(dirr)
%RMKDIR		recursive mkdir allowing many-element paths
%
% rmkdir(newdirectory)

if (~exist(pathDir(dirr), 'dir'))
  rmkdir(pathDir(dirr));
end

if (~exist(dirr, 'dir'))
  mkdir(pathDir(dirr), pathFile(dirr));
end
