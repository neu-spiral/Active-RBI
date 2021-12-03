
if exist('userParamsCallMode','var')
    endOfParams='%===';
    fid = fopen('userParameters.m','r');
    flag=1;
    exeFlag=0;
    while flag
        tline = fgetl(fid);
        if strcmp(tline,userParamsCallMode)
            exeFlag=1;
        end
        if ~isempty(min(strfind(tline,endOfParams))) && min(strfind(tline,endOfParams))==1
            if exeFlag
                exeFlag=0;
                flag=0;
            end
        end
        if ischar(tline) && exeFlag
            eval(tline)
        end
    end
    clear('flag','fid','tline','exeFlag','endOfParams','userParamsCallMode')
end