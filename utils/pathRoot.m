function r = pathRoot(p)
% root = pathRoot(pathname)
% Given a pathname, return the pathname sans extension.
% This includes the directory name(s) in the path.
%
% See also pathDir, pathExt, pathFile, filesep.

ext = '.';

r = p;
w = find(p == ext);
if (length(w))
  w = w(length(w));
  if (w > length(pathDir(p)))	% check that '.' is not in dirname
    r = p(1:w-1);
  end
end
