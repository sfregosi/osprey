
% This is a startup.m file for using Osprey. When you start Matlab so that
% it uses this startup file (see below for instructions to do this), it 
% will launch Osprey automatically. You can use this file directly, or if
% you already have a startup.m file, you can append the contents of this
% file to yours. In any case, edit the text below as needed.


% Change the following command to specify where you installed the 'osprey'
% folder.
path(path, 'C:\Program Files\osprey');


% On Windows, you can make an Osprey icon for your desktop this way: 
% 1) Find matlab.exe on your hard drive. It might be in C:\Program
%    Files\MATLAB\R20xxx\bin (where xxx is something like 17a), or maybe
%    C:\MATLAB or something.
%
% 2) Create a shortcut to matlab.exe by right-clicking on it and
%    choosing "Create shortcut", then put the shortcut on your desktop.
%
% 3) Rename the shortcut 'Osprey'.
%
% 4) Right-click on the shortcut and choose 'Properties'. In the box labeled
%    'Start in', type the folder name where this file, startup.m, is stored.
%    For example, if this file is C:\MyHome\osprey\startup.m, then change the
%    'Start in' box to say C:\MyHome\osprey .
%
% You're done -- you should be able to launch Osprey by double-clicking on your
% desktop icon.


% The following cd command is optional. If you uncomment it (by removing the
% '%' at the start of the line), it will make Osprey start up in the folder it
% specifies, so you don't have to hunt around to find your data files. Edit the
% stuff between the quote marks to make it be the folder where you store your
% data:
%cd('C:\MyHome\MyDataDir\');


% If you have trouble with Matlab's 'splash box' (the box at startup that says
% 'Matlab' and shows the orange hump-shaped graph) sticking on the screen when
% you first launch Matlab/Osprey, then uncomment this line:
%pause(3)


% Tell Matlab not to put so much blank space in. Optional.
format compact

% Launch Osprey.
osprey
