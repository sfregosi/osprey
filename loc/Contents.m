%
%Time Delay Localization
%-----------------------
%
%This directory has files for doing time-delay localization.  In
%time-delay localization, a source emits a sound (or some other type of
%signal), which is received at a number of microphones or other sensors.
%
%The sound arrives at the microphones at slightly different times.  For
%any two microphones, the delay between the arrival times at the
%microphones determines a curve -- a hyperbola -- on which the sound
%source must lie.  With three or more microphones, the intersecting
%hyperbolas determine the sound source location.  (Although sometimes
%they don't, and the location is ambiguous; see the reference at the top
%of Spiesberger.m.)
%
%Since there is error in the measurement of the time delays, there will
%be error in the measured location.  Multiple time-delay measurements
%allow the position of the sound source to be pinpointed with higher
%accuracy.
%
%Locations may be calculated in either 2 or 3 dimensions.
%
%To make this localization method work, you need to know
%
%  - the locations of the microphones (the array),
%  - the speed of sound (assumed to be uniform over the whole area), and
%  - either (1) the time delays between pairs of microphones, or (2) the
%    arrival times of the sound signal at the different microphones
%    (from which the time delays are computed)
%    
%
%The M-files of interest are
%
%enterDelays.m  lets you enter time delays between microphones from keyboard
%fileDelays.m   reads the time delays from a file instead of from the keyboard
%locateDelays.m given the time delays, computes and plots best-fitting location
%
%enterTimes.m   lets you enter the times the signal arrived at each microphone
%fileTimes.m    reads arrival times from a file instead of from the keyboard
%locateTimes.m  given arrival times, computes and plots best-fitting location
%
%test.m         example run of the code (uses testarray4 and testpos12)
%locAccuracy.m  plots the relative accuracy of locations for a given array
%delayFromSound.m  uses sound signal to calculate time delays via 
%                  cross-correlation; requires signal processing toolbox
%
%
%Auxiliary functions are
%
%timesToDelays.m        auxiliary function for enterTimes; calculates delays
%checkScale.m           controls entering times in seconds or milliseconds
%bestFit.m              actually computes the best-fit location
%CalcDeltaTimes.m       auxiliary fn to bestFit; calculates arrival times
%CalcDeltaJacobian.m    axuiliary fn to bestFit; computes guess-location error
%dist.m                 Euclidean distance function
%showResults.m          plots microphones, hyperbolae, and best-fit location
%plotPhones.m           auxiliary function to showResults; plots
%PlotHyperbola.m        plots a hyperbola
%PlotHyperbolas.m       plots several hyperbolae
%Spiesberger.m          closed-form solution for 3-phone case
