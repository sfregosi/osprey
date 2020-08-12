function z = opCacheData(ch, cmd, x, y)
% opCacheData: Perform various functions on the cache for a given channel.
% Each of these functions operates on the cache for the given channel ch.
% Here is the only place where the opCacheData<n> arrays and 
% opCacheIndex<n> arrays are accessed.
%
% opCacheData(ch, 'clear')
% Clear the cache and index, i.e. do    cache = [];  index = [];
% 
% opCacheData(ch, 'iclear')
% Clear the index, i.e. do    index = [];
% 
% nCols = opCacheData(ch, 'ncols')
% Return the number of columns in the cache, i.e. nCols(cache)
%
% nRows = opCacheData(ch, 'nrows')
% Return the number of rows in the cache, i.e. nRows(cache)
%
% opCacheData(ch, 'extend', newcols)
% Append empty cols to the end of the cache.
%
% opCacheData(ch, 'sub', rows, cols)
% Return the values at the given subscripts, i.e. cache(rows,cols)
%
% index = opCacheData(ch, 'iget')
% Return the index for the cache.  Usually opCacheIndex is set to this.
%
% opCacheData(ch, 'iset', index)
% Set the index for the cache.
%
% opCacheData(ch, 'colset', colIndex, values)
% Set the given slots of the cache to the given values.

global opCacheData1  opCacheData2  opCacheData3  opCacheData4
global opCacheData5  opCacheData6  opCacheData7  opCacheData8
global opCacheIndex1 opCacheIndex2 opCacheIndex3 opCacheIndex4
global opCacheIndex5 opCacheIndex6 opCacheIndex7 opCacheIndex8

nd = ['opCacheData'  num2str(ch)];
ni = ['opCacheIndex' num2str(ch)];
if (strcmp(cmd, 'replace') | strcmp(cmd, 'iclear'))

  eval(['if (exist(''' nd ''')==0) ' nd '=[]; end']);	   % create nd if needed

  if (strcmp(cmd, 'replace'))
    eval([nd '=[];' nd '=x;'])
  end
  eval([ni '=-1*ones(size(' ni '));']);
  global opNP
  opNP = [];			% see opComputeSpect.m

elseif (strcmp(cmd, 'ncols'))  eval(['z=nCols(', nd, ');']);
elseif (strcmp(cmd, 'nrows'))  eval(['z=nRows(', nd, ');']);
elseif (strcmp(cmd, 'extend')) eval([nd, '(1,nCols(', nd, ')+x)=0;']); 
elseif (strcmp(cmd, 'sub'))    eval(['z=', nd, '(x,y);']);
elseif (strcmp(cmd, 'iget'))   eval(['z=' ni ';']);
elseif (strcmp(cmd, 'iset'))   eval([ni '=x;']);
elseif (strcmp(cmd, 'colset')) eval([nd '(:,x)=y;']);

else
  error(['Unknown command: ', cmd]);
end
