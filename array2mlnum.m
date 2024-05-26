%--------------------------------------------------------------------------
% array2mlnum  - rewrites array to matlab string equivalent
%
% Author: Anton Potocnik, F5, IJS
% Date:   25.01.2014
% Arguments:
%       txt = array2mlnum(array)
%
% Only step of one is reduced: [1 2 4] -> [1:2 4]
%--------------------------------------------------------------------------

function txt = array2mlnum(array)


k = 1;
beg = 1;
txt = ['[' num2str(array(k)) ':'];

if issorted(array)

    for k = 2:numel(array)
        if array(k) > array(k-1) + 1 % Bigger step
            if k > beg + 1
                txt = [txt num2str(array(k-1)) ' ' num2str(array(k)) ':'];
            else
                txt = [txt(1:end-1) ' ' num2str(array(k)) ':'];
            end
            beg = k;
        end
    end
    
elseif issorted(array(end:-1:1))
    error('Backwards array is not implemented yet!')
else
	error('Array is not obviousely sorted!')
end

% Finnalize if necessary
if beg < k
    txt = [txt num2str(array(end))];
else
    txt(end) = [];
end
txt = [txt ']'];
