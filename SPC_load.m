%--------------------------------------------------------------------------
%% Specter ANALYSIS Load data
% Version 2.1 - Loads almost everything
%
% Author: Anton Potocnik, F5, IJS
% Date:   27.10.2008 - 05.11.2013
% Input:  spc.path 
% Output  spc.data{}.H   (Wavenumber (cm^-1)) !!!
%                   .Y   (Intensity (arb. units))
%            .names{}
%            .desc{}
%            .N         % numel(spc.data)
%--------------------------------------------------------------------------

%% Get file list and its information
files = dir(spc.path);
fpath = fileparts(spc.path);

if isempty(files)
    error('Files not found!')
end

%% Get previous data
ind = 1;   % data counter, different than i if data allready exist
if isfield(spc,'data')      % if data allready exists add new data
    ind = numel(spc.data)+1;
    data = spc.data;
    names = spc.names;
    desc = spc.desc;
end

%% Load files
disp(' ');
disp('##########################################');
disp('Loading data from:');
disp(['  ' fpath]);

for i=1:numel(files)
    if files(i).isdir == true  % Skip Folders
        continue;
    end
    fname = fullfile(fpath,files(i).name);
    
    % Recognize file format
    des = textread(fname,'%s',1,'bufsize',16380); 
    
    if ~isempty(str2num(des{1})) % Plain column ascii numbers
        Ma = dlmread(fname);
        H = Ma(:,1);
        Y = Ma(:,2);
    else
        switch des{1}
            case 'Sample_Description:'              
                msgbox('Fileformat not recognized!','Error') % TODO
            otherwise
                msgbox('Fileformat not recognized!','Error')
                return
        end
    end
    
    H = reshape(H,[],1);
    Y = reshape(Y,[],1);
    
    tmp = pwd;
    cd(fpath);
    data{ind}.fname = fullfile(pwd,files(i).name);
    cd(tmp);
    clear tmp
    [pathstr, name, ext] = fileparts(data{ind}.fname);
    names{ind} = name;
    
    if ~isreal(Y)   % No complex values
        Y = real(Y);
    end
    
    pos = find(isnan(H)); % Remove NaN entries
    if ~isempty(pos)
       H(pos) = [];
       Y(pos) = [];
    end
    
    % Sort x-axis to always increasing
    [v ix] = sort(H);   
    data{ind}.H = H(ix);
    data{ind}.Y = Y(ix);
          
    data{ind}.date = files(i).date; % Get date of creation
    desc{ind} = '';            % Initialize description
    
    fprintf('%d\t%s\tNOP=',ind,files(i).name,numel(H));
    ind = ind+1;
end

spc.data = data;
spc.names = names;
spc.desc = desc;
spc.N = numel(spc.data);

clear Y H i ind files fpath v ix data desc fname names Ma des tmp
clear pathstr name ext

