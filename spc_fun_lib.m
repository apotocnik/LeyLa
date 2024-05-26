%--------------------------------------------------------------------------
% spc_fun_lib - fit function library
%
% Author: Anton Potocnik, F5, IJS
% Date:   28.01.2009 - 06.11.2013
% Arguments:
%       funstr = equ_lib(name, number)
% Input:    name    ... function name ('dLorentz', 'dDyson', 'dGauss') no
% numbers or other characters, only letters
%           number  ... parameters number area# width# pos# alpharea#
% Output:   funstr  ... string fitting function
%--------------------------------------------------------------------------
% NOTE!
% names must consist solely on letters, no numbers or other signs like *
%
function funstr = spc_fun_lib(name, number)
    
% Sign needed!!!
switch name
                           
    case 'Lorentz'      % w ... w(fwhm)
        funstr = ['+2*area#/pi*width#/(4*(x-pos#)^2+width#^2)'];
              
    case 'Gauss'        % w ... 2*w(pp)
       funstr =  ['+area#/sqrt(2*pi)/width#*exp(-(x-pos#)^2/2/width#^2)'];
                  
    case 'Dyson'       % w ... 2*w(pp)  alpha = 0abs...1dis 
        funstr = ['+area#*2/pi*(width#*cos(alpharea#)+2*(x-pos#)*sin(alpharea#))/(4*(x-pos#)^2+width#^2)'];
    
    case 'pVoigt'       % w ... 2*w(pp)  alpha = 0lor...1gauss 
        funstr = ['+area#*(alpha#*2/pi*width#/(4*(x-pos#)^2+width#^2)+(1-alpha#)*sqrt(4*log(2)/pi)/width#*exp(-(x-pos#)^2*4*log(2)/width#^2))' ];
                
    case 'power'       
        funstr = ['+p#*x^n#' ];
    
    case 'slope'
        funstr = '+slope*x';
    
    case 'offset'
        funstr = '0*x+offset';
        
    otherwise
        funstr = {'Lorentz','Gauss','Dyson','pVoigt','power','slope','offset'};
              
end

% Replace # with number
if ~iscell(funstr) 
    if nargin == 2
        funstr = strrep(funstr,'#',num2str(number));
    else
        funstr = strrep(funstr,'#','');
    end
end
