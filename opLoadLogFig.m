function varargout = opLoadLogFig(varargin)
% OPLOADLOGFIG M-file for opLoadLogFig.fig
%      OPLOADLOGFIG, by itself, creates a new OPLOADLOGFIG or raises the existing
%      singleton*.
%
%      H = OPLOADLOGFIG returns the handle to a new OPLOADLOGFIG or the handle to
%      the existing singleton*.
%
%      OPLOADLOGFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPLOADLOGFIG.M with the given input arguments.
%
%      OPLOADLOGFIG('Property','Value',...) creates a new OPLOADLOGFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before opLoadLogFig_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to opLoadLogFig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help opLoadLogFig

% Last Modified by GUIDE v2.5 25-Jul-2011 11:45:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @opLoadLogFig_OpeningFcn, ...
                   'gui_OutputFcn',  @opLoadLogFig_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before opLoadLogFig is made visible.
function opLoadLogFig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to opLoadLogFig (see VARARGIN)

% Choose default command line output for opLoadLogFig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes opLoadLogFig wait for user response (see UIRESUME)
% uiwait(handles.opLoadLogDialog);


% --- Outputs from this function are returned to the command line.
function varargout = opLoadLogFig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function datalogNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to datalogNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of datalogNameEdit as text
%        str2double(get(hObject,'String')) returns contents of datalogNameEdit as a double


% --- Executes during object creation, after setting all properties.
function datalogNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datalogNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function datacolumnsNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to datacolumnsNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of datacolumnsNameEdit as text
%        str2double(get(hObject,'String')) returns contents of datacolumnsNameEdit as a double


% --- Executes during object creation, after setting all properties.
function datacolumnsNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datacolumnsNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
