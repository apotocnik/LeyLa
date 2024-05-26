    function ind = findStrInCell(txt, mycell, exact)
    %findStrInCell retnrs index of cell element with txt string
    %
    % ind = findStrInCell(txt, mycell, exact)
    %
    % Author: Anton Potocnik
    % Date: 27.01.2014
    
    if nargin < 3
        exact = 0;
    end
    
    switch exact
        case 1
            r = cellfun(@(x) strcmp(x,txt), mycell);
        otherwise
            r = cell2mat(cellfun(@(x) ~isempty(strfind(x,txt)), mycell,'UniformOutput',false));
    end
    
    ind = find(r==1);