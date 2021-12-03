%% function action = checkKeyboardOperations(keyStruct)
% checkKeyboardOperations(keyStruct)
% Evaluates the keyboard state and returns the action assigned to the first key in the list that has been pressed.
%
%   The inputs of the function:
%
%       keyStruct - Struct, contains data pertaining to key action values.
%
%   The outputs of the function:
%
%       action - Double, action value defined for a particular key.
%
%%

function [ action ] = checkKeyboardOperations( keyStruct )

    % Gets the status of any keypress that might have occurred (http://docs.psychtoolbox.org/KbQueueCheck).
    [keyIsDown, firstKeyPressTimes] = PsychHID('KbQueueCheck');

    % Checks if there has been a keypress.
    if keyIsDown == 1
        
        % Creates an array of booleans, which indicates which keys have been pressed previously.
        keyCodeActiveness = firstKeyPressTimes(keyStruct.code) > 0;
        
        % Sets the value the action variable.
        action = 2;
        
        % Iterates over the length of the keyCodeActiveness array backwards.
        for keyIndex = length(keyCodeActiveness):-1:1
            
            % Checks if the respective element from the keyCodeActiveness array is true.
            if keyCodeActiveness(keyIndex)
                
                % Sets the value of the action variable.
                action = keyStruct.actionValue(keyIndex);
                
            end
            
        end
        
    else
        
        % Sets the value the action variable.
        action = 2;
        
    end
    
end