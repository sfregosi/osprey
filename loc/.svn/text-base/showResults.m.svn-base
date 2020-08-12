function sigma = showResults(xopt, m1, m2, act, calc, err, m, c)
%SHOWRESULTS	Display results of the localization algorithm.
%
% sigma = showResults(xopt, m1, m2, act, calc, err, m, c)
%    Plot the best point.  Also print the coords of the best point
%    and per-delay information.

global scale scaleText

checkScale('init')

  disp(' ')
if (length(xopt) == 2)
  hold on
  plot(xopt(1), xopt(2), 'o', 'LineWidth', 3)
  hold off
  disp(sprintf('Best location:  [x y] = [%.3f  %.3f]', xopt(1), xopt(2)))
else
  disp(sprintf('Best location:  [x y z] = [%.3f  %.3f  %.3f]', ...
      xopt(1), xopt(2), xopt(3)))
end

disp(' ')
disp(sprintf('    phone1    phone2    Actual  Calculated  Error%s', scaleText))
disp([m1' m2' act calc err*scale])

n = length(m1);
sigma = sqrt(m/(n-2))*1000/c;
disp(sprintf('Mean error is %g ms',sigma))

% Generate mesh plot of error surface
%figure(2)
%clf
%contour(x(:,1),y(1,:),log(e'),12)
%title('Log of error function')

%figure(3)
%clf
%meshc(x(:,1),y(1,:),log(e'))
%title('Log of error function')
