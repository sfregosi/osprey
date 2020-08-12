function [m1,m2,d] = timesToDelays(h, t)
%timeToDelays	Turn arrival times into inter-phone delays.
%
% [m1,m2,delays] = timesToDelays(phoneNumbers, arrivalTimes)
%    The arrival times should be in seconds.  So are the delays.
%    phoneNumbers is used to index into arrivalTimes; it's normally
%    1:(number of phones).  The phone number pairs are also put
%    into the m1 and m2 output arrays.
%
%    If arrivalTimes is missing, only m1 and m2 are computed.

n = 1;				% time-delay number
for i = 1 : length(h)
  for j = i+1 : length(h)
    m1(n) = h(i);
    m2(n) = h(j);
    n = n + 1;
  end
end

if (nargin > 1)
  d = -(t(m1) - t(m2));
end
