%% success = calibrateAmps(amplifierStruct)
%Calibrates the amplifiers.
%   calibrateAmps calibrates the amplifers listed in the amplifierStruct.
%   It also loges the calibration information (Scale and Offset) in the
%   ampInfoFilename.(The file is created in the logger function)
%   
%   success = calibrateAmps(amplifierStruct) 
%       returns
%           success (0/1) - a flag to show the success of the operation
%       uses
%           ampInfoFilename - the file used to write the calibration
%                           information.
% See also logger - LogError
%
%%

function success = calibrateAmps(amplifierStruct)
global ampInfoFilename
disp('')
disp('Calibrating amplifiers ...')
try
    for ampIndex = 1: amplifierStruct.numberOfAmplifiers
        set(amplifierStruct.ai(ampIndex),'Mode','Calibration');
        [offset, scaling] = gUSBampCalibration(amplifierStruct.ai(ampIndex).DeviceSerial,false);
        gUSBampSaveCalibration(offset,scaling,amplifierStruct.ai(ampIndex).DeviceSerial);
        
        templog=[repmat('\t',size(offset,1),1) num2str((1:size(offset,1))') repmat('\t',size(offset,1),1) num2str(offset) ...
            repmat('\t',size(offset,1),1) num2str(scaling) repmat('\n ',size(offset,1),1)]';
        templog = [amplifierStruct.ai(ampIndex).DeviceSerial '\n\t\tOffset\t\tScaling\n' reshape(templog,1,numel(templog))];
        logger(templog,ampInfoFilename);
        disp(['Amplifier   ' amplifierStruct.ai(ampIndex).DeviceSerial '   calibrated.'])
    end
    success = 1;
catch ME
    logError(ME);
    success=0;
end