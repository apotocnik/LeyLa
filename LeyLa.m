function varargout = LeyLa(varargin)
% LEYLA M-file for LeyLa.fig
%      LEYLA, by itself, creates a new LEYLA or raises the existing
%      singleton*.
%
%      H = LEYLA returns the handle to a new LEYLA or the handle to
%      the existing singleton*.
%
%      LEYLA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LEYLA.M with the given input arguments.
%
%      LEYLA('Property','Value',...) creates a new LEYLA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spcFit_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LeyLa_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% List_Box the above text to modify the response to help LeyLa

% Last Modified by GUIDE v2.5 05-Jul-2014 20:48:24

% Begin initialization code - DO NOT LIST_BOX
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LeyLa_OpeningFcn, ...
                   'gui_OutputFcn',  @LeyLa_OutputFcn, ...
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
% End initialization code - DO NOT LIST_BOX


% --- Executes just before LeyLa is made visible.
function LeyLa_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LeyLa (see VARARGIN)

% Choose default command line output for LeyLa
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using LeyLa.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5,1));
end

% UIWAIT makes LeyLa wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Initialize popFunctions and popSimFun
funs = spc_fun_lib('');  % Get functions name cell
set(handles.popFunctions, 'String',funs);
set(handles.uitSpline,'Data',[]);

% Set pointer values to guidata
set(handles.txtSell,'BackgroundColor',get(handles.figure1,'Color'));
set(handles.txtVersion,'BackgroundColor',get(handles.figure1,'Color'));
set(handles.figure1, 'KeyPressFcn', @figure1_KeyPressFcn); 

% Create spc default sturcture in does not exist 
if evalin('base','exist(''spc'',''var'')') == 0
   createDefEprStruct();
end



% User Function Create Default spc structure in base work space
function createDefEprStruct()

    evalin('base','spc.material=''material'';');
    evalin('base','spc.mass=0.0;');
    evalin('base',['spc.date=''' datestr(now,'dd-mm-yyyy') ''';']);
    evalin('base','spc.fit.fits={};');
%     evalin('base','spc.nra=[];');
    evalin('base','spc.desc={};');
    evalin('base','spc.names={};');
    disp(['Default spc structure (material / 0mg / ' datestr(now,'dd-mm-yyyy') ')']);




% --- Outputs from this function are returned to the command line.
function varargout = LeyLa_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --------------------------------------------------------------------
function PrintMenuItem_Callback(~, eventdata, handles)
    printpreview(handles.figure1)



% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)

    selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                         ['Close ' get(handles.figure1,'Name') '...'],...
                         'Yes','No','Yes');
    if strcmp(selection,'No')
        return;
    end

    delete(handles.figure1)



% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes on selection change in lbFiles.
function lbFiles_Callback(hObject, eventdata, handles)
    
    spcplot(handles);
    spc_update(hObject, eventdata, handles);




% --- Executes during object creation, after setting all properties.
function lbFiles_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    if evalin('base','exist(''spc'',''var'')') == 1
        spc = evalin('base','spc');
        if isfield(spc,'data')
            for i=1:numel(spc.data)
                [pathstr, name, ext] = fileparts(spc.data{i}.fname);
                shownames{i} = name;
            end
            set(hObject, 'String', shownames);
        else
            set(hObject, 'String', []);
        end
    else
        set(hObject, 'String', []);
    end






% --- Executes during object creation, after setting all properties.
function popFunctions_CreateFcn(hObject, ~, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butFitAdd.
function butFitAdd_Callback(hObject, eventdata, handles)

    func_num = get(handles.popFunctions, 'Value');
    func_list = get(handles.popFunctions, 'String');
    list_sel = get(handles.lbFunctions, 'String');
    coefs = get(handles.uitFit, 'Data');
    param_num = size(coefs,1);

    % Delete empty rows
    rm = [];
    for i=1:param_num
       if strcmp(coefs{i,1},''); 
           rm = [rm i];
       end
    end
    coefs(rm,:)=[];
    param_num = size(coefs,1);

    % Search for slope and offset and max number
    isSlope = false;
    isOffset = false;
    max_number=0;
    for i=1:numel(list_sel)
         if strcmp('slope',list_sel{i})
             isSlope = true;
         elseif strcmp('offset',list_sel{i})
             isOffset = true;
         else
            numb = str2double(list_sel{i}(~isletter(list_sel{i})));
            if numb > max_number
                max_number = numb;
            end
         end
    end

    % Set max value
    apend = num2str(max_number+1);
    
    % Only one term of slope and offset is allowed
    ft = fittype(spc_fun_lib(func_list{func_num}),'indep','x');
    cnames = coeffnames(ft);
    if strcmp(cnames{1},'slope') 
        if isSlope == false
            apend = '';
        else
            return
        end
    end
    if strcmp(cnames{1},'offset') 
        if isOffset == false
            apend = '';
        else
            return
        end
    end

    % Add coefficients to the table
    for j=1:numel(cnames)
        vrstica = {[cnames{j} apend],0,0,Inf,false};
        coefs = [coefs; vrstica];
        set(handles.uitFit, 'Data', coefs);
    end

    % Add function
    list_sel{numel(list_sel)+1} = [func_list{func_num} apend];
    set(handles.lbFunctions, 'Value',1);
    set(handles.lbFunctions, 'String',list_sel);



% --- Executes during object creation, after setting all properties.
function lbFunctions_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function lbParameters_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butFitRem.
function butFitRem_Callback(hObject, eventdata, handles)

    list_sel = get(handles.lbFunctions, 'String');
    list_num = get(handles.lbFunctions, 'Value');
    coefs = get(handles.uitFit,'Data');
    
    if isempty(list_sel), return; end;
    funName = list_sel{list_num};
    
    % Get Function number
    tmp = list_sel{list_num};
    tmp(isletter(tmp)) = [];                % remove lettters
    if isempty(tmp)
        funNumber = '0';
    else
        funNumber = tmp;
    end

    % Find parameters with function number 
    tmp = cellfun(@(x) x(isstrprop(x,'digit')),coefs(:,1),'UniformOutput',false);
    tmp(cellfun('isempty',tmp)) = {'0'};
    tmp = cellfun(@(x) str2double(x), tmp);
    rem = find(tmp == str2double(funNumber));

    
    % Find slope parameter
    if strcmp(funName,'slope')
        rem = [];
        for i=1:size(coefs,1)
            if strfind(coefs{i,1},'slope')
                rem = [rem i];
            end
        end
    end
    % Find offset parameter
    if strcmp(funName,'offset')
        rem = [];
        for i=1:size(coefs,1)
            if strfind(coefs{i,1},'offset')
                rem = [rem i];
            end
        end
    end
    
    % Remove parameters
    coefs(rem,:) = [];
    
    % Remove function
    list_sel(list_num) = [];

    if ~strcmp(funName,'offset') && ~strcmp(funName,'slope')
        % change number order for functions
        for i=list_num:numel(list_sel)
           par = list_sel{i};
           name = par; name(~isletter(name))=[];
           number = par; number(isletter(number))=[];
           number = num2str(str2double(number)-1);
           if strcmp(number,'NaN'), number = ''; end;
           list_sel{i} = [name number];
        end
        
        % change number order for coefficients
        for i=rem(1):size(coefs,1)
           par = coefs{i,1};
           name = par; name(~isletter(name))=[];
           number = par; number(isletter(number))=[];
           number = num2str(str2double(number)-1);
           if strcmp(number,'NaN'), number = ''; end;
           coefs{i,1} = [name number];
        end
        
    end
    
    % write fields
    set(handles.uitFit,'Data',coefs);
    set(handles.lbFunctions, 'String',list_sel);

    % Set function value
    if list_num > 1
        set(handles.lbFunctions, 'Value',list_num-1);
    else
        set(handles.lbFunctions, 'Value',1);
    end




% --- Executes on button press in butPlotFunc.
function butPlotFunc_Callback(hObject, eventdata, handles)

%     working(1,handles);
%     axes(handles.axes1);
    set(gcf, 'CurrentAxes', handles.axes1);
    if strcmp(ylim('mode'),'manual')
        yLims = ylim;
    end
    if strcmp(xlim('mode'),'manual')
        xLims = xlim;
    end

    [funstr Nfun] = getEquation(handles);
    coefs = get(handles.uitFit,'Data');
    coefstr = coefs(:,1);
    coefval = coefs(:,2);
    if isempty(coefval)
        spcplot(handles);
        return
    end
    
    idx = get(handles.lbFiles, 'Value');
    spc = evalin('base','spc');
    
    cla;
    plot(spc.data{idx}.H,spc.data{idx}.Y,'k');
    hold on
    
    fty = fittype(funstr,'coef',coefstr);
    tmp='';
    for i=1:numel(coefval)  % write parameters in cfit function
       tmp = [tmp ',' num2str(coefval{i})];  
    end

    range = get(handles.edtFitRange, 'String');

    [H Y] = extrange(spc.data{idx}.H,spc.data{idx}.Y,range);
    spc.fit.range = range;

    H = reshape(H,[],1);
    Y = reshape(Y,[],1);

    cf = eval(['cfit(fty' tmp ');']);
    cf = reshape(cf(H),size(H));
    line('XData',H,'YData',cf,'Color','r','HitTest','off');
    
    line('XData',H,'YData',Y-cf,'Color',[1 165/256 0],'HitTest','off');
    
    % Plot components
    if get(handles.chkShowComp,'value') == 1
        for i=1:Nfun
            funstr = getEquation(handles,i);
            futy = fittype(funstr);
            cs = coeffnames(futy);

            tmp='';
            for j=1:numel(cs)  % write parameters in cfit function
                ind = cellfun(@(x) isequal(x,cs{j}),coefstr);
                tmp = [tmp ',' num2str(coefval{ind})];  
            end
            cf = eval(['cfit(futy' tmp ');']);
            cf = reshape(cf(H),size(H));
            line('XData',H,'YData',cf,'Color','b','HitTest','off');
%             plot(H,cf,'c');
        end
        legend({spc.names{idx},'Simulation','Data-Sim','Components'},'Interpreter','none');
    else
        legend({spc.names{idx},'Simulation','Data-Sim'},'Interpreter','none');
    end
    hold off

    if exist('yLims','var')
        ylim(yLims);
    end

    if exist('xLims','var')
        xlim(xLims);
    else
        if H(1) < H(end)
            xlim([H(1) H(end)]);
        else
            xlim([H(end) H(1)]);
        end
    end

    if ~isempty(spc.mass) 
        title([spc.material '  ' num2str(spc.mass) 'mg  ' spc.date]);
    else
        title([spc.material '  ' spc.date]);
    end
    
    xlabel('Wavenumber (cm^{-1})');
    ylabel('Intensity (arb. units)');
    grid on
    backupFit(handles);
    set(handles.axes1,'ButtonDownFcn',@axes1_ButtonDownFcn);
%     working(0,handles);


% --- Executes on button press in butFitOpts.
function butFitOpts_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');

    if isfield (spc.fit,'opts')
        opts = spc.fit.opts;
    else
        opts = fitoptions('Method','Nonlinear');
        opts.Algorithm =  'Trust-Region';            % 'Trust-Region'  'Levenberg-Marquardt'
        opts.Display =    'notify';                  % 'notify'  'off'  'iter'
        opts.MaxIter = 1000;
        opts.MaxFunEvals = 1000;
        opts.TolFun = 1e-10;
        opts.TolX = 1e-10;
        opts.Robust = 'Off';
    end
    inspect(opts);
        




% --- Executes on button press in butFitFunc.
function butFitFunc_Callback(hObject, eventdata, handles)
    
    working(1,handles);
    repeat = str2double(get(handles.edtFitRepeat, 'String'));
    for k=1:repeat
        
        idx = get(handles.lbFiles, 'Value');
        idx = idx(1);
        spc = evalin('base','spc');
        fitfun = getEquation(handles);

        opts = fitoptions('Method','Nonlinear');
        opts.Display =    'notify';    % 'notify'  'off'  'iter'
        opts.Algorithm = 'Trust-Region'; %'Levenberg-Marquardt' 
        opts.MaxIter = 1000;
        opts.MaxFunEvals = 1000;
        opts.TolFun = 1e-10; 
        opts.TolX = 1e-10;
        opts.Robust = 'Off'; %Off On LAR Bisquare

        uicoefs = get(handles.uitFit,'Data');
        coefstr = uicoefs(:,1);
        coefval = uicoefs(:,2);
        lowerlimit = uicoefs(:,3);
        upperlimit = uicoefs(:,4);
        fixvary = uicoefs(:,5);

        coef = [];  % Clear coef and prob

        % Get variable parameters
        for i=1:numel(coefstr)
            coef.(coefstr{i}) = [coefval{i} lowerlimit{i} upperlimit{i} ~fixvary{i}]; 
        end

        spc.fit.options = opts;
        spc.fit.chosen = idx;     % Simulate only selected
        spc.fit.fitfun = fitfun;
        spc.fit.coef = coef;
        spc.fit.plot = 0;   % Please do NOT plot fitted specters and results
        spc.fit.range = get(handles.edtFitRange, 'String');

        idx_curr=idx;
        SPC_fit;

        % Refresh new coefficients
        coef_names  = fieldnames(spc.fit.coef)';
        if (size(spc.fit.results,2))/2 ~= size(uicoefs,1)
            return
        end
        for i=1:(size(spc.fit.results,2))/2
            ind = -1;
            for j=1:size(uicoefs,1)
                if strcmp(uicoefs{j,1},coef_names{i})
                    ind = j;
                    break
                end
            end
            if ind > 0
                uicoefs{ind,2} = spc.fit.results(idx_curr,i*2-1);
            end
        end
        spc.fit.fits{idx}.uicoefs = uicoefs;
        spc.fit.fits{idx}.functions = get(handles.lbFunctions,'String'); % NEW

        if get(handles.chkKeepIniPar,'Value') == 1
            set(handles.uitFit,'Data',uicoefs);
        end
        set(handles.txtChi2, 'String',['Chi^2 = ' num2str(spc.fit.fits{idx_curr}.gof.sse,'%5.3e')]);


        set(handles.chkPlotFit,'Value',1);
        set(handles.chkPlotFit,'Enable','on');
        butPlotFunc_Callback(hObject, eventdata, handles);
    
    end

    % Save spc
    assignin('base','spc',spc);
    backupFit(handles);
    working(0,handles);



% --- Executes on button press in butRunFitFun.
function butRunFitFun_Callback(hObject, eventdata, handles)

    % Code for interrupting run loop
    if strcmp(get(hObject,'String'),'Stop')
       evalin('base','STOP=1;'); 
       set(hObject,'String','Run');
       return
    end
    
    idx = get(handles.lbFiles, 'Value');
    max_idx = numel(get(handles.lbFiles, 'String'));

    prompt = {'start idx:','stop idx:','abs(step):'};
    dlg_title = 'Run fits';
    num_lines = 1;
    def = {num2str(idx),num2str(max_idx),'1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if ~isempty(answer) % If CANCEL, answer is empty
        idx = str2double(answer{1});
        max_idx = str2double(answer{2});
        step = str2double(answer{3});
    else 
        return
    end
    
    set(hObject,'String','Stop');
    evalin('base','clear STOP'); 
    
    step = sign(max_idx-idx)*abs(step);

    for i = idx:step:max_idx
        set(handles.lbFiles, 'Value',i);
        spcplot(handles);
        refresh;
        butFitFunc_Callback(hObject, eventdata, handles);
        refresh;
        if evalin('base','exist(''STOP'',''var'')') == 1
            evalin('base','clear STOP');
            break;
        end
    end
    disp('Fit run done!');
    set(hObject,'String','Run');



% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popMethod_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edtMaxIter_CreateFcn(hObject, eventdata, handles)
% Hint: list_box controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edtMaxFunE_CreateFcn(hObject, eventdata, handles)
% Hint: list_box controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edtTolFun_CreateFcn(hObject, eventdata, handles)
% Hint: list_box controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edtTolX_CreateFcn(hObject, eventdata, handles)
% Hint: list_box controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function popRobust_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% User function: retruns equation string from lbFunction
function [equ Nfun] = getEquation(handles,i)

    
    list_sel = get(handles.lbFunctions, 'String');
    equ = '';
    Nfun = numel(list_sel);

    if nargin == 1
        list = 1:Nfun;
    elseif nargin == 2
        list = i;
        if i < 1 || i > Nfun
            error(['i must be greater than 1 or smaller then ' num2str(Nfun)])
        end
    else
        error('equ = getEquation(handles,[i]) requires one or two arguments!!!')
    end
    
    for i=list
         if strcmp('s*x',list_sel{i})
            equ = [equ ' + s*x'];
         elseif strcmp('y0',list_sel{i})
            equ = [equ ' + y0'];
         else
            number = str2double(list_sel{i}(~isletter(list_sel{i})));
            func = list_sel{i}(isletter(list_sel{i}));
            equ = [equ ' + ' spc_fun_lib(func,number)];
         end
    end







% User function: plots data with fit 
function spcplot(handles)
% tic
    idx = get(handles.lbFiles, 'Value');
    chk_Fit = get(handles.chkPlotFit, 'Value');
    spc = evalin('base','spc');

    LW = 1.0; % LineWidth

    
    axes(handles.axes1);
    
      
    if strcmp(ylim('mode'),'manual')
        yLims = ylim;
        xLims = xlim;
    end

    cla;    % Clear graph
    
    if spc.N < 1
        return
    end

    j=1; % color counter
    leg=1; % legend counter

    for i=idx

        H = spc.data{i}.H; %cm-1
        Y = spc.data{i}.Y;
        
        line('XData',H,'YData',Y,'Color',colors(j),'LineWidth',LW,'HitTest','off');

        M{leg} = spc.names{i};  %K, deg, pressure %name{i};
        leg=leg+1;
        hold on
        if chk_Fit
            if numel(spc.fit.fits) >= i && ~isempty(spc.fit.fits{i}) 
                line('XData',H,'YData',spc.fit.fits{i}.f(H),'Color','r','LineWidth',LW,'HitTest','off');
                M{leg} =  'Fit function';  %K, deg, pressure %name{i};
                leg=leg+1;
                set(handles.chkPlotFit,'Enable','on');
            else
                set(handles.chkPlotFit,'Enable','off');
            end
        end
        j=j+1;
    end
    
    tic
    legend(M,'Interpreter','none');
    toc

    if exist('yLims','var')
        ylim(yLims);
        xlim(xLims);
    else
        %if H(1) < H(end)
            xlim([H(1) H(end)]);
        %else
        %    xlim([H(end) H(1)]);
        %end
    end

    if ~isempty(spc.mass) 
        title([spc.material '  ' num2str(spc.mass) 'mg  ' spc.date]);
    else
        title([spc.material '  ' spc.date]);
    end


    % Draw points for spline base correction
    if numel(idx) == 1
        if isfield(spc.data{idx},'splinePoints')
            spoints = spc.data{idx}.splinePoints;
            x = cell2mat(spoints(:,1));
            y = cell2mat(spoints(:,2));
            plot(x,y,'o')

            if numel(x) > 2
                xx = spc.data{idx}.H;
                yy = spline(x,y,xx);
                plot(xx,yy)
            end
        end
    end
    

    hold off
    grid on
    xlabel('Wavenumber (cm^{-1})');
    ylabel('Intensity (arb. units)');
    
    set(handles.axes1,'ButtonDownFcn',@axes1_ButtonDownFcn);
    drawnow expose
%   toc


    


% User function: updates all spc text boxes
function spc_update(hObject, eventdata, handles)

%     working(1,handles);

    idx = get(handles.lbFiles, 'Value');
    spc = evalin('base','spc');
    set(handles.txtSell,'String',['Selected: ' num2str(idx)]);
    
    if numel(idx) > 1, return; end; % multiselection
    if spc.N < 1, return; end; % No data

    
    if get(handles.chkUpdate, 'Value') == 1

        % Update fitting functions
        if ~isempty(spc.fit.fits{idx})
            set(handles.lbFunctions,'String',spc.fit.fits{idx}.functions);
           
            % Refresh coefficients
            coefs = spc.fit.fits{idx}.uicoefs;
            
            if get(handles.chkDNUpdateFix,'Value')==0
                coefs_old = get(handles.uitFit,'Data');
                coefs(:,5) = coefs_old(:,5);
            end
            set(handles.uitFit,'Data',coefs);
            
            set(handles.txtChi2, 'String',['Chi^2 = ' num2str(spc.fit.fits{idx}.gof.sse,'%5.3e')]);               
        end

    end
    
    % Update Description edit box
    if ~isempty(spc.desc{idx})
        set(handles.edtDesc,'String',spc.desc{idx});
    else
        set(handles.edtDesc,'String','');
    end
    
    
    % Update points for spline base correction
    if isfield(spc.data{idx},'splinePoints')
        set(handles.uitSpline,'data',spc.data{idx}.splinePoints);
    else
        set(handles.uitSpline,'data',[]);
    end

%     working(0,handles);




% --- Executes on button press in butPointer1.
function butPointer1_Callback(hObject, eventdata, handles)



% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)



% % --- Executes on button press in butNAnalyse.
% function butNAnalyse_Callback(hObject, eventdata, handles)
% 



% --- Executes during object creation, after setting all properties.
function popWmethod_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function popXcmethod_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edtCutOff_CreateFcn(hObject, eventdata, handles)

% Hint: list_box controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edtBLCorr_CreateFcn(hObject, eventdata, handles)

% Hint: list_box controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in chkPlotFit.
function chkPlotFit_Callback(hObject, eventdata, handles)


% --- Executes on button press in chkUpdate.
function chkUpdate_Callback(hObject, eventdata, handles)


% --- Executes on selection change in lbFunctions.
function lbFunctions_Callback(hObject, eventdata, handles)



% --- Executes on selection change in popWmethod.
function popWmethod_Callback(hObject, eventdata, handles)


% --- Executes on selection change in popXcmethod.
function popXcmethod_Callback(hObject, eventdata, handles)




% --- Executes on selection change in popMethod.
function popMethod_Callback(hObject, eventdata, handles)

% --- Executes on selection change in popRobust.
function popRobust_Callback(hObject, eventdata, handles)

% --- Executes on selection change in popFunctions.
function popFunctions_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function mnuEPR_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)

function edtCutOff_Callback(hObject, eventdata, handles)

function edtBLCorr_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuExport_Callback(hObject, eventdata, handles)


function edtTolX_Callback(hObject, eventdata, handles)

function edtTolFun_Callback(hObject, eventdata, handles)


function edtMaxFunE_Callback(hObject, eventdata, handles)


function edtMaxIter_Callback(hObject, eventdata, handles)


% % --- Executes on button press in btnNRArun.
% function btnNRArun_Callback(hObject, eventdata, handles)
% 



% % --- Executes on button press in btnSaveNRAH1.
% function btnSaveNRAH1_Callback(hObject, eventdata, handles)
% 


% % --- Executes on button press in btnSaveNRAH2.
% function btnSaveNRAH2_Callback(hObject, eventdata, handles)
% 



% % --- Executes on button press in btnSaveNRAdH.
% function btnSaveNRAdH_Callback(hObject, eventdata, handles)
% 


% % --- Executes on button press in btnInegrate.
% function btnInegrate_Callback(hObject, eventdata, handles)
% 




% --- Executes on button press in butPlotRes2.
function butPlotRes2_Callback(hObject, eventdata, handles)



% --- Executes on button press in butPlotRes.
function butPlotRes_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    plot_sfi_results(spc);


% --- Executes on button press in butDelete.
function butDelete_Callback(hObject, eventdata, handles)



% --- Executes on button press in butReload.
function butReload_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    if isfield(spc,'data')
        set(handles.lbFiles, 'String', spc.names);
        axes(handles.axes1);
        title([spc.material '  ' num2str(spc.mass) 'mg  ' spc.date]);
    else
        set(handles.lbFiles, 'String', []);
    end



% % --- Executes on button press in butNRA.
% function butNRA_Callback(hObject, eventdata, handles)



% % --- Executes on button press in butFitting.
% function butFitting_Callback(hObject, eventdata, handles)



% % --- Executes on button press in butSimul.
% function butSimul_Callback(hObject, eventdata, handles)
% 




% --------------------------------------------------------------------
function mnuLoad_Callback(hObject, eventdata, handles)
    [FileName,PathName] = uigetfile({'*.*','All files'},'MultiSelect','on');
    if ~isequal(FileName, 0)
        cd(PathName)
        spc = evalin('base','spc');
        if ~iscell(FileName), FileName = {FileName}; end; 
        for i=1:numel(FileName)
            spc.path = [PathName FileName{i}];
            SPC_load;
            spc.fit.fits{spc.N} = [];
        end
        assignin('base','spc',spc);
        butReload_Callback(hObject, eventdata, handles);
        set(handles.lbFiles, 'Value',spc.N);
        spcplot(handles);
        spc_update(hObject, eventdata, handles);
        axis auto
    end




% --------------------------------------------------------------------
function mnuSampleD_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');

    prompt = {'Material:','Mass [mg]:','Date:'};
    dlg_title = 'Sample Description';
    num_lines = 1;
    if isfield(spc,'material')
        def = {spc.material,num2str(spc.mass),spc.date};
    else
        def = {'DPPH','0.0',datestr(now, 'dd-mm-yyyy')};
    end
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if ~isempty(answer) % If CANCEL answer is empty
        spc.material = answer{1};
        spc.mass = answer{2};
        spc.date = answer{3};
    end

    axes(handles.axes1);
    title([spc.material '  ' num2str(spc.mass) 'mg  ' spc.date]);

    assignin('base','spc',spc);



% --- Executes on button press in butEdit.
function butEdit_Callback(hObject, eventdata, handles)

%     
% % --------------------------------------------------------------------
% function mnuSort_Callback(hObject, eventdata, handles)
% 


% --------------------------------------------------------------------
function toolSave_ClickedCallback(hObject, eventdata, handles)

    [FileName,PathName] = uiputfile('*.sfi');
    if ~isequal(FileName, 0)
        cd(PathName);
        spc = evalin('base','spc');
        save([PathName FileName],'spc');
    end


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)

    [FileName,PathName] = uigetfile('*.sfi');
    if ~isequal(FileName, 0)
        cd(PathName)
        load([PathName FileName],'-mat');

        if ~exist('spc','var')
            errordlg('Wrong file format!');
            return
        end

        % Verify Compatibility 
        spc = veryfyCompatibility(spc,hObject,eventdata,handles);
        
        assignin('base','spc',spc);

        butReload_Callback(hObject, eventdata, handles);
        set(handles.lbFiles, 'Value',spc.N);
        spc_update(hObject, eventdata, handles);
        spcplot(handles);
        axis auto
    end

    
    
% --------------------------------------------------------------------
function spc = veryfyCompatibility(spc,hObject,eventdata,handles)

	if ~isfield(spc,'fit')
        spc.fit.fits={}; 
        return   % nothing to change
    end
    
    if isempty(spc.fit.fits)
        return   % nothing to change
    end
    
    if isfield(spc.fit.fits{1},'functions')
        return;  % it is the latest version, return
    end
   
    
    % Find functions
    spc.fit.fitfun = strrep(spc.fit.fitfun,'alpha','ulphu');
    spc.fit.fitfun = strrep(spc.fit.fitfun,'a','area');
    spc.fit.fitfun = strrep(spc.fit.fitfun,'w','width');
    spc.fit.fitfun = strrep(spc.fit.fitfun,'xc','pos');
    spc.fit.fitfun = strrep(spc.fit.fitfun,'ulphu','alpha');
    
    funs = get(handles.popFunctions,'String');
    set(handles.lbFunctions,'String','');
%     set(handles.uitFit,'Data',[]);
    
    for j=1:50   % Test for 50 function of the same type
        for i=1:numel(funs)-2
            testfun = spc_fun_lib(funs{i},j);
            if ~iscell(testfun)  % Search only among found functions - unknown name results in cell array of known functions
                k = strfind(spc.fit.fitfun, testfun);
                if isempty(k)
                    ttfun = testfun;
                    ttfun(strfind(ttfun,'+'))=[];
                    ttfun(strfind(ttfun,'-'))=[];
                    fffun = spc.fit.fitfun;
                    fffun(strfind(fffun,'+'))=[];
                    fffun(strfind(fffun,'-'))=[];
                    k = strfind(fffun, ttfun);
                    if k > 0
                        disp(['Function found was without + or - !!! =>' funs{i}]);
                    end
                end
                if k > 0
                    set(handles.popFunctions,'Value',i)
                    butFitAdd_Callback(hObject, eventdata, handles);
                    break;
                end
            end
        end
    end
    
    % Separeated because they have only one instance - no number at the
    % end
    k = strfind(spc.fit.fitfun, 'slope');
    if k > 0
        set(handles.popFunctions,'Value',numel(functions)-1)
        butFitAdd_Callback(hObject, eventdata, handles);
    end
    k = strfind(spc.fit.fitfun, 'offset');
    if k > 0
        set(handles.popFunctions,'Value',numel(functions))
        butFitAdd_Callback(hObject, eventdata, handles);
    end

    
    
    % find nonempty fits
    idx = find(cellfun('isempty',spc.fit.fits)==0);
    
    for i=idx
    
        % save functions
        spc.fit.fits{i}.functions = get(handles.lbFunctions,'String');

        % rename parameters
        coefs = spc.fit.fits{i}.uicoefs;
        for j=1:size(coefs,1)
            coefs{j,1} = strrep(coefs{j,1},'alpha','ulphu');
            coefs{j,1} = strrep(coefs{j,1},'a','area');
            coefs{j,1} = strrep(coefs{j,1},'w','width');
            coefs{j,1} = strrep(coefs{j,1},'xc','pos');
            coefs{j,1} = strrep(coefs{j,1},'ulphu','alpha');
        end
        spc.fit.fits{i}.uicoefs = coefs;
    end

    % Remove obsoleete results# field names from spc
    finames = fieldnames(spc);
    for i=1:numel(finames)
        if strfind(finames{i},'results')
            spc = rmfield(spc,finames{i});
        end
    end
        

% --------------------------------------------------------------------
function mnuExpFit_Callback(hObject, eventdata, handles)

    [FileName,PathName] = uiputfile('*.dat');
    if ~isequal(FileName, 0)
        cd(PathName);
        spc = evalin('base','spc');
        idx = get(handles.lbFiles, 'Value');
        export_fit([PathName FileName],spc,idx);
    end
    msgbox(['Fit has been saved to ' [PathName FileName]],'Saved');


% --------------------------------------------------------------------
function mnuExpAFit_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    names = get(handles.lbFiles, 'String');
    FileName = ['sim_' names{1} '.dat'];
    [FileName,PathName] = uiputfile('*.dat','Save to directory',FileName);
    if ~isequal(FileName, 0)
        ret = questdlg('All files will be saved in this directory with an appendix ''sim_...'' .','Confirm');
        if ~strcmp(ret,'Yes')
            return
        end
        cd(PathName);

        for i=1:numel(names)
            FileName = ['sim_' names{i} '.dat'];
            export_fit([PathName FileName],spc,i);
        end
    end
    msgbox(['Fits have been saved to ' PathName],'Saved');



% % --------------------------------------------------------------------
% function mnuExpSim_Callback(hObject, eventdata, handles)
% 

% % --------------------------------------------------------------------
% function mnuExpASim_Callback(hObject, eventdata, handles)
% 


% User function: export fit
function export_fit(Filename, spc, idx)

    H = spc.data{idx}.H';
    Y = spc.data{idx}.Y';
    F = spc.fit.fits{idx}.f(H)';

    fid = fopen(Filename, 'wt');
    fprintf(fid, '# spcFit 3.0  exported data+fit file;  Anton Potocnik @ IJS F5\n');
    fprintf(fid, '# ------------------------------------------------------------\n');
    fprintf(fid, '# Original data file:\n');
    fprintf(fid, '# %s\n',spc.data{idx}.fname);
    fprintf(fid, '# Fit function:\n');
    fprintf(fid, '# %s\n',spc.fit.fitfun);
    fprintf(fid, '# Coefficients:\n');
    tmp = fieldnames(spc.fit.fits{idx}.coef);
    for i=1:size(tmp,1)
        if numel(tmp{i}) < 5
            fprintf(fid, '#  %s\t\t',tmp{i});
        else
            fprintf(fid, '#  %s\t',tmp{i});
        end
        fprintf(fid, '%f\t+/-\t%f\n',[spc.fit.fits{idx}.results(i,1);spc.fit.fits{idx}.results(i,2)]);
    end
    fprintf(fid, '# Data:\n');
    fprintf(fid, '# X\t \tY\t \tFit\n');

    fprintf(fid, '%e\t%e\t%e\n', [H; Y; F]);
    fclose(fid);








% % --------------------------------------------------------------------
% function mnuNRAres_Callback(hObject, eventdata, handles)
% 


% --------------------------------------------------------------------
function mnuFitRes_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    if ~isfield(spc,'fit')
        errordlg('Fit results not available!');
        return
    end

    [FileName,PathName] = uiputfile({'*.txt';'*.dat'});
    if ~isequal(FileName, 0)
        cd(PathName);
        r = spc.fit.results;
        txt = num2clipL(r, spc.names);
        fid = fopen([PathName FileName], 'wt');
            fprintf(fid, txt);
        fclose(fid);
        msgbox(['Fit results with area were saved to ' [PathName FileName]],'Saved');
    end


% --------------------------------------------------------------------
function mnuNew_Callback(hObject, eventdata, handles)

    if evalin('base','exist(''spc'',''var'');') == 1
        answ = questdlg('All data in base workspace will be deleted! Do you really want to proceed?','New Experiment');
        if ~strcmp(answ,'Yes')
            return
        end
    end

    evalin('base','clear spc');
    createDefEprStruct();
    mnuSampleD_Callback(hObject, eventdata, handles);
    butReload_Callback(hObject, eventdata, handles);
    axes(handles.axes1);  cla;
    axis auto




% --- Executes on button press in butTODO.
function butTODO_Callback(hObject, eventdata, handles)

% % --------------------------------------------------------------------
% function cmnEdit_Callback(hObject, eventdata, handles)
% 


% --------------------------------------------------------------------
function cmnDelete_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    spc = evalin('base','spc');

    if spc.N < 1
        return; % Not selected
    end

    if strcmp(questdlg(['Do you really want to delete this spectrum?'],'Delete'), 'Yes') ~= 1;
        return
    end

    spc = SPC_delete(spc,idx);
    assignin('base','spc',spc);

    if spc.N < 1
        set(handles.lbFiles, 'Value',0);
    else
        if idx > spc.N 
            set(handles.lbFiles, 'Value',spc.N);
        else
            set(handles.lbFiles, 'Value',idx);
        end
    end

    butReload_Callback(hObject, eventdata, handles);
    
    if spc.N > 0, spcplot(handles); end;




% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)

    OpenMenuItem_Callback(hObject, eventdata, handles)


% --- Executes on button press in butSubBaseLine.
function butSubBaseLine_Callback(hObject, eventdata, handles)


% --- Executes on button press in butLorentz.
function butLorentz_Callback(hObject, eventdata, handles)



% --- Executes on button press in butSubData.
function butSubData_Callback(hObject, eventdata, handles)


% % --------------------------------------------------------------------
% function mnuExpTestLor_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function cmnCpyData_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    spc = evalin('base','spc');

    ma = [];

    for i=idx
        H = reshape(spc.data{i}.H,[],1);
        Y = reshape(spc.data{i}.Y,[],1);
%         H = [0 H];
%         Y = [spc.temp(i); Y];
        ma = [ma H Y];

    end
    num2clipL(ma)



% --------------------------------------------------------------------
function mnuNormAll_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    max_idx = numel(get(handles.lbFiles, 'String'));
    idx = get(handles.lbFiles, 'Value');
    
    prompt = {['Select spectra:        current = ' num2str(idx)]};
    dlg_title = 'Normalize';
    num_lines = 1;
    def = {['1:' num2str(max_idx)]};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if ~isempty(answer) % If CANCEL, answer is empty
        ind = str2num(answer{1});
    else 
        return
    end
    
    for idx=ind
        if ~isfield(spc.data{idx},'Y0')
            spc.data{idx}.Y0 = spc.data{idx}.Y;
            spc.data{idx}.H0 = spc.data{idx}.H;
        end
        spc.data{idx}.Y = normalize(spc.data{idx}.Y);
    end
    assignin('base','spc',spc);

    butReload_Callback(hObject, eventdata, handles);
    set(handles.lbFiles, 'Value',idx);
    spcplot(handles);
    spc_update(hObject, eventdata, handles);
    msgbox('Data have been normalized between [0 1]. To undo use Return Original Data.','Normalize')

    function Y = normalize(Y)
    ymax = max(Y);
    ymin = min(Y);

    Y = (Y-ymin)/(ymax-ymin);



% % --------------------------------------------------------------------
% function mnuReNormAll_Callback(hObject, eventdata, handles)
% 
%     spc = evalin('base','spc');
% 
%     max_idx = numel(get(handles.lbFiles, 'String'));
% 
%     if ~isfield(spc.data{1},'Y0')
%         msgbox('Renormalization not available!','Renormalize')
%         return
%     end
% 
%     for idx=1:max_idx
%         spc.data{idx}.Y = spc.data{idx}.Y0;
%     end
%     assignin('base','spc',spc);
% 
%     butReload_Callback(hObject, eventdata, handles);
%     set(handles.lbFiles, 'Value',idx);
%     spcplot(handles);
%     spc_update(hObject, eventdata, handles);
%     msgbox('Data hase been renormalized.','Renormalize')
% 







function edtFitRange_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtFitRange_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtNRArange_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtNRArange_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --------------------------------------------------------------------
% function CpyPointers_Callback(hObject, eventdata, handles)
% 


% --------------------------------------------------------------------
function RangeEdt_Callback(hObject, eventdata, handles)


% % --------------------------------------------------------------------
% function AppNRArangePoint_Callback(hObject, eventdata, handles)




% % --------------------------------------------------------------------
% function NRArangeEdt_Callback(hObject, eventdata, handles)
% 
% % function edtPhase_Callback(hObject, eventdata, handles)





% --- Executes during object creation, after setting all properties.
function edtPhase_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on button press in butPhUp.
% function butPhUp_Callback(hObject, eventdata, handles)
% 



% % --- Executes on button press in butPhDown.
% function butPhDown_Callback(hObject, eventdata, handles)
% 




% --- Executes on key press with focus on butPhUp and none of its controls.
function butPhUp_KeyPressFcn(hObject, eventdata, handles)

% --- Executes on key press with focus on edtPhase and none of its controls.
function edtPhase_KeyPressFcn(hObject, eventdata, handles)


% % --- Executes on button press in butAbs.
% function butAbs_Callback(hObject, eventdata, handles)
% 



% --------------------------------------------------------------------
function Save_Callback(hObject, eventdata, handles)

    toolSave_ClickedCallback(hObject, eventdata, handles)


% % --------------------------------------------------------------------
% function getTemp_Callback(hObject, eventdata, handles)
% 





function edtAngleStep_Callback(hObject, eventdata, handles)
% hObject    handle to edtAngleStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtAngleStep as text
%        str2double(get(hObject,'String')) returns contents of edtAngleStep as a double


% --- Executes during object creation, after setting all properties.
function edtAngleStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtAngleStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGxx_Callback(hObject, eventdata, handles)
% hObject    handle to edtGxx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGxx as text
%        str2double(get(hObject,'String')) returns contents of edtGxx as a double


% --- Executes during object creation, after setting all properties.
function edtGxx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGxx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGyy_Callback(hObject, eventdata, handles)
% hObject    handle to edtGyy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGyy as text
%        str2double(get(hObject,'String')) returns contents of edtGyy as a double


% --- Executes during object creation, after setting all properties.
function edtGyy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGyy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtGzz_Callback(hObject, eventdata, handles)
% hObject    handle to edtGzz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtGzz as text
%        str2double(get(hObject,'String')) returns contents of edtGzz as a double


% --- Executes during object creation, after setting all properties.
function edtGzz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtGzz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtHxx_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtHxx_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtHyy_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtHyy_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edtHzz_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtHzz_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on button press in butSimulate.
% function butSimulate_Callback(hObject, eventdata, handles)
% 


% --- Executes on button press in rbutgIso.
function rbutgIso_Callback(hObject, eventdata, handles)


% --- Executes on button press in rbutgCil.
function rbutgCil_Callback(hObject, eventdata, handles)


% --- Executes on button press in rbutgAniso.
function rbutgAniso_Callback(hObject, eventdata, handles)


% --- Executes on button press in chkPlotSim.
function chkPlotSim_Callback(hObject, eventdata, handles)

% --- Executes on button press in chkPlotX.
function chkPlotX_Callback(hObject, eventdata, handles)


% --- Executes on key press with focus on butDelete and none of its controls.
function butDelete_KeyPressFcn(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuAnalyse_Callback(hObject, eventdata, handles)

    

% --------------------------------------------------------------------
function mnuSub_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuSubBL_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    s = 0;
    y0 = 0;

    coefs = get(handles.uitFit,'Data');
    if ~isempty(coefs)
        coefstr = coefs(:,1);
        coefval = coefs(:,2);

        for i=1:numel(coefstr)
            if strcmp(coefstr{i},'offset')
                y0 = coefval{i};
            end
        end
        for i=1:numel(coefstr)
            if strcmp(coefstr{i},'slope')
                s = coefval{i};
            end
        end

    end

    prompt = {'slope =','offset ='};
    dlg_title = 'Substract y = slope*x + offset';
    num_lines = 1;

    def = {num2str(s),num2str(y0)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if numel(answer)==0
        return;
    end

    s = str2double(answer{1});
    y0 = str2double(answer{2});

    idx = get(handles.lbFiles, 'Value');

    H = spc.data{idx}.H; % in mT
    Y = spc.data{idx}.Y;
    H = reshape(H,[],1);
    
    if ~isfield(spc.data{idx},'Y0')
        spc.data{idx}.Y0 = spc.data{idx}.Y;
        spc.data{idx}.H0 = spc.data{idx}.H;
    end

    spc.data{idx}.Y = Y  - s*H - y0;

    assignin('base','spc',spc);
    spcplot(handles);

% --------------------------------------------------------------------
function mnuSubData_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    idx = get(handles.lbFiles, 'Value');

    prompt = {'spc_idx =','ref_idx =','factor ='};
    dlg_title = 'Substract reference data';
    num_lines = 1;
    index = idx;
    def = {num2str(idx),'1', '1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if numel(answer)==0
        return;
    end

    spc_idx = str2num(answer{1});
    ref_idx = str2double(answer{2});
    factor = str2double(answer{3});

    for idx = spc_idx
        H = spc.data{idx}.H;
        Y = spc.data{idx}.Y;

        if ~isfield(spc.data{idx},'Y0')
            spc.data{idx}.Y0 = Y;
            spc.data{idx}.H0 = H;
        end

        [refH XI] = sort(spc.data{ref_idx}.H);
        refY = spc.data{ref_idx}.Y(XI);
        [H XI] = sort(H);
        Y = Y(XI);
        
        [b,i,j]=unique(refH); % Remove duplicates from x        

        spc.data{idx}.Y=Y - factor*interp1(b,refY(i),H,'nearest','extrap');
        disp(idx)
    end

    assignin('base','spc',spc);
    spcplot(handles);




% --------------------------------------------------------------------
function mnuSubFit_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    idx = get(handles.lbFiles, 'Value');

    prompt = {'idx =','factor ='};

    dlg_title = 'Substract fit';
    num_lines = 1;
    index = idx;
    def = {num2str(index), '1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if numel(answer)==0
        return;
    end

    index = str2double(answer{1});
    factor = str2double(answer{2});

    if numel(spc.fit.fits) < index || isempty(spc.fit.fits{index}) 
        msgbox('Fit not available!','Error');
        return
    end

    H = spc.data{idx}.H;
    Y = spc.data{idx}.Y;

    if ~isfield(spc.data{idx},'Y0')
        spc.data{idx}.Y0 = Y;
        spc.data{idx}.H0 = H;
    end

    fitY = spc.fit.fits{index}.f(H);
    spc.data{idx}.Y = Y - factor*fitY;

    assignin('base','spc',spc);
    spcplot(handles);


% % --------------------------------------------------------------------
% function mnuSubSim_Callback(hObject, eventdata, handles)
% 




% --------------------------------------------------------------------
function pshAxisAuto_ClickedCallback(hObject, eventdata, handles)
    axis auto


% 
% % --------------------------------------------------------------------
% function mnuTestLor_Callback(hObject, eventdata, handles)
% 
%     


% % --------------------------------------------------------------------
% function mnuShowInfo_Callback(hObject, eventdata, handles)
% 

% % --- Executes on button press in butFitSim.
% function butFitSim_Callback(hObject, eventdata, handles)






% --- Executes on key press with focus on edtGxx and none of its controls.
function edtGxx_KeyPressFcn(hObject, eventdata, handles)


function edtSimPhase_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtSimPhase_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkFitG.
function chkFitG_Callback(hObject, eventdata, handles)

% --- Executes on button press in chkFitH.
function chkFitH_Callback(hObject, eventdata, handles)


% --- Executes on button press in chkFitPh.
function chkFitPh_Callback(hObject, eventdata, handles)


function edtSimIter_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtSimIter_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in butReduceN.
function butReduceN_Callback(hObject, eventdata, handles)


function edtSimFunTol_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtSimFunTol_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtSimXTol_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtSimXTol_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on button press in butRunFitSim.
% function butRunFitSim_Callback(hObject, eventdata, handles)

function edtSimLin_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtSimLin_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtSimConst_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtSimConst_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkFitLin.
function chkFitLin_Callback(hObject, eventdata, handles)


% --- Executes on button press in chkFitConst.
function chkFitConst_Callback(hObject, eventdata, handles)



function edtSimAmp_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtSimAmp_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% % --- Executes on button press in butSimCopy.
% function butSimCopy_Callback(hObject, eventdata, handles)


function edtSimRange_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtSimRange_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% % --------------------------------------------------------------------
% function mnuMultiAll_Callback(hObject, eventdata, handles)
%     
%     spc = evalin('base','spc');
%     max_idx = numel(get(handles.lbFiles, 'String'));
% 
%     prompt = {'Enter numeric factor:'};
%     dlg_title = 'Multiply All';
%     num_lines = 1;
%     def = {'100'};
%     factor = str2double(inputdlg(prompt,dlg_title,num_lines,def));
% 
%     for idx=1:max_idx
%         spc.data{idx}.Y = factor*spc.data{idx}.Y;
%         if isfield(spc.data{idx},'X')
%             spc.data{idx}.X = factor*spc.data{idx}.X;
%         end
%     end
%     assignin('base','spc',spc);
% 
%     butReload_Callback(hObject, eventdata, handles);
%     set(handles.lbFiles, 'Value',idx);
%     spcplot(handles);
%     spc_update(hObject, eventdata, handles);
%     msgbox('Done','Multiply All')
% 


function edtSimQuad_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtSimQuad_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkFitQuad.
function chkFitQuad_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuMulti_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    idx = get(handles.lbFiles, 'Value');
    max_idx = numel(get(handles.lbFiles, 'String'));
    
    prompt = {['Select spectra:        current = ' num2str(idx)],'Enter numeric factor:'};
    dlg_title = 'Multiply';
    num_lines = 1;
    def = {['1:' num2str(max_idx)],'100'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if ~isempty(answer) % If CANCEL, answer is empty
        ind = str2num(answer{1});
        factor = str2double(answer{2});
    else 
        return
    end

    for idx = ind
        if ~isfield(spc.data{idx},'Y0')
            spc.data{idx}.Y0 = spc.data{idx}.Y;
            spc.data{idx}.H0 = spc.data{idx}.H;
        end
        spc.data{idx}.Y = factor*spc.data{idx}.Y;
    end
    
    assignin('base','spc',spc);
    butReload_Callback(hObject, eventdata, handles);
    set(handles.lbFiles, 'Value',idx);
    spcplot(handles);
    spc_update(hObject, eventdata, handles);
    msgbox('Done','Multiply')



% % --------------------------------------------------------------------
% function mnuCpySimRes_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuEdit_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function mnuBin_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    idx = get(handles.lbFiles, 'Value');
    max_idx = numel(get(handles.lbFiles, 'String'));
    
    prompt = {['Select spectra:        current = ' num2str(idx)],'Binning:'};
    dlg_title = 'Bin data';
    num_lines = 1;
    def = {['1:' num2str(max_idx)],'2'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if ~isempty(answer) % If CANCEL, answer is empty
        ind = str2num(answer{1});
        n = floor(str2double(answer{2}));
    else 
        return
    end
    
    for idx = ind

        if ~isfield(spc.data{idx},'Y0')
            spc.data{idx}.Y0 = spc.data{idx}.Y;
            spc.data{idx}.H0 = spc.data{idx}.H;
        end

        len = numel(spc.data{idx}.Y);
        j=1;
        for i=1:n:len-n+1
            Y(j) = mean(spc.data{idx}.Y(i:i+n-1));
            H(j) = spc.data{idx}.H(i);
            j=j+1;
        end

        spc.data{idx}.Y = reshape(Y,1,[]);
        spc.data{idx}.H = reshape(H,1,[]);
        spc.data{idx}.exp.nPoints = numel(H);
    end

    assignin('base','spc',spc);

    butReload_Callback(hObject, eventdata, handles);
    spcplot(handles);

    msgbox(['Number of points is ' num2str(spc.data{idx}.exp.nPoints)],'Binning')



% % --------------------------------------------------------------------
% function mnuBinAll_Callback(hObject, eventdata, handles)
%     spc = evalin('base','spc');
%     n = floor(str2double(inputdlg('Binning:','Bin data', 1, {'2'})));
%     max_idx = numel(get(handles.lbFiles, 'String'));
% 
%     for idx=1:max_idx
%         if ~isfield(spc.data{idx},'Y0')
%             spc.data{idx}.Y0 = spc.data{idx}.Y;
%             spc.data{idx}.H0 = spc.data{idx}.H;
%             spc.data{idx}.X0 = spc.data{idx}.X;
%         end
% 
%         len = numel(spc.data{idx}.Y);
%         j=1;
%         for i=1:n:len-n+1
%             Y(j) = mean(spc.data{idx}.Y(i:i+n-1));
%             X(j) = mean(spc.data{idx}.X(i:i+n-1));
%             H(j) = spc.data{idx}.H(i);
%             j=j+1;
%         end
% 
%         spc.data{idx}.Y = reshape(Y,1,[]);
%         spc.data{idx}.X = reshape(X,1,[]);
%         spc.data{idx}.H = reshape(H,1,[]);
% 
%         spc.data{idx}.exp.nPoints = numel(H);
% 
%         assignin('base','spc',spc);
% 
%         butReload_Callback(hObject, eventdata, handles);
%         spcplot(handles);
%     end
% 
%     msgbox(['Number of points is ' num2str(spc.data{idx}.exp.nPoints)],'Binning')
% 



function edtSimNOP_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtSimNOP_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% 
% % --- Executes on button press in butOther.
% function butOther_Callback(hObject, eventdata, handles)
% 




function edit28_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butAbs.
function pushbutton47_Callback(hObject, eventdata, handles)


% --- Executes on button press in butPhDown.
function pushbutton48_Callback(hObject, eventdata, handles)


% --- Executes on button press in butPhUp.
function pushbutton49_Callback(hObject, eventdata, handles)
% 
% 
% function edtHilbert_Callback(hObject, eventdata, handles)
% 



% --- Executes during object creation, after setting all properties.
function edtHilbert_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% % --- Executes on button press in butHilDown.
% function butHilDown_Callback(hObject, eventdata, handles)
% 



% % --- Executes on button press in butHilUp.
% function butHilUp_Callback(hObject, eventdata, handles)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edtPhase.
function edtPhase_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes on key press with focus on edtPhase and none of its controls.
function edit28_KeyPressFcn(hObject, eventdata, handles)


% % --- Executes on button press in butHilRecalc.
% function butHilRecalc_Callback(hObject, eventdata, handles)



function edtLorW_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtLorW_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtLorHc_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtLorHc_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtLorB_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtLorB_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkFitLor.
function chkFitLor_Callback(hObject, eventdata, handles)


% --- Executes on selection change in popSimFun.
function popSimFun_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popSimFun_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edtLorPhi_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtLorPhi_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over butPlotFunc.
function butPlotFunc_ButtonDownFcn(hObject, eventdata, handles)



% --------------------------------------------------------------------
function New_ClickedCallback(hObject, eventdata, handles)



% % --- Executes on button press in btnGaussmT.
% function btnGaussmT_Callback(hObject, eventdata, handles)
% 


% --- Executes on button press in pushbutton57.
function pushbutton57_Callback(hObject, eventdata, handles)



% % --------------------------------------------------------------------
% function cmnCopySim_Callback(hObject, eventdata, handles)
% 




% --------------------------------------------------------------------
function cmnCopyFit_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    spc = evalin('base','spc');

%     plotFit = get(handles.chkPlotFit, 'Value');
%     plotFite = get(handles.chkPlotFit, 'Enable');
%     if strcmp(plotFite,'on') && plotFit == 1 
%         plotFit = 1;
%     else
%         plotFit = 0;
%     end

    ma = [];

    for i=idx
        if numel(spc.fit.fits) >= i && ~isempty(spc.fit.fits{i}) % plotFit == 1 && 
            fitH = spc.data{i}.H;
            fitY = spc.fit.fits{i}.f(spc.data{i}.H);
            ma = [ma fitH fitY];
        else
            msgbox('Nothing to Copy!','Error');
        end
    end
    num2clipL(ma)


% --------------------------------------------------------------------
function mnuRetData_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    max_idx = numel(get(handles.lbFiles, 'String'));
    idx = get(handles.lbFiles, 'Value');
    
    prompt = {['Select spectra:        current = ' num2str(idx)]};
    dlg_title = 'Normalize';
    num_lines = 1;
    def = {['1:' num2str(max_idx)]};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if ~isempty(answer) % If CANCEL, answer is empty
        ind = str2num(answer{1});
    else 
        return
    end
    
    problems = 0;
    
    for idx=ind

        if ~isfield(spc.data{idx},'Y0')
            disp(['Nothing to return for spectrum ' num2str(idx)]);
            problems = problems + 1;
            continue
        end

        spc.data{idx}.H = spc.data{idx}.H0;
        spc.data{idx}.Y = spc.data{idx}.Y0;
        spc.data{idx}.exp.nPoints = numel(spc.data{idx}.H);
    end

    assignin('base','spc',spc);
    spcplot(handles);
    
    if numel(ind) > 1
        txt = 'Spectra have';
    else
        txt = ['Spectrum ' num2str(idx) ' has'];
    end
    
    if problems > 0
        msgbox(['Spectra restored, however, there were ' num2str(problems) ' problems!'], 'Return Original Data');
    else
        msgbox([txt ' been restored!'], 'Return Original Data');
    end
    



% --------------------------------------------------------------------
function mnuShift_Callback(hObject, eventdata, handles)
    spc = evalin('base','spc');
    idx = get(handles.lbFiles, 'Value');
    max_idx = numel(get(handles.lbFiles, 'String'));
    
    prompt = {['Select spectra:        current = ' num2str(idx)],'Shift data to the right:'};
    dlg_title = 'Shift';
    num_lines = 1;
    def = {['1:' num2str(max_idx)],'0'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if ~isempty(answer) % If CANCEL, answer is empty
        ind = str2num(answer{1});
        shift = str2double(answer{2});
    else 
        return
    end
    
    for idx = ind
        if ~isfield(spc.data{idx},'Y0')
            spc.data{idx}.Y0 = spc.data{idx}.Y;
            spc.data{idx}.H0 = spc.data{idx}.H;
        end
        spc.data{idx}.H = spc.data{idx}.H + shift*ones(size(spc.data{idx}.H));
    end
    assignin('base','spc',spc);
    spcplot(handles);
    msgbox('Specta have been shifted!','Shift Data');


% --- Executes during object creation, after setting all properties.
function uitFit_CreateFcn(hObject, eventdata, handles)


function edtFN_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edtFN_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butESBrowse.
function butESBrowse_Callback(hObject, eventdata, handles)


% % --- Executes on button press in butESexe.
% function butESexe_Callback(hObject, eventdata, handles)
%     


% --- Executes on button press in butESRun.
function butESRun_Callback(hObject, eventdata, handles)


function edtRep_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtRep_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkFitHc.
function chkFitHc_Callback(hObject, eventdata, handles)



% function edtCalibrate_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtCalibrate_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on button press in butCalibrate.
% function butCalibrate_Callback(hObject, eventdata, handles)




% --------------------------------------------------------------------
function mnuAllData_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    names = get(handles.lbFiles, 'String');
    FileName = ['dat' names{1} '.dat'];
    [FileName,PathName] = uiputfile('*.dat','Save to directory',FileName);
    if ~isequal(FileName, 0)
        ret = questdlg('All files will be saved with an appendix ''dat_...''.','Confirm');
        if ~strcmp(ret,'Yes')
            return
        end
        cd(PathName);

        for i=1:numel(names)
            FileName = ['dat_' names{i} '.dat'];
            export_data([PathName FileName],spc,i);
        end
    end
    msgbox(['All data was saved to ' PathName],'Saved');



function export_data(Filename, spc, idx)
    H = spc.data{idx}.H;
    Y = spc.data{idx}.Y;
    H = reshape(H,[],1);
    Y = reshape(Y,[],1);

    fid = fopen(Filename, 'wt');
        fprintf(fid, '# X\t \tY\t\n');
        fprintf(fid, '%f\t%f\n', [H'; Y';]);
    fclose(fid);



% --------------------------------------------------------------------
function mnuSData_Callback(hObject, eventdata, handles)

    [FileName,PathName] = uiputfile('*.dat');
    if ~isequal(FileName, 0)
        cd(PathName);
        spc = evalin('base','spc');
        idx = get(handles.lbFiles, 'Value');
        export_data([PathName FileName],spc,idx);
    end
    msgbox(['Data was saved to ' [PathName FileName]],'Saved');


% % --------------------------------------------------------------------
% function mnuCalcGfact_Callback(hObject, eventdata, handles)



% --------------------------------------------------------------------
function cpyFigure_Callback(hObject, eventdata, handles)
    set(handles.txtSell,'BackgroundColor','white');
    set(handles.txtVersion,'BackgroundColor','white');
    set(handles.chkPlotFit,'BackgroundColor','white');
    set(handles.chkUpdate,'BackgroundColor','white');
    set(handles.panFit,'BackgroundColor','white');
    set(handles.text2,'BackgroundColor','white');
    set(handles.text28,'BackgroundColor','white');
    set(handles.chkShowComp,'BackgroundColor','white');
    set(handles.text91,'BackgroundColor','white');
    set(handles.chkKeepIniPar,'BackgroundColor','white');
    set(handles.chkDNUpdateFix,'BackgroundColor','white');
    set(handles.txtPos,'BackgroundColor','white');
    print -dmeta % -dbitmap
    set(handles.txtSell,'BackgroundColor',get(handles.figure1,'Color'));
    set(handles.txtVersion,'BackgroundColor',get(handles.figure1,'Color'));
    set(handles.chkPlotFit,'BackgroundColor',get(handles.figure1,'Color'));
    set(handles.chkUpdate,'BackgroundColor',get(handles.figure1,'Color'));
    set(handles.panFit,'BackgroundColor',get(handles.figure1,'Color'));
    set(handles.text2,'BackgroundColor',get(handles.figure1,'Color'));
    set(handles.text28,'BackgroundColor',get(handles.figure1,'Color'));
    set(handles.chkShowComp,'BackgroundColor',get(handles.figure1,'Color'));
    set(handles.text91,'BackgroundColor',get(handles.figure1,'Color'));
    set(handles.chkKeepIniPar,'BackgroundColor',get(handles.figure1,'Color'));
    set(handles.chkDNUpdateFix,'BackgroundColor',get(handles.figure1,'Color'));
    set(handles.txtPos,'BackgroundColor',get(handles.figure1,'Color'));
    msgbox('Done!','Copy Figure')


% --- Executes on selection change in lbSimFun.
function lbSimFun_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function lbSimFun_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on button press in butSimAdd.
% function butSimAdd_Callback(hObject, eventdata, handles)



% % --- Executes on button press in butSimRemove.
% function butSimRemove_Callback(hObject, eventdata, handles)



% --- Executes during object creation, after setting all properties.
function butRunFitFun_CreateFcn(hObject, eventdata, handles)
    
    
function mnuSimulate_Callback(hObject, eventdata, handles)
    



% % --- Executes on button press in butES.
% function butES_Callback(hObject, eventdata, handles)
% 


% --- Executes on button press in pushbutton78.
function pushbutton78_Callback(hObject, eventdata, handles)




function edit46_Callback(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit46 as text
%        str2double(get(hObject,'String')) returns contents of edit46 as a double


% --- Executes during object creation, after setting all properties.
function edit46_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton79.
function pushbutton79_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton79 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton80.
function pushbutton80_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton80 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton81.
function pushbutton81_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton81 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit47_Callback(hObject, eventdata, handles)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit47 as text
%        str2double(get(hObject,'String')) returns contents of edit47 as a double


% --- Executes during object creation, after setting all properties.
function edit47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton82.
function pushbutton82_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton83.
function pushbutton83_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton84.
function pushbutton84_Callback(hObject, eventdata, handles)


function edit48_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit48_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton85.
function pushbutton85_Callback(hObject, eventdata, handles)

% --- Executes on button press in pushbutton86.
function pushbutton86_Callback(hObject, eventdata, handles)


% --- Executes on button press in butESrun.
% function butESrun_Callback(hObject, eventdata, handles)



% function edtES_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtES_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in butESexe.
function pushbutton88_Callback(hObject, eventdata, handles)



% --- Executes on button press in pushbutton89.
function pushbutton89_Callback(hObject, eventdata, handles)


% % --- Executes on button press in butSimUndo.
% function butSimUndo_Callback(hObject, eventdata, handles)



% % --- Executes on button press in butSimReUndo.
% function butSimReUndo_Callback(hObject, eventdata, handles)


    
    


function backupFit(handles)
    
    if evalin('base','exist(''fitHist'',''var'')')
        fitHist = evalin('base','fitHist');
    else
        fitHist.params = {};
        fitHist.current = 0;
    end
    

    newPar = get(handles.uitFit, 'Data');
    if fitHist.current > 0
        if isequalcell(fitHist.params{end},newPar);
           return; 
        end
    end
    
    fitHist.params{end+1} = newPar;
    fitHist.current = numel(fitHist.params);
    assignin('base','fitHist',fitHist);


function r = isequalcell(C1,C2)
    r = 0;
    if ~isequal(size(C1),size(C2)), return; end;
    for i=1:numel(C1)
    	if ~isequal(C1{i},C2{i}), return; end;
    end
    r = 1;



% --- Executes on button press in chkShowComp.
function chkShowComp_Callback(hObject, eventdata, handles)
% hObject    handle to chkShowComp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkShowComp


% --- Executes on button press in butFitUndo.
function butFitUndo_Callback(hObject, eventdata, handles)
if evalin('base','exist(''fitHist'',''var'')')
        fitHist = evalin('base','fitHist');
        ind = fitHist.current;
        if ind > 1
            ind = ind - 1;
            set(handles.uitFit, 'Data',fitHist.params{ind});
            fitHist.current = ind;
            assignin('base','fitHist',fitHist);
        else
            disp('No more data!');
        end
    else
        disp('No data!');
    end


% --- Executes on button press in butFitReundo.
function butFitReundo_Callback(hObject, eventdata, handles)
    if evalin('base','exist(''fitHist'',''var'')')
        fitHist = evalin('base','fitHist');
        ind = fitHist.current;
        if ind < numel(fitHist.params)
            ind = ind + 1;
            set(handles.uitFit, 'Data',fitHist.params{ind});
            fitHist.current = ind;
            assignin('base','fitHist',fitHist);
        else
            disp('No more data!');
        end
    else
        disp('No data!');
    end


% --------------------------------------------------------------------
function mnuData_Callback(hObject, eventdata, handles)



function edtDesc_Callback(hObject, eventdata, handles)
 idx = get(handles.lbFiles, 'Value');
 spc = evalin('base','spc');
 spc.desc{idx} = get(hObject,'String');
 assignin('base','spc',spc);


% --- Executes during object creation, after setting all properties.
function edtDesc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
    


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
    pos = get(hObject,'CurrentPoint');
%     disp(pos)
    H = pos(1,1);
    Y = pos(1,2);
    str = ['(' num2str(H,'%10.3f') ', ' num2str(Y,'%10.5e') ')'];
    
    ob = findobj('Tag','txtPos');
    set(ob,'String',str);
    
    ob = findobj(hObject,'Tag','vline');
    v = axis(hObject);
    switch get(gcf,'selectiontype')
    case 'normal'%left mouse button click
        disp([str ';  X copied to clipboard']);
        num2clipL(round(H*1e3)/1e3);
        if isempty(ob)
            line('XData',[H H],'YData',v(3:4),'Parent',hObject,'Tag','vline','Color',[0.7 0.7 0.7],'HitTest','off')
        end
        set(ob,'XData',[H H],'YData',v(3:4));
    case 'alt'%right mouse button click
        disp([str ';  Y copied to clipboard']);
        num2clipL(Y);
        if isempty(ob)
            line('XData',v(1:2),'YData',[Y Y],'Parent',hObject,'Tag','vline','Color',[0.7 0.7 0.7],'HitTest','off')
        end
        set(ob,'XData',v(1:2),'YData',[Y Y]);
    end






% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over butPointer1.
function butPointer1_ButtonDownFcn(hObject, eventdata, handles)



% --- Executes on button press in chkKeepIniPar.
function chkKeepIniPar_Callback(hObject, eventdata, handles)


% --- Executes on button press in chkDNUpdateFix.
function chkDNUpdateFix_Callback(hObject, eventdata, handles)


% --- Executes on key press with focus on edtDesc and none of its controls.
function edtDesc_KeyPressFcn(hObject, eventdata, handles)


function edtFitRepeat_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edtFitRepeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtFitRepeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on butFitFunc and none of its controls.
function butFitFunc_KeyPressFcn(hObject, eventdata, handles)



% --------------------------------------------------------------------
function cmnEdit_Callback(hObject, eventdata, handles)
    idx = get(handles.lbFiles, 'Value');
    names = get(handles.lbFiles, 'String');
    spc = evalin('base','spc');

    prompt = {'Name:'};
    dlg_title = names{idx};
    num_lines = 1;
    name = spc.names{idx};


    def = {name};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    if numel(answer)==0
        return;
    end

    spc.names{idx} = answer{1};

    assignin('base','spc',spc);

    butReload_Callback(hObject, eventdata, handles);
    spcplot(handles);
    spc_update(hObject, eventdata, handles);



% --------------------------------------------------------------------
function mnuChi2Hist_Callback(hObject, eventdata, handles)

    chi2offset


% --------------------------------------------------------------------
function mnuRepeat_Callback(hObject, eventdata, handles)
% hObject    handle to mnuRepeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuIni_Callback(hObject, eventdata, handles)

    set(handles.chkUpdate,'Value',0);
    set(handles.chkKeepIniPar,'Value',0);
    set(handles.chkDNUpdateFix,'Value',0);
    
% --------------------------------------------------------------------
function mnuChain_Callback(hObject, eventdata, handles)
    
    set(handles.chkUpdate,'Value',0);
    set(handles.chkKeepIniPar,'Value',1);
    set(handles.chkDNUpdateFix,'Value',1);


% --------------------------------------------------------------------
function mnuReFit_Callback(hObject, eventdata, handles)
    
    set(handles.chkUpdate,'Value',1);
    set(handles.chkKeepIniPar,'Value',0);
    set(handles.chkDNUpdateFix,'Value',1);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edtDesc.
function edtDesc_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edtDesc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1

function working(on_off,handles)
    
    switch on_off
        case 1
            set(handles.txtBusy,'Visible','on');
            
        otherwise
            set(handles.txtBusy,'Visible','off');
    end
    drawnow
    


% --------------------------------------------------------------------
function mnuParameters_Callback(hObject, eventdata, handles)
% hObject    handle to mnuParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mnuParImport_Callback(hObject, eventdata, handles)
    
    [FileName,PathName] = uigetfile({'*.txt';'*.dat'});
    if ~isequal(FileName, 0)
        cd(PathName);
        
        fid = fopen([PathName FileName], 'r');
        
        line = textscan(fid, '%s %s\n',1);
        if ~strcmp([line{1}{1} ' ' line{2}{1}],'LeyLa parameters')
            msgbox('Wrong parameter file!','error');
            return
        end
        
        line = textscan(fid, '%d\n',1);
        N = line{1};
        functions = {};
        for i=1:N
            line = textscan(fid, '%s\n',1);
            functions{i} = line{1}{1};
        end
        
        line = textscan(fid, '%d\n',1);
        N = line{1};
        uicoefs = {};
        for i=1:N
            line = textscan(fid, '%s\t%f\t%f\t%f\t%d\n',1);
            line{1} = line{1}{1};
            line{5} = isequal(line{5},1);
            uicoefs(i,:) = line;
        end

        fclose(fid);
        
        set(handles.lbFunctions,'string',functions);
        set(handles.uitFit,'Data',uicoefs);
        
        msgbox(['Parameters have been read from ' [PathName FileName]],'Import');
    end

    

% --------------------------------------------------------------------
function mnuParExport_Callback(hObject, eventdata, handles)

    [FileName,PathName] = uiputfile({'*.txt';'*.dat'});
    if ~isequal(FileName, 0)
        cd(PathName);
        
        fid = fopen([PathName FileName], 'w');
        
        fprintf(fid,'LeyLa parameters\n'); % Header
        
        functions = get(handles.lbFunctions,'String');
        fprintf(fid,'%d\n',numel(functions));
        for i=1:numel(functions)
            fprintf(fid,'%s\n',functions{i});
        end
        
        uicoefs = get(handles.uitFit,'Data');
        [nrows,ncols]= size(uicoefs);
        fprintf(fid,'%d\n',nrows);
        for row=1:nrows
            fprintf(fid, '%s\t%f\t%f\t%f\t%d\n', uicoefs{row,:});
        end

        fclose(fid);
        
        msgbox(['Parameters have been saved to ' [PathName FileName]],'Export');
    end
    

    
% --------------------------------------------------------------------
function mnuCpyFitResults_Callback(hObject, eventdata, handles)

    spc = evalin('base','spc');
    if ~isfield(spc,'fit') || ~isfield(spc.fit,'results')
        errordlg('Fit results not available!');
        return
    end

    res = spc.fit.results;
    num2clipL(res,spc.names)
    msgbox('Fit results have been copied to clipboard','Saved');
    

function cr = convertResults(spc,handles)
    working(1,handles);
    
    res = spc.fit.results;
    [funstr Nfun] = getEquation(handles);
    
    for k=1:size(res,1)
               
        coefs = spc.fit.fits{k}.uicoefs;
        coefstr = coefs(:,1);
        coefval = coefs(:,2);
        
        for i=1:Nfun
            
            funstr = getEquation(handles,i);
            futy = fittype(funstr); % Slow !!!
            cs = coeffnames(futy);

            tmp='';
            for j=1:numel(cs)  % write parameters in cfit function
                ind = cellfun(@(x) isequal(x,cs{j}),coefstr);
                tmp = [tmp ',' num2str(coefval{ind})];  
            end
            cf = eval(['cfit(futy' tmp ');']);
            
            posA = findStrInCell('area',cs);
            posPos = findStrInCell('pos',cs);
            
            posA = findStrInCell(cs{posA},coefstr,1);
            posPos = findStrInCell(cs{posPos},coefstr,1);
            
            height = cf(coefval{posPos});
            dA = res(k,2*posA);
            A = res(k,2*posA-1);
            if dA == 0
                dheight = 0;
            else
                dheight = dA/A*height;
            end
            
            % TODO: calculate errorbar from other parameters!
            res(k,2*posA) = dheight;
            res(k,2*posA-1) = height;
        end
        disp([num2str(k) '/' num2str(size(res,1))])
    end

    cr = res;
    working(0,handles);
    
% --------------------------------------------------------------------
function mnuCpyFitResultsH_Callback(hObject, eventdata, handles)
    
    spc = evalin('base','spc');
    if ~isfield(spc,'fit') || ~isfield(spc.fit,'results')
        errordlg('Fit results not available!');
        return
    end
    
    res = convertResults(spc,handles);
    num2clipL(res,spc.names)
    msgbox('Fit results with heights were copied to clipboard','Saved');


% --------------------------------------------------------------------
function mnuSplineBC_Callback(hObject, eventdata, handles)

set(handles.panSplineBC,'Visible','on');
set(handles.panFit,'Visible','off');
    


% --- Executes on button press in butPanSBCclose.
function butPanSBCclose_Callback(hObject, eventdata, handles)
    
set(handles.panSplineBC,'Visible','off');
set(handles.panFit,'Visible','on');


% --- Executes on button press in butAddPoint.
function butAddPoint_Callback(hObject, eventdata, handles)
    
    [X Y but] = ginput(1);

    if but == 1 % left click
    else
        return
    end
    
    disp(['Add point: X = ' num2str(X,'%10.5e') ' Y = ' num2str(Y,'%10.5e')]);
    
    coefs = get(handles.uitSpline, 'Data');
    vrstica = {X,Y};
    coefs = [coefs; vrstica];
    set(handles.uitSpline, 'Data', coefs);
    
    idx = get(handles.lbFiles, 'Value');
    spc = evalin('base','spc');
    spc.data{idx}.splinePoints = coefs;
    assignin('base','spc',spc);

    spcplot(handles);
    


% --- Executes on button press in butRmPoint.
function butRmPoint_Callback(hObject, eventdata, handles)
    
    idx = get(handles.lbFiles, 'Value');
    spc = evalin('base','spc');
    
    if ~isfield(spc.data{idx},'splinePoints')
        return
    end
    
    [X Y but] = ginput(1);

    if but == 1 % left click
    else
        return
    end

    coefs = spc.data{idx}.splinePoints;
    x = cell2mat(coefs(:,1));
    y = cell2mat(coefs(:,2));
    
    X = x - X;
    Y = y - Y;
    
    d = X.*X + Y.*Y;
    [m in] = min(d);
    
    X = x(in);
    Y = y(in);
    
    disp(['Remove point: X = ' num2str(X,'%10.5e') ' Y = ' num2str(Y,'%10.5e')]);
    
    coefs(in,:) = [];
    set(handles.uitSpline, 'Data', coefs);
    spc.data{idx}.splinePoints = coefs;
    assignin('base','spc',spc);

    spcplot(handles);


% % --- Executes on button press in butDrawSpline.
% function butDrawSpline_Callback(hObject, eventdata, handles)


% --- Executes on button press in butSubSpline.
function butSubSpline_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    spc = evalin('base','spc');
    
    % Draw points for spline base correction
    if isfield(spc.data{idx},'splinePoints')
        spoints = spc.data{idx}.splinePoints;
        x = cell2mat(spoints(:,1));
        y = cell2mat(spoints(:,2));

        xx = spc.data{idx}.H;
        yy = spline(x,y,xx);
        
        if ~isfield(spc.data{idx},'Y0')
            spc.data{idx}.Y0 = spc.data{idx}.Y;
            spc.data{idx}.H0 = spc.data{idx}.H;
        end
        
        Y = spc.data{idx}.Y;
        Y = Y - yy;
        spc.data{idx}.Y = Y;
        spc.data{idx} = rmfield(spc.data{idx},'splinePoints');
        assignin('base','spc',spc);
        set(handles.uitSpline, 'Data', []);
        spcplot(handles);
        
    else
        msgbox('No points selected!');
    end


% --- Executes when entered data in editable cell(s) in uitSpline.
function uitSpline_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitSpline (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on key press with focus on uitSpline and none of its controls.
function uitSpline_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to uitSpline (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

    


% --- Executes when selected cell(s) is changed in uitSpline.
function uitSpline_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitSpline (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function uitSpline_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uitSpline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in butSplineRefresh.
function butSplineRefresh_Callback(hObject, eventdata, handles)

    idx = get(handles.lbFiles, 'Value');
    spc = evalin('base','spc');
    coefs = get(handles.uitSpline, 'Data');
    spc.data{idx}.splinePoints = coefs;
    assignin('base','spc',spc);

    spcplot(handles);


% --------------------------------------------------------------------
function mnuFitResHei_Callback(hObject, eventdata, handles)
    
    spc = evalin('base','spc');
    if ~isfield(spc,'fit')
        errordlg('Fit results not available!');
        return
    end

    [FileName,PathName] = uiputfile({'*.txt';'*.dat'});
    if ~isequal(FileName, 0)
        cd(PathName);
        res = convertResults(spc,handles);
        txt = num2clipL(res, spc.names);
        fid = fopen([PathName FileName], 'wt');
            fprintf(fid, txt);
        fclose(fid);
        msgbox(['Fit results with heights were saved to ' [PathName FileName]],'Saved');
    end

