function limits = defaultLimits(arr, scale)
%defaultLimits		calculate plotting limits since user didn't supply them
% 
% limits = defaultLimits(arr)
%    Given arr, a D x n array of phone positions, calculate limits that are
%    centered on arr's center and have a size three times arr's maximum extent.
%    (D is the number of dimensions, usually 2 or 3). This "maximum extent" 
%    is the maximum of the extents in each dimension.  'limits' is returned
%    as a 1 x 2*D vector: 
%              [xmin xmax ymin ymax]               for 2 dimensions, or
%              [xmin xmax ymin ymax zmin zmax]     for 3 dimensions.
%
% limits = defaultLimits(arr, scale)
%    Use 'scale' instead of the default 3 as the array size.

if (nargin < 2), scale = 3; end

D = size(arr,1);
A = [min(arr'); max(arr')];
extent = max(diff(A));
limits = [1;1] * mean(A) + extent * scale/2 * [-1; 1] * ones(1,D);
limits = limits(:)';
