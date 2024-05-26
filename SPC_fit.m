%--------------------------------------------------------------------------
% SPC ANALYSIS Fit data using analitic functions
%
% Version: 2.0
% Author: Anton Potocnik @ IJS-F5
% Date:   27.10.2008 - 29.01.2009
% Input:  spc.fit.fitfun     ... string fit function
%         spc.fit.coef       ... structure with start values
%         spc.fit.options    ... parameters for fitting; start values will be
%                                updated
%         spc.fit.chosen     ... vector of specter numbers to fit
%         spc.fit.plot       ... plot results? (1/0)
%         spc.fit.range      ... specify range where to fit (extrange function)
% Output: spc.fit.fits{}.f           ... fit function
%                       .opts        ... fitting options
%                       .model       ... fitting model
%                       .results     ... 1.col coeff values, 2.col errors
%                       .gof         ... goodness of fit
%         spc.fit.results       ... all parameters with xc
%--------------------------------------------------------------------------

disp(' ');
disp('##########################################');
disp(['Fitting specters']);

clear Mov
%% Copy previous results
if isfield(spc.fit,'results')
    results = spc.fit.results;
end

%% Get coefficient and problems names and values
coef_values = struct2cell(spc.fit.coef);
coef_names  = fieldnames(spc.fit.coef)';
param_names = coef_names;
coef_values = cell2mat(coef_values);

% Find vary and not vary indeces
vary_idx = find(coef_values(:,4)==1); 
not_vary_idx = find(coef_values(:,4)==0);  


% Extract not vary
prob_values = num2cell(coef_values(not_vary_idx,1))';
prob_names = coef_names(not_vary_idx);

% Extract vary
coef_values(not_vary_idx,:) = [];
coef_names(not_vary_idx) = [];

% Set fit model
spc.fit.model = fittype(spc.fit.fitfun,'problem',prob_names,'coefficients',coef_names);

spc.fit.options.StartPoint = coef_values(:,1)';        % Update start value
if strcmp(spc.fit.options.Algorithm,'Trust-Region')==1
    spc.fit.options.Upper = coef_values(:,3)';         % Update upper limits
    spc.fit.options.Lower = coef_values(:,2)';         % Update lower limits
else
    spc.fit.options.Upper = [];         % Delete upper limits
    spc.fit.options.Lower = [];         % Delete lower limits
end

%% FIT
model = spc.fit.model;
opts = spc.fit.options;

for i = spc.fit.chosen

    H = spc.data{i}.H;
    Y = spc.data{i}.Y;
    if isfield(spc.fit,'range')
        [H Y] = extrange(H,Y,spc.fit.range);
    end

    H = reshape(H,[],1);
    Y = reshape(Y,[],1);
    
    [f1 gof] = fit(H, Y, model, opts, 'problem', prob_values);
    coeff = coeffvalues(f1);        % Get fit coefficients
    
    %% Analyse and Save values
    spc.fit.fits{i}.f = f1;
    opts.StartPoint = coeff;
    spc.fit.fits{i}.opts = opts;
    spc.fit.fits{i}.model = model;
    spc.fit.fits{i}.gof = gof;
    
    % Extract errors
    ci = confint(f1,0.95);      % Boundaries within 95%
    err = (ci(2,:)-ci(1,:))/2;  % Absolut error
    
    % First column - coefficients
    res(vary_idx,1) = coeff;
    res(not_vary_idx,1) = cell2mat(prob_values);
    
    % Second column - errors
    res(vary_idx,2) = err;
    res(not_vary_idx,2) = zeros(1,numel(prob_values));

    spc.fit.fits{i}.results = res;
    spc.fit.fits{i}.coef = spc.fit.coef;

    
    %% Plot fit & data
%     if spc.fit.plot==1
%         figure(1);
%         plot(H,Y,H,f1(H),'r');
        %axis([min(H) max(H) -0.01 0.01])
%         legend(num2str(spc.temp(i)));
%         Mov(i) = getframe;
%     end
    
    tmp = sprintf('SSE=%3.6f\t', gof.sse);
    disp(sprintf('%s%s', [tmp num2str(res(:,1)')]));
    
end

%% Analyse Fits

for i = spc.fit.chosen
    vrstica = [reshape(spc.fit.fits{i}.results',1,[])];
    if exist('results','var')
        if size(results,2) ~= size(vrstica,2)   % different in size
            anse = questdlg('Different results already exist. Overwrite all previous results?','Overwrite');
            if strcmp(anse,'Yes')
                results = [];
            else
                return;
            end
        end 
    end
    results(i,:) = vrstica;
end
spc.fit.results = results;

%% Chop results to functions and plot individual function results
clear res


clear i j H Y model opts f1 gof ind tmp coef_names coef_values prob_names prob_values ci err results coeff
clear vary_idx not_vary_idx  res param_names title_str xc dxc results r id r 