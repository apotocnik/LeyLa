%--------------------------------------------------------------------------
% plot_sfi_results  - plots multiple results from spc structre NEW!!!
%
% Author: Anton Potocnik, F5, IJS
% Date:   27.01.2009 - 25.01.2014
% Arguments:
%       h = plot_sfi_results(spc)
%--------------------------------------------------------------------------

function plot_sfi_results(spc)


if ~isfield(spc,'fit')
    error('There is no spc.fit structure!')
end

if isfield(spc,'material') && isfield(spc,'date')
    if ~isempty(spc.mass) 
        title_str = [spc.material '  ' num2str(spc.mass) 'mg  ' spc.date];
    else
        title_str = [spc.material '  ' spc.date];
    end
end



% find peak components in the fitting function ----------------------------
%  - every peak function has at least three parameters
%  - discarded functions have up to two parameters (powers, offset, slope...)

% find index of peak components with at least three parameters
names = fieldnames(spc.fit.coef);
indeces = cell2mat(cellfun(@(x) str2double(x(~isletter(x))),names,'UniformOutput',false));
indcomp = unique(indeces);
indcomp = [indcomp cellfun(@(x) sum(indeces==x),num2cell(indcomp))];
indcomp(indcomp(:,2)<3,:) = []; % remove components with less then 3 parameters
% indcomp = cell2mat(indcomp);

% find component with maximum number of components and get all parameter
% names
% We assume the same relevant parameter names of different peak components
[M ind] = max(indcomp(:,2));
ind1 = find(indeces==indcomp(ind,1));
parnames = cellfun(@(x) (x(isletter(x))),names,'UniformOutput',false);
parnames = parnames(ind1);
parnames = cell2mat(cellfun(@(x) [x,','],parnames','UniformOutput',false));
parnames(end) = [];

%--------------------------------------------------------------------------
% ask for additional plots

show_error = true;

prompt = {'Show parameters: (separate by ,)','Show components:','Show errorbars?'};
dlg_title = 'Plot results';
num_lines = 1;
def = {parnames,array2mlnum(indcomp(:,1)),'y'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer), return; end; % User changed his mind

% Get parameter names
answer{1}(isspace(answer{1})) = [];
i=1;
parnames = {};
while(~isempty(answer{1}) && ~strcmp(answer{1},',')) 
   [parnames{i} answer{1}] = strtok(answer{1},','); i = i + 1;
end

components = str2num(answer{2});

% get errorbar answer
if isempty(strfind(answer{3},'y'))
    show_error = false;
end

parN = numel(parnames); % Number of parameters or axes to show
compN = numel(components); % Number of peak components to show

%% Create figure
%--------------------------------------------------------------------------
font_size_title = 16;
font_size_labels = 14;
font_size_numbers = 14;
offset_l = 0.14; % offset left
offset_r = 0.06; % offset right
offset_t = 0.06; % offset top 
offset_b = 0.09; % offset bottom
offset_bw = 0.04; % offset between axes
%--------------------------------------------------------------------------
%                               x  y   w   h
figure1 = figure('Position',[560,150,560,670]);
axis off

% Create X vector
X = 1:spc.N;
empties = cellfun(@(x) isempty(x),spc.fit.fits);
X(empties) = [];

posX = offset_l;
posW = 1 - offset_l - offset_r;
posH = (1 - offset_t - offset_b - (parN-1)*offset_bw)/parN;

ah = zeros(parN,1);
for k=1:parN % loop over parameters, axes
    posY = 1 - offset_t - (k-1)*offset_bw - k*posH;
    
    ah(k) = axes('Parent',figure1,'YMinorTick','on','XMinorTick','on',...
    'Position',[posX posY posW posH],...
    'LineWidth',1,...
    'FontSize',font_size_numbers,...
    'FontName','Arial');
    box on
    hold all

    
    for i=1:compN % loop over components
        
        % Get values
        pname = [parnames{k} num2str(indcomp(i,1))];
        ind = find(cellfun(@(x) strcmp(x,pname),names) == 1);
        if isempty(ind)
           continue 
        end
        
        Y = spc.fit.results(:,2*ind-1); % Should take into account errorbars
        dY = spc.fit.results(:,2*ind);
        Y(empties,:) = [];
        dY(empties,:) = [];

        if show_error
            errorbar(X,Y,dY,'Parent',ah(k),'MarkerFaceColor',colors(i),...
            'MarkerEdgeColor',colors(i),'Marker',markers(i),'LineStyle','none');
        else
            plot(X,Y,'Parent',ah(k),'MarkerFaceColor',colors(i),...
            'MarkerEdgeColor',colors(i),'Marker',markers(i),'LineStyle','none');
        end
    end
    
    hold off
    grid on
    ylabel(parnames{k},'FontSize',font_size_labels,'FontName','Arial');
end

% Create xlabel and xtics and link all of them together
xlabel('Spectrum number','FontSize',font_size_labels,'FontName','Arial');
linkaxes(ah,'x');
xlim([X(1)-1 X(end)+1]);

% remove xtick label for all by the last axes
cellfun(@(x) set(x,'xticklabel',[]),num2cell(ah(1:end-1)));

% Add legend
leg = cellfun(@(x) num2str(x), num2cell(components),'UniformOutput',false);
legend(ah(1),leg);

% Add title
title(ah(1),title_str,'FontSize',font_size_title);

