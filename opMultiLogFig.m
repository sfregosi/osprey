function varargout = opMultiLogFig(varargin)
% OPMULTILOGFIG M-file for opMultiLogFig.fig
%      OPMULTILOGFIG, by itself, creates a new OPMULTILOGFIG or raises the existing
%      singleton*.
%
%      H = OPMULTILOGFIG returns the handle to a new OPMULTILOGFIG or the handle to
%      the existing singleton*.
%
%      OPMULTILOGFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPMULTILOGFIG.M with the given input arguments.
%
%      OPMULTILOGFIG('Property','Value',...) creates a new OPMULTILOGFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before opMultiLogFig_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to opMultiLogFig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help opMultiLogFig

% Last Modified by GUIDE v2.5 24-Nov-2004 14:36:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @opMultiLogFig_OpeningFcn, ...
                   'gui_OutputFcn',  @opMultiLogFig_OutputFcn, ...
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


% --- Executes just before opMultiLogFig is made visible.
function opMultiLogFig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to opMultiLogFig (see VARARGIN)

% Choose default command line output for opMultiLogFig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes opMultiLogFig wait for user response (see UIRESUME)
% uiwait(handles.opMultiLogFig);


% --- Outputs from this function are returned to the command line.
function varargout = opMultiLogFig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function NLogsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NLogsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NLogsEdit as text
%        str2double(get(hObject,'String')) returns contents of NLogsEdit as a double


% --- Executes during object creation, after setting all properties.
function NLogsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NLogsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function LogNamesEdit_Callback(hObject, eventdata, handles)
% hObject    handle to LogNamesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LogNamesEdit as text
%        str2double(get(hObject,'String')) returns contents of LogNamesEdit as a double


% --- Executes during object creation, after setting all properties.
function LogNamesEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LogNamesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


