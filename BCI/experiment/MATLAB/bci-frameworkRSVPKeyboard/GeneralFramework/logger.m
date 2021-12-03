%% logger(message,filename)
%logger records the message provided to the specified filename. This
%   function is used for processes logging. 
%   
%   logger(message,filename) takes the following variables as input.
%       message - A string that contains the message to be recorded
%       filename - A string that contains the filename where the message to
%       be recorded. 
% 
%  See also logError.
%%

function logger(message,filename)

fid=fopen(filename,'a');
fprintf(fid,datestr(now,31));
fprintf(fid,'\r\n');

if(ischar(message))
    fprintf(fid,message);
else
    error('Incorrect message formatting.');
end
fprintf(fid,'\r\n');
fclose(fid);