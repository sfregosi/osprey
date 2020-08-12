function dtnum = findDateInString(str)
%findDateInString	extract date from a string like 'x180510-191722.wav'
%
% dtnum = findDateInString(str)
%   Given a string str -- perhaps a filename -- containing a date/time stamp
%   somewhere in it, extract the date and return it as a datenum value. There
%   can be other stuff in the string that's not a date/time stamp. The date
%   within the string should be formatted as YYMMDD-hhmmss or YYMMDD_hhmmss or
%   YYMMDDThhmmss, where YY is a 2-digit year, MM is a 2-digit month, DD is a
%   2-digit day, hh is a 2-digit hour, mm is a 2-digit minute, and ss is a
%   2-digit second. In that last example, 'T' is literally the character T, as
%   used in ISO 8601 -- see datestr format #30. Also the seconds part (ss) can
%   contain decimal fractions of a second. If no date in this format is found
%   in str, NaN is returned.
%
%   Examples of str: 
%     'xyz180510-191722.wav' - interpreted as day 2018-05-10 at time 19:17:22
%     '180510T191722 good one' - interpreted as day 2018-05-10 at time 19:17:22
%     '180510-191722.153' - interpreted as day 2018-05-10 at time 19:17:22.153
%     '2018-05-10 19:17:22'  - not in correct format, so NaN would be returned
%
% dtnum = findDateInString(cellstr)
%   If the input argument is a cell array of strings, the date is extracted
%   from each member of it. The return value is an array of datenum values (or
%   NaNs) the same size as cellstr.
%
% See also datenum, datestr.

if (ischar(str))
  % A string. Find the date string in it.
  pos = regexp(str, '\d\d\d\d\d\d[-_T]\d\d\d\d\d\d', 'once');
  if (isempty(pos))
    dtnum = NaN;	% didn't find date
  else
    v = sscanf(str(pos:end), '%2d%2d%2d%*c%2d%2d%f');
    v(1) = v(1) + 1900 + iff(v(1) < 80, 100, 0);
    dtnum = datenum(v.');
  end
  
elseif (iscell(str))
  % Cell array of strings. Recurse on each string.
  dtnum = zeros(size(str));
  for i = 1 : numel(str)
    dtnum(i) = findDateInString(str{i});
  end
  
else
  error('Input must be a string or cell array of strings.')
end
