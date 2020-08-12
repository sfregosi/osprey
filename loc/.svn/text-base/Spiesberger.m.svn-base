% This is a closed-form solution for using three phones to locate
% an object in 2-space.  There are usually two solutions.  It operates on
% the example set up by R, tau, c.
% 
% This is from
%     Spiesberger, J.L. 2001. Hyperbolic location errors due to an 
%     insufficient number of receivers. J. Acoust. Soc. Am. 109:3076-3079.

% Set up problem.
R = [10 0; 1 10];                % receiver posns, one per row; also at (0,0)
tau = [0.0254319; 0.0259020];    % time delays [tau21 tau31]
c = 330;                         % speed of sound

% Calculate
b = [norm(R(1,:))^2 - c^2 * tau(1)^2;
     norm(R(2,:))^2 - c^2 * tau(2)^2];
Rinv = inv(R);
a1 = (Rinv * b  )' * (Rinv * b  );
a2 = (Rinv * tau)' * (Rinv * b  );
a3 = (Rinv * tau)' * (Rinv * tau);

disp('Spiesberger''s equation:')
t1pos = (c*a2 + sqrt(c^2*a2^2 - (c^2*a3 - 1)*a1)) / (2*c * (c^2*a3 - 1)) * c
t1neg = (c*a2 - sqrt(c^2*a2^2 - (c^2*a3 - 1)*a1)) / (2*c * (c^2*a3 - 1)) * c

%disp('My equation:')
%t1pos = (a2 + sqrt(a2^2 - (a3 - 1/c^2)*a1)) / (2 * (c^2*a3 - 1)) * c
%t1neg = (a2 - sqrt(a2^2 - (a3 - 1/c^2)*a1)) / (2 * (c^2*a3 - 1)) * c

disp('Source, John''s eqn:')
spos = Rinv * b / 2 - c^2 * t1pos/c * Rinv * tau
sneg = Rinv * b / 2 - c^2 * t1neg/c * Rinv * tau

sA = [0.7184 0.5511];
sB = [-10.1506 -9.4319];
t1A = norm(sA) / c
%t1B = norm(sB) / c
t2A = norm(R(1,:) - sA) / c
%t2B = norm(R(1,:) - sB) / c
t3A = norm(R(2,:) - sA) / c
%t3B = norm(R(2,:) - sB) / c
tau12A = t1A - t2A
%tau12B = t1B - t2B
tau13A = t1A - t3A
%tau13B = t1B - t3B

disp(' ')
disp('Compare:')
sA
sB
Rinv * b / 2 - c^2 * t1A * Rinv * tau

disp(' ')
%norm(R(1,:) - sA)^2
%c^2 * t2A ^ 2
%c^2 * (-tau12A + t1A)^2

sA(1)*R(1,1) + sA(2)*R(1,2)
-1/2 * c^2 * tau(1)^2 - c^2 * tau(1) * t1A + 1/2 * (R(1,1)^2 + R(1,2)^2)
1/2 * norm(R(1,:))^2 - 1/2 * c^2 * tau(1)^2 - c^2 * t1A * tau(1)

disp(' ')
R * sA'
1/2 * b - c^2 * t1A * tau
