c = 1500;
tol = 0;
lims = [-200 200 -75 175];

if (0)
  arr = [0 0; 100 0].';
  m1 = [1];
  m2 = [2];
  d = dist(arr(1,:), arr(2,:)) / c * 0.7;
else
  arr = [0 0; 100 0; 50 100].';
  m1 = [1 1 2];
  m2 = [2 3 3];
  if (1)
    p = [30 -10];
    dist = sqrt(sum((repmat(p.',1,nCols(arr)) - arr).^2));
    d = (dist(m2) - dist(m1)) / c;
  else
    d1 = arr(:,m1) - arr(:,m2);
    d = sqrt(sum(d1.^2, 1)) / c * 0.5;
  end
end
PlotHyperbolas(d,tol,arr,m1,m2,c,lims);

x = get(gca, 'Children');
set(x, 'LineWidth', 2)
%set(x(1), 'LineWidth', 3, 'Color', 'r')
%set(gca, 'Color', [.6 .6 1])		% light blue background
set(gca, 'Color', [0 0 0])		% black background
wysiwyg