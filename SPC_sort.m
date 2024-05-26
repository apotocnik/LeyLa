%--------------------------------------------------------------------------
% SPC_sort  - sorts specters in spc structure
%
% Version: 1.1
% Author: Anton Potocnik, F5, IJS
% Date:   17.05.2009
%       
% Input:    
%       spc         
%       spc.sort    temp,freq,dates
%       spc.sortDir descend,ascend
%--------------------------------------------------------------------------


if ~isfield(spc,'sortDir')
    spc.sortDir = 'descend';  % 'ascend'
end

% SORT in ascend order
[v ix] = sort(spc.(spc.sort),spc.sortDir);


% if strcmp(spc.sortDir,'descend')    % problems with cell arrays
%     ix = ix(numel(ix):-1:1);
% end

spc.data = reshape(spc.data(ix),[],1);
spc.temp = reshape(spc.temp(ix),[],1);
spc.freq = reshape(spc.freq(ix),[],1);
spc.dates = reshape(spc.dates(ix),[],1);

spc.fit.fits = reshape(spc.fit.fits(ix),[],1);
spc.sim = reshape(spc.sim(ix),[],1);

if isfield(spc.fit,'results')
    s = size(spc.fit.results,1);
    if s==0, return; end
    spc.fit.results(s+1:spc.N,:) = zeros(spc.N-s,size(spc.fit.results,2));
    spc.fit.results = spc.fit.results(ix,:);
end

if isfield(spc.fit,'results_g')
    s = size(spc.fit.results_g,1);
    if s==0, return; end
    spc.fit.results_g(s+1:spc.N,:) = zeros(spc.N-s,size(spc.fit.results_g,2));
    spc.fit.results_g = spc.fit.results_g(ix,:);
end

if isfield(spc,'results_g1')
    s = size(spc.results_g1,1);
    if s==0, return; end
    spc.results_g1(s+1:spc.N,:) = zeros(spc.N-s,size(spc.results_g1,2));
    spc.results_g1 = spc.results_g1(ix,:);
end

if isfield(spc,'results_g2')
    s = size(spc.results_g2,1);
    if s==0, return; end
    spc.results_g2(s+1:spc.N,:) = zeros(spc.N-s,size(spc.results_g2,2));
    spc.results_g2 = spc.results_g2(ix,:);
end

if isfield(spc,'results_g3')
    s = size(spc.results_g3,1);
    if s==0, return; end
    spc.results_g3(s+1:spc.N,:) = zeros(spc.N-s,size(spc.results_g3,2));
    spc.results_g3 = spc.results_g3(ix,:);
end

if isfield(spc,'results_g4')
    s = size(spc.results_g4,1);
    if s==0, return; end
    spc.results_g4(s+1:spc.N,:) = zeros(spc.N-s,size(spc.results_g4,2));
    spc.results_g4 = spc.results_g4(ix,:);
end

if isfield(spc.nra,'results')
    s = size(spc.nra.results,1);
    if s==0
        return
    end
    if s < spc.N
       spc.nra.results(s:spc.N,:)=zeros(size(spc.nra.results,2),spc.N-s);
       spc.nra.results_g(s:spc.N,:)=zeros(size(spc.nra.results_g,2),spc.N-s);
    end
    spc.nra.results = spc.nra.results(ix,:);
    spc.nra.results_g = spc.nra.results_g(ix,:);
end

clear v ix
    