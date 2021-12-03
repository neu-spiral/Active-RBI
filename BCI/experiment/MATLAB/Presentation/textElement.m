classdef textElement < handle
    properties
        textSize
        textColor
        XPosition='center'
        YPosition='center'
        text
        XCursor
        YCursor
        textBounds
        vSpacing=1;
        windowHandle
        Parent
        Children
    end
    methods
        function self=textElement(type,text,presentationInfo)
            self.Children=linkedList;
            if(nargin>0)
                self.windowHandle=presentationInfo.window;
                switch type
                    case {'Target','ERPTrial','FRPTrial','Fixation','Decision','copyTaskTarget','SequenceBegin','ERPStimulus','FRPStimulus'}
                        if strcmp(type,'copyTaskTarget')
                            self.textSize=presentationInfo.copyTaskTarget.TextSize;
                        else
                            if sum(strfind(type,'FRP'))>0
                                self.textSize=presentationInfo.FRPStimulusTextSize;
                            else
                                self.textSize=presentationInfo.ERPStimulusTextSize;
                            end
                        end
                        if(ischar(text))
                            self.text=text;
                            if(isfield(presentationInfo.Color,type))
                                self.textColor=presentationInfo.Color.(type);
                            else
                                if sum(strfind(type,'FRP'))>0
                                    self.textColor=presentationInfo.Color.FRPStimulus;
                                else
                                    self.textColor=presentationInfo.Color.ERPStimulus;
                                end
                            end
                        else
                            self.text=text.Stimulus;
                            if(strcmpi(text.Color,'default'))
                                if(isfield(presentationInfo.Color,type))
                                    self.textColor=presentationInfo.Color.(type);
                                else
                                    if sum(strfind(type,'FRP'))>0
                                        self.textColor=presentationInfo.Color.FRPStimulus;
                                    else
                                        self.textColor=presentationInfo.Color.ERPStimulus;
                                    end
                                end
                            else
                                self.textColor=str2num(text.Color);
                            end
                        end
                        
                    case 'activePauseBar'
                        self.textSize=presentationInfo.pauseBar.activeTextSize;
                        self.text=presentationInfo.pauseBar.activeText;
                        self.textColor=presentationInfo.pauseBar.activeColor;
                        self.vSpacing=presentationInfo.pauseBar.vSpacing;
                        if(ischar(presentationInfo.pauseBar.activeRelativeYLocation))
                            self.YPosition=presentationInfo.pauseBar.activeRelativeYLocation;
                        else
                            self.YPosition=presentationInfo.pauseBar.activeRelativeYLocation*presentationInfo.windowRect(4);
                        end
                        if(ischar(presentationInfo.pauseBar.activeRelativeXLocation))
                            self.XPosition=presentationInfo.pauseBar.activeRelativeXLocation;
                        else
                            self.XPosition=presentationInfo.pauseBar.activeRelativeXLocation*presentationInfo.windowRect(3);
                        end
                    case 'activePauseBarChannelDrop'
                        self.textSize=presentationInfo.pauseBar.activeTextSize;
                        self.text=presentationInfo.pauseBar.activeTextChannelDrop;
                        self.textColor=presentationInfo.pauseBar.activeColor;
                        self.vSpacing=presentationInfo.pauseBar.vSpacing;
                        if(ischar(presentationInfo.pauseBar.activeRelativeYLocation))
                            self.YPosition=presentationInfo.pauseBar.activeRelativeYLocation;
                        else
                            self.YPosition=presentationInfo.pauseBar.activeRelativeYLocation*presentationInfo.windowRect(4);
                        end
                        if(ischar(presentationInfo.pauseBar.activeRelativeXLocation))
                            self.XPosition=presentationInfo.pauseBar.activeRelativeXLocation;
                        else
                            self.XPosition=presentationInfo.pauseBar.activeRelativeXLocation*presentationInfo.windowRect(3);
                        end
                    case 'inactivePauseBar'
                        self.vSpacing=presentationInfo.pauseBar.vSpacing;
                        self.textSize=presentationInfo.pauseBar.inactiveTextSize;
                        self.text=presentationInfo.pauseBar.inactiveText;
                        self.textColor=presentationInfo.pauseBar.inactiveColor;
                        if(ischar(presentationInfo.pauseBar.inactiveRelativeYLocation))
                            self.YPosition=presentationInfo.pauseBar.inactiveRelativeYLocation;
                        else
                            self.YPosition=presentationInfo.pauseBar.inactiveRelativeYLocation*presentationInfo.windowRect(4);
                        end
                        if(ischar(presentationInfo.pauseBar.inactiveRelativeXLocation))
                            self.XPosition=presentationInfo.pauseBar.inactiveRelativeXLocation;
                        else
                            self.XPosition=presentationInfo.pauseBar.inactiveRelativeXLocation*presentationInfo.windowRect(3);
                        end
                    case {'TargetIndicator','DecisionIndicator','CopyTaskTargetIndicator','FRPIndicator'}
                        self.textSize=presentationInfo.(type).TextSize;
                        if(presentationInfo.(type).Enabled)
                            if strcmp(type,'FRPIndicator')
                                self.text=[presentationInfo.(type).Text repmat(' ',1,(ceil(presentationInfo.FRPStimulusTextSize/self.textSize)+length(presentationInfo.(type).Text)))];
                            else
                                self.text=[presentationInfo.(type).Text repmat(' ',1,(ceil(presentationInfo.ERPStimulusTextSize/self.textSize)+length(presentationInfo.(type).Text)))];
                            end
                            
                        else
                            self.text='';
                        end
                        
                        
                        self.textColor=presentationInfo.(type).Color;
                        
                        
                        
                    case 'typingFeedback'
                        if(ischar(text))
                            self.text=text;
                            self.textColor=presentationInfo.typingFeedbackBar.neutralColor;
                        else
                            self.text=text.text;
                            switch text.mood
                                case 'neutral'
                                    self.textColor=presentationInfo.typingFeedbackBar.neutralColor;
                                case 'positive'
                                    self.textColor=presentationInfo.typingFeedbackBar.positiveColor;
                                case 'negative'
                                    self.textColor=presentationInfo.typingFeedbackBar.negativeColor;
                            end
                            self.textSize=presentationInfo.typingFeedbackBar.TextSize;
                            self.vSpacing=presentationInfo.typingFeedbackBar.vSpacing;
                            self.XPosition=0;
                            self.YPosition=0;
                        end
                        
                        
                end
            end
        end
        
        function addGraphicElement(self,element)
            self.Children.insertEnd(listNode(element));
            element.Parent=self;
        end
        
        function Draw(self)
            if(~isempty(self.Parent))
                switch class(self.Parent)
                    case 'textElement'
                        self.XPosition=self.Parent.XCursor;
                        self.YPosition=self.Parent.YCursor;
                end
            end
            Screen('TextSize',self.windowHandle, self.textSize);
            if(isempty(self.text))
                self.XCursor=self.XPosition;
                self.YCursor=self.YPosition;
                self.textBounds=[self.XCursor,self.YCursor,self.XCursor,self.YCursor];
            else
            %if(strcmp(self.YPosition,'center'))
            if(length(self.text)>=2 && strcmp(self.text(1:2),'\n'))
            [self.XCursor, self.YCursor, self.textBounds] = DrawFormattedText(self.windowHandle, self.text,0,self.YPosition,self.textColor,[],[],[],self.vSpacing);    
            else
            [self.XCursor, self.YCursor, self.textBounds] = DrawFormattedText(self.windowHandle, self.text,self.XPosition,self.YPosition,self.textColor,[],[],[],self.vSpacing);
            end
%             else
%             newLineLocations=[-1 strfind(self.text,'\n')];
%             tempXPos=self.XPosition;
%             tempYPos=self.YPosition;
%             for(newLineIndex=1:length(newLineLocations)-1)
%                 [self.XCursor, self.YCursor, self.textBounds] = DrawFormattedText(self.windowHandle, self.text(newLineLocations(newLineIndex)+2:newLineLocations(newLineIndex+1)+1),tempXPos,tempYPos,self.textColor,[],[],[],self.vSpacing);
%                 
%                 tempXPos=0;
%                 tempYPos=self.YCursor;
%             end
%             if(newLineLocations(newLineIndex)+2<=length(self.text))
%                 tempXPos=self.XCursor;
%                 
%                 [self.XCursor, self.YCursor, self.textBounds] = DrawFormattedText(self.windowHandle, self.text(newLineLocations(newLineIndex)+2:end),tempXPos,tempYPos,self.textColor,[],[],[],self.vSpacing);
%             end
%            end
            end
            currentNode=self.Children.Head;
            for(elementIndex=1:self.Children.elementCount)
                currentNode.Data.Draw;
                currentNode=currentNode.Next;
            end
        end
        
        function copyObject=copy(self)
            copyObject=textElement;
            S=properties(self);
            for(propertyIndex=1:length(S))
                copyObject.(S{propertyIndex})=self.(S{propertyIndex});
            end
            
            if(~isempty(self.Children))
                copyObject.Children=linkedList;
                currentNode=self.Children.Head;
                while(~isempty(currentNode))
                    copyObject.Children.insertEnd(listNode(copy(currentNode.Data)));
                    copyObject.Children.Tail.Data.Parent=copyObject;
                    currentNode=currentNode.Next;
                end
            end
        end
        
    end
end