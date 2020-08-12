function c = loccond(jac, i, j)
% c = loccond(jac)	the "location condition number" of a Jacobian
%
% jac is a Jacobian matrix of time-delay derivatives, typically 2xN or 3xN
% (for 2- and 3-dimensional arrays, respectively), where N is the number 
% of time delays.  
%
% i and j are index vectors telling which pairs from jac to use.  They are
% the values returned by timesToDelays, and they are passed in only
% because it's faster that way.
%
% c is like a condition number, representing how sensititve the loc
% is to changes in the delays.  For each pair of Jacobian vectors, the
% cosine of the angle between them is computed.  The smallest such cosine
% over all Jacobian vector pairs is the condition number.
%
% Correction: (1 - sine) is used instead of cosine.
%
% It's not clear whether this is the right thing to compute.
% Is plain old cond better than this?

eps = 1e-10;
ix = (abs(jac) < eps);
jac(ix) = ones(1,sum(sum(ix))) * 1e-20;
quac = 1 ./ jac;		 % use dx/dDi instead of dDi/dx (Di = delay i)

d = sum(quac(:,i) .* quac(:,j));
ll = sqrt(sum(quac(:,i).^2)) .* sqrt(sum(quac(:,j).^2));
ix = (abs(ll) > eps & ~isinf(ll));
if (all(ix == 0))
  c = Inf;
  disp('Warning (in loccond); all hyperbolas are infinitely badly conditioned')
else
  c = min(abs(d(ix) ./ ll(ix))); % d/ll = cos of angle between jacobian vectors
end

%c = 1 - sqrt(1 - c.^2);		 % convert to 1-(sin of angle)
