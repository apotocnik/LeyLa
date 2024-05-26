    function str = num2clip(array, names)
    %NUM2CLIP copies a numerical-array to the clipboard
    %
    % str = NUM2CLIP(ARRAY)
    %
    % Copies the numerical array ARRAY to the clipboard as a tab-separated
    % string. This format is suitable for direct pasting to Excel and other
    % programs.
    % Author: Anton Potocnik
    % Date: 09.09.2009 - 17.11.2013

    str = mat2str(array);
    str(str==char(32))=char(9);
    str(str==';')=char(10);
    str(str=='[')='';
    str(str==']')='';
    
    if nargin == 2
        if iscell(names)
            pos = find(str==char(10));
            str = [names{1} char(9) str];
            pos = find(str==char(10));
            for i=1:numel(pos)
                str = [str(1:pos(i)) names{i+1} char(9) str(pos(i)+1:end)];
                pos = find(str==char(10));
            end
        end
    end
    
    clipboard('copy',str);
    
    
    
    