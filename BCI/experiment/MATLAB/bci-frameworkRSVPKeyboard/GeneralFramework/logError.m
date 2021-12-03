%% logError(ME)
%Logs the errors
%   logError(ME), logs errors message in the errorFilename, file along with
%   the time-stamp and the filename(s) or the function(s) causing the error
%   and the line number in each of them. Errors can be the standard matlab
%   exception (ME) formtat, or they can be strings generated buy the programmer.
%
%   logError
%       uses:
%           errorFilename - The file containing the error log.
%       inputs:
%           ME - Matlab Exception or string
%           exitFlag - A flag indicating if the function should exit the
%           program completely or not. (default is 1 for exit)
%       outputs:
%           "Incorrect error message formatting." will be displayed incase
%               of an incorrect ME format.
%   Example:
%   function success = foo()
%   try
%
%
%   catch ME
%     logError(ME);
%     success=0;
%   end
%
%%

function logError(ME,exitFlag)
global errorFilename
if(nargin<2)
    exitFlag=1;
end
if(~exist(errorFilename,'var'))
    errorFilename='errorLog.txt';
end
fid=fopen(errorFilename,'a');
fprintf(fid,datestr(now,31));
fprintf(fid,'\r\n');
if(strcmpi(class(ME),'MException'))
    
    fprintf(fid,ME.identifier);
    fprintf(fid,'\r\n');
    fprintf(fid,ME.message);
    fprintf(fid,'\r\n');
    for stacki=1:length(ME.stack)
        fprintf(fid,'Error in %s (line %d)',ME.stack(stacki).file,ME.stack(stacki).line);
        fprintf(fid,'\r\n');
    end
    fprintf(fid,'\r\n');
    fclose(fid);
    if(exitFlag==1)
        ME.rethrow
    end
elseif(ischar(ME))
    fprintf(fid,'%s',ME);
    fprintf(fid,'\r\n');
    fclose(fid);
    %disp(ME);
    if(exitFlag==1)
        error(ME);
    end
else
    if(exitFlag==1)
        error('Incorrect error message formatting.');
    end
end