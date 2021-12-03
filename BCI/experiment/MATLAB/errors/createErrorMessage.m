
function createErrorMessage(errorCode, affectedVariableValue, affectedVariableName) 
switch errorCode
    case 100
        %error code 100 = hardware error
        msgbox(strcat({'Hardware Error; '}, affectedVariableName, {' = '}, num2str(affectedVariableValue)), 'Error','error');
        createErrorReport('Hardware Error', affectedVariableValue, affectedVariableName);
    case 101
        %error code 101 = user error
        msgbox(strcat({'User Error; '}, affectedVariableName, {' = '}, num2str(affectedVariableValue)), 'Error', 'custom', imread('error3.png'));
        createErrorReport('User Error', affectedVariableValue, affectedVariableName);
    case 102 
        %error code 102 = software error
        msgbox(strcat({'Software Error; '}, affectedVariableName, {' = '}, num2str(affectedVariableValue)), 'Error', 'custom', imread('error1.png'));
        createErrorReport('Software Error', affectedVariableValue, affectedVariableName);
    case 103
        %error code 103 = drowsiness detected
        msgbox(strcat({'Drowsiness detected; '}, affectedVariableName, {' = '}, num2str(affectedVariableValue)), 'Warning', 'custom', imread('drowsiness.jpg'));
        createErrorReport('Drowsiness detected', affectedVariableValue, affectedVariableName);
    case 104
        %error code 104 = noise detected
        msgbox(strcat({'Noise detected; '}, affectedVariableName, {' = '}, num2str(affectedVariableValue)), 'Warning', 'custom', imread('noise.jpg'));
        createErrorReport('Noise detected', affectedVariableValue, affectedVariableName);
    case 105
        %error code 105 = no EEG signal
        msgbox(strcat({'Expected EEG signal not present; '}, affectedVariableName, {' = '}, num2str(affectedVariableValue)), 'Warning', 'custom', imread('erp.png'));
        createErrorReport('Expected EEG signal not present', affectedVariableValue, affectedVariableName);
    case 106
        %error code 106 = code error
        msgbox(strcat({'Code Error; '}, affectedVariableName, {' = '}, num2str(affectedVariableValue)), 'Error', 'custom', imread('codebug.jpg'));
        createErrorReport('Code Error', affectedVariableValue, affectedVariableName);
    case 107
        %error code 107 = calibration error
        msgbox(strcat({'Calibration Error; '}, affectedVariableName, {' = '}, num2str(affectedVariableValue)), 'Error', 'custom', imread('calibration.jpg'));
        createErrorReport('Calibration Error', affectedVariableValue, affectedVariableName);
    case 108
        %error code 108 = timing/performance error
        msgbox(strcat({'Timing/Performance Error; '}, affectedVariableName, {' = '}, num2str(affectedVariableValue)), 'Error', 'custom', imread('timingerror.png'));
        createErrorReport('Timing/Performance Error', affectedVariableValue, affectedVariableName);
    otherwise
        %unknown error code
        msgbox(strcat({'Unknown Error; '}, affectedVariableName, {' = '}, num2str(affectedVariableValue)), 'Error','custom', imread('error2.png'));
        createErrorReport('Unknown Error', affectedVariableValue, affectedVariableName);
end


end 

function createErrorReport(errorName, affectedVariableValue, affectedVariableName)
    %creates an error report containing the contents of all local
    %variables below a given size. 
    outputText = sprintf('%s %s %s %s %s %s %s', 'EEG signal processing error report\n', errorName, ' ', affectedVariableName, ' = ', num2str(affectedVariableValue), '\n');
    getVariables = who;
    for x=1:size(getVariables)
        currentVar = eval(char(getVariables(x)));
        y = whos(char(getVariables(x)));
        currentVarSize = y.bytes;
        if(currentVarSize < 10000)
            outputText = sprintf('%s %s %s %s %s', outputText, char(getVariables(x)), ' = ', evalc('disp(currentVar)'), '\n');
        end
    end
    fileID = fopen('errorLog.txt','w','n','Shift_JIS');
    fprintf(fileID, '%s', char(outputText));
end
