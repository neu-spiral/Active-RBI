%% [success, amplfierStruct]=detectAmps()
%This function detects the amplifiers. 
%   detectAmps detects the connected amplifiers and creates amplifier objects. 
%   If the number of amplifiers is more than 1, it prints the serial numbers of 
%   the amplifiers and queries the master amplifier. Analog input objects as many 
%   as the number of amplifiers are also created.
%
%   [success, amplifierStruct]=detectAmps() returns
%       success (0/1) - a flag to show the success of the operation
%       amplifierStruct - a structure with the following fields filled in this
%       function
%
%           amplifierStruct.numberOfAmplifiers - Number of amplifiers (integer)
%           amplifierStruct.ai - Vector of analog input objects (amplifier object)
%           amplifierStruct.masterIndex - Index of the master amplifier (integer)
%           amplifierStruct.slaveIndex  - Index of the slave amplifier  (vector of integers)
% 
                     
%%
function [success,amplifierStruct]=detectAmps()


try
    %% Detection of the amplfiers and creation of amplifier objects
    amplifierStruct.numberOfAmplifiers=0;
    while amplifierStruct.numberOfAmplifiers==0
        amp_info = daqhwinfo('guadaq');  
        amplifierStruct.numberOfAmplifiers = length(amp_info.InstalledBoardIds);
        if(amplifierStruct.numberOfAmplifiers==0)
            disp('No amplifers detected.');
            disp('Please, check power and USB connections.');
            tryAgain=input('Try again? (y/n):','s');
            if(tryAgain=='n')
                disp('Detecting amplifier(s) aborted by user.')
                success=0;
                return;
            end
        end
    end
    
    amplifierSerialNums=cell(amplifierStruct.numberOfAmplifiers,1);
    for ampi = 1:amplifierStruct.numberOfAmplifiers
        amplifierStruct.ai(ampi)=analoginput('guadaq',amp_info.InstalledBoardIds{ampi});
        amplifierSerialNums{ampi}= amplifierStruct.ai(ampi).DeviceSerial;
    end
   %%  Query slave location in daisy-chain configuration and set the slave flags 
    if(amplifierStruct.numberOfAmplifiers > 1)
        string2display=num2str([repmat('  ',amplifierStruct.numberOfAmplifiers,1) ...
            num2str((1:amplifierStruct.numberOfAmplifiers)')...
            repmat(':  ',amplifierStruct.numberOfAmplifiers,1) cell2mat(amplifierSerialNums)]);
        
        continueFlag=1;
        while continueFlag
            disp(' ');
            disp('The list of the detected amplifiers:');
            disp(string2display)
            amplifierStruct.masterIndex=input('Please enter the number corresponding to master amplifier: ');
            %Slaves should be ordered, if there are more than two amplifiers.
            amplifierStruct.slaveIndex=setdiff(1:amplifierStruct.numberOfAmplifiers,amplifierStruct.masterIndex); 
            
            if(isnumeric(amplifierStruct.masterIndex))
                if(~isempty(amplifierStruct.masterIndex) && ...
                        0<amplifierStruct.masterIndex && ...
                        amplifierStruct.masterIndex<=amplifierStruct.numberOfAmplifiers)
                    continueFlag=0;
                else
                    disp(['Input is not valid, please enter an integer between 1 and ' num2str(amplifierStruct.numberOfAmplifiers) '.']);
                    
                end
            else
                disp(['Input is not valid, please enter an integer between 1 and ' num2str(amplifierStruct.numberOfAmplifiers) '.']);
                
            end
            
        end
        for ampi=1:amplifierStruct.numberOfAmplifiers
            if(ampi~=amplifierStruct.masterIndex)
                set(amplifierStruct.ai(ampi),'SlaveMode','on');
            end
        end
    else
        amplifierStruct.masterIndex=1;
        amplifierStruct.slaveIndex=[];
    end
    amplifierStruct.ai=amplifierStruct.ai([amplifierStruct.masterIndex amplifierStruct.slaveIndex]);
    success=1;
catch ME
    logError(ME);
    amplifierStruct=[];
    success=0;
end



