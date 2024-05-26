function varargout = chi2offset(varargin)
% CHI2OFFSET MATLAB code for chi2offset.fig
%      CHI2OFFSET, by itself, creates a new CHI2OFFSET or raises the existing
%      singleton*.
%
%      H = CHI2OFFSET returns the handle to a new CHI2OFFSET or the handle to
%      the existing singleton*.
%
%      CHI2OFFSET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHI2OFFSET.M with the given input arguments.
%
%      CHI2OFFSET('Property','Value',...) creates a new CHI2OFFSET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before chi2offset_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to chi2offset_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help chi2offset

% Last Modified by GUIDE v2.5 17-Nov-2013 20:30:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @chi2offset_OpeningFcn, ...
                   'gui_OutputFcn',  @chi2offset_OutputFcn, ...
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


% --- Executes just before chi2offset is made visible.
function chi2offset_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to chi2offset (see VARARGIN)

% Choose default command line output for chi2offset
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes chi2offset wait for user response (see UIRESUME)
% uiwait(handles.figure1);
butRefresh_Callback(hObject, eventdata, handles)



% --- Outputs from this function are returned to the command line.
function varargout = chi2offset_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in lbNames.
function lbNames_Callback(hObject, eventdata, handles)
    contents = cellstr(get(handles.lbNames,'String'));
    if isempty(contents), return, end;
    
    sname = contents{get(handles.lbNames,'Value')};
    spc = evalin('base','spc'); 
    idx = find(cellfun(@(x) strcmp(x,sname), contents));
    idx = idx(1);
    set(handles.txtChi2,'String',['Chi2 = ' num2str(spc.fit.fits{idx}.gof.sse,'%5.3e')])
    

% --- Executes during object creation, after setting all properties.
function lbNames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butRefresh.
function butRefresh_Callback(hObject, eventdata, handles)

spc = evalin('base','spc');
co = str2double(get(handles.edtCutoff,'String'));
if isnan(co), return, end;

chis = [];
set(handles.txtMsg,'String','');
for i = 1:spc.N
    if isempty(spc.fit.fits{i})
        set(handles.txtMsg,'String','Not all spectra are included!');
        continue
    end
    chis(i) = spc.fit.fits{i}.gof.sse;
end

hist(handles.axeHist,chis,20);
v = axis(handles.axeHist);

if co < v(1,1)
    co = v(1,1);
end
line('XData',[co co],'YData',v(3:4),'Parent',handles.axeHist,'Tag','vline','Color',[0.7 0.7 0.7],'HitTest','off')
xlabel('Chi2')
ylabel('Frequency')

set(handles.axeHist,'ButtonDownFcn',@axeHist_ButtonDownFcn);

sel = chis > co;
set(handles.lbNames,'String',spc.names(sel));
set(handles.lbNames,'Value',1);
set(handles.edtCutoff,'String',num2str(co,'%5.5e'));
lbNames_Callback(hObject, eventdata, handles);



function edtCutoff_Callback(hObject, eventdata, handles)
% hObject    handle to edtCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtCutoff as text
%        str2double(get(hObject,'String')) returns contents of edtCutoff as a double


% --- Executes during object creation, after setting all properties.
function edtCutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function axeHist_ButtonDownFcn(hObject, eventdata, handles)
    pos = get(hObject,'CurrentPoint');
    co = pos(1,1);

    ob = findobj('Tag','edtCutoff');
    set(ob,'String',num2str(co,'%5.5e'));

    
    ob = findobj(hObject,'Tag','vline');
    v = axis(hObject);
    if isempty(ob)
        line('XData',[co co],'YData',v(3:4),'Parent',hObject,'Tag','vline','Color',[0.7 0.7 0.7],'HitTest','off')
    end
    set(ob,'XData',[co co],'YData',v(3:4));
    handles = guidata(hObject);
    butRefresh_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function axeHist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axeHist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axeHist


% --- Executes on button press in butSet.
function butSet_Callback(hObject, eventdata, handles)
% hObject    handle to butSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
