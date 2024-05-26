%--------------------------------------------------------------------------
% SPC_delete  - delete specters in spc structure
%
% Version: 1.0
% Author: Anton Potocnik, F5, IJS
% Date:   13.03.2009 - 15.03.2009
%       
% Arguments spc = EPR_delete(spc,v)
% Input:    
%       spc         
%       v           vector of indeces to delete
%--------------------------------------------------------------------------

function spc = SPC_delete(spc,v)

spc.data(v) = [];
spc.names(v) = [];
spc.desc(v) = [];

if isfield(spc.fit,'fits')
    if numel(spc.fit.fits) >= v
        spc.fit.fits(v)=[];
    end
end
if isfield(spc.fit,'results')
    if size(spc.fit.results,1) >= v
        spc.fit.results(v,:)=[];
    end
end


spc.N = numel(spc.data);