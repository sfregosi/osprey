
% An example run of the code.

if (1)
  disp(' ')
  disp('************ Localization using INTER-PHONE TIME DELAYS *************')
  disp(' ')
  
  arr        = [0 1; 1 1; 1 0]';
  c          = 10;
  
  disp('Enter these values when asked:')
  disp('   number of inter-phone delays: 3')
  disp('   between #1 and #2, 0.051')
  disp('   between #1 and #3, 0')
  disp('   between #2 and #3, -0.049')
  disp(' ')
  
  [m1,m2,delays,useful] = enterDelays(arr, c);
  locateDelays
  disp('Best location should have been approximately [0.78 0.78]')
  disp(' ')
end
if (1)
  input('Press return to continue.', 's');
  disp(' ')
  disp('*************** Localization using TIMES OF ARRIVAL *****************')
  disp(' ')
  disp('Now enter these values:')
  disp('   number of phones: 3')
  disp('   arrival time for phone #1: 5.5')
  disp('   arrival time for phone #2: 5.51')
  disp('   arrival time for phone #3: 5.49')
  disp(' ')
  
  [m1,m2,delays,useful] = enterTimes(arr, c);
  locateDelays
  disp('Best location should have been approximately [0.42 0.34]')
end
if (1)
  disp(' ')
  input('Press return to continue.', 's');
  
  disp(' ')
  disp('********** Localization using TIME DELAY DATA FROM FILES ************')
  
  % The array and location are from Sean Hayes's blue whale array.
  % The files were originally called 'array4.txt' and 'lb12.txt'.
  %
  % The positions are in kilometers.
  
  disp(' ')
  disp('Loading data from files...')
  arrcols = 1:2;
  arrfile = 'testarray4';
  delayfile = 'testpos12';
  fileDelays
  c = 1.510;
  locateDelays
  disp('Best location should have been approximately [-10847.3  4082.6]')
end  
if (1)
  disp(' ')
  input('Press return to continue.', 's');
  
  disp(' ')
  disp('******* 3-DIMENSIONAL Localization using time delay data from files ********')
  
  % The array and location are from Sean Hayes's blue whale array.
  % The files were originally called 'array4.txt' and 'lb12.txt'.
  %
  % The positions are in kilometers.
  
  disp(' ')
  disp('Loading data from files...')
  arrcols = 1:3;
  arrfile = 'testarray4_3d';
  delayfile = 'testpos12_3d';
  fileDelays
  c = 343;
  locateDelays
  disp('Best location should have been [1.0  0.5  0.2]')
end
