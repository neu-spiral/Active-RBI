%% function DrawBackground( win, type, backgroundInfo )
% DrawBackground( win, type, backgroundInfo )
% Draws a background for the specified window, using the given information about the background.
%
%   The inputs of the function:
%
%       win - Double, pointer to the window for which the background is to be drawn.
%
%       type - String, determines the nature of the background to be drawn.
%
%       backgroundInfo - Struct, contains the information for the background being drawn.
%
%%

function DrawBackground( win, type, backgroundInfo )

    % Check if the type of background to be drawn.
    switch type
        
        case 'topFeedbackText' % If the type of background is topFeedbackText...
            
            % Specify the size of the text.
            Screen('TextSize',win, backgroundInfo.TextSize);
            
            % Initialise position variables.
            nx = 0;
            ny = 0;
            
            % Iterate over the length of the backgroundInfo.TextList array.
            for feedbackParti = 1:length(backgroundInfo.TextList)
                
                % Draw the formatted text for the respective element of the backgroundInfo.TextList array, using the information from backgroundInfo.
                [nx, ny, textbounds] = DrawFormattedText( win, backgroundInfo.TextList{feedbackParti}, nx, ny, backgroundInfo.ColorList{feedbackParti}, [], [], [], backgroundInfo.vSpacing);
                
            end

            % Check if borders are enabled.
            if(backgroundInfo.BorderEnabled)
                
                % Calculate the vertical position of the border line.
                borderLineY = ny + (backgroundInfo.TextSize * backgroundInfo.vSpacing);
                
                % Draw the border line.
                Screen('DrawLine', win,backgroundInfo.BorderInfo.color, backgroundInfo.BorderInfo.XPosition(1),borderLineY,backgroundInfo.BorderInfo.XPosition(2),borderLineY, backgroundInfo.BorderInfo.width);
                
            end

        case 'pauseBar' % If the type of background is pauseBar...
            
            % Specify the size of the text.
            Screen('TextSize',win, backgroundInfo.TextSize);
            
            % Draw the formatted text, using the information from backgroundInfo.
            DrawFormattedText(win, backgroundInfo.Text, 'center',backgroundInfo.Ylocation, backgroundInfo.Color);
            
        otherwise % If the type of background is some other value...
            
            % Do nothing
            
    end
    
end