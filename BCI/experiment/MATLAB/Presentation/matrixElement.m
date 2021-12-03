classdef matrixElement < handle
    properties
        textSize
        textColor
        XPosition='center'
        YPosition='center'
        text
        
        imgAdress
        windowRect
        imageRect
        imgSize
        tex                                     % CellArray: containing the texture of image type elements.
        image                                   % Vector: (2D) containing an image if needed to be presented as a nonmatrix element.
        
        XCursor
        YCursor
        textBounds
        vSpacing=1;
        windowHandle
        Parent
        Children
        WholeMatrix=true;                       % Flag: if true the background matrix will be drawn.
        MatrixPresentation=false;               % Flag: if true content of "text" will be highlighted on the background matrix.
        symbols                                 % CellArray: containing all elements to be shown in background matrix.
        symbolsType                             % CellArray: containing the type ('Text' or 'Image') of all elements to be shown in background matrix.
        minDistanceBetweenElements
        nonMatrixElementsRelativeVPosition=0;
        matrixForeColor                         % Vector : (1D) containing the RGB color for highlights.
        matrixBackColor                         % Vector : (1D) containing the RGB color for background matrix.
        relativeVerticalMatrixSize
        nonMatrixElementType
        matrixSize
        type
        MatrixSymbolRects
        MatrixElementSize
    end
    methods
        function self=matrixElement(type,text,presentationInfo,nonMatrixElementType)
            self.Children=linkedList;
            if(nargin>0)
                
                self.windowRect=presentationInfo.windowRect;
                self.matrixSize=presentationInfo.matrixSize;
                                
                self.symbols=presentationInfo.matrix.symbols;
                self.symbolsType=presentationInfo.matrix.symbolsType;
                
                self.tex=presentationInfo.imageTextures.tex;
                self.imgAdress=presentationInfo.imageTextures.Address;
                self.windowHandle=presentationInfo.window;
                self.minDistanceBetweenElements=presentationInfo.minDistanceBetweenMatrixElements;
                self.matrixForeColor=presentationInfo.matrixForeColor;
                self.matrixBackColor=presentationInfo.matrixBackColor;
                self.relativeVerticalMatrixSize=presentationInfo.relativeVerticalMatrixSize;
                self.WholeMatrix=true;
                self.MatrixSymbolRects=presentationInfo.MatrixSymbolRects;
                self.MatrixElementSize=presentationInfo.matrixElementSize;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Some cases are left as comment so that in the future can
                % be used if needed.
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                switch type
                    
                    case {'ERPStimulus','FRPStimulus','Target','ERPTrial','FRPTrial','Fixation','Decision','copyTaskTarget'}
                        
                        
                        if isfield(presentationInfo,'imageRectSize')
                            self.imgSize=presentationInfo.imageRectSize;
                        else
                            if sum(strfind(type,'FRP'))>0
                                self.imgSize=presentationInfo.FRPStimulusTextSize;
                            else
                                self.imgSize=presentationInfo.ERPStimulusTextSize;
                            end
                            
                            
                        end
                        if strcmp(type,'copyTaskTarget')
                            self.textSize=presentationInfo.copyTaskTarget.TextSize;
                        else
                            if sum(strfind(type,'FRP'))>0
                                self.textSize=presentationInfo.FRPStimulusTextSize;
                            else
                                self.textSize=presentationInfo.ERPStimulusTextSize;
                            end
                            
                        end
                        if strcmp(type,'copyTaskTarget')||strcmp(type,'Target')||strcmp(type,'Decision')|| strcmp(type,'Fixation')
                            screen_resolution = self.windowRect;
                            self.YPosition=floor(screen_resolution(4)*presentationInfo.nonMatrixElementsRelativeVPosition-self.textSize*1.4/2);
                            self.YPosition=min((floor(screen_resolution(4)-(self.textSize*1.4))),self.YPosition);
                            self.YPosition=max(self.YPosition,0);
                            self.XPosition=floor(screen_resolution(3)*presentationInfo.nonMatrixElementsRelativeHPosition-self.textSize*1.4/2);
                            self.XPosition=min((floor(screen_resolution(3)-(self.textSize*1.4))),self.XPosition);
                            self.XPosition=max(self.XPosition,0);
                        end
                        
                        if presentationInfo.matrixSpeller && (strcmp(type,'ERPTrial') || strcmp(type,'FRPTrial'))
                            self.MatrixPresentation=true;
                        else
                            self.MatrixPresentation=false;
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
                            if length(text)>1
                                self.text={text.Stimulus};
                            else
                                self.text=text.Stimulus;
                            end
                            if(strcmpi(text(1).Color,'default'))
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
                                self.textColor=str2num(text(1).Color);
                            end
                        end
                        self.WholeMatrix=false;
                        %                     case 'activePauseBar'
                        %                         self.textSize=presentationInfo.pauseBar.activeTextSize;
                        %                         self.text=presentationInfo.pauseBar.activeText;
                        %                         self.textColor=presentationInfo.pauseBar.activeColor;
                        %                         self.vSpacing=presentationInfo.pauseBar.vSpacing;
                        %                         if(ischar(presentationInfo.pauseBar.activeRelativeYLocation))
                        %                             self.YPosition=presentationInfo.pauseBar.activeRelativeYLocation;
                        %                         else
                        %                             self.YPosition=presentationInfo.pauseBar.activeRelativeYLocation*presentationInfo.windowRect(4);
                        %                         end
                        %                         if(ischar(presentationInfo.pauseBar.activeRelativeXLocation))
                        %                             self.XPosition=presentationInfo.pauseBar.activeRelativeXLocation;
                        %                         else
                        %                             self.XPosition=presentationInfo.pauseBar.activeRelativeXLocation*presentationInfo.windowRect(3);
                        %                         end
                        %                         self.WholeMatrix=false;
                        %                     case 'activePauseBarChannelDrop'
                        %                         self.textSize=presentationInfo.pauseBar.activeTextSize;
                        %                         self.text=presentationInfo.pauseBar.activeTextChannelDrop;
                        %                         self.textColor=presentationInfo.pauseBar.activeColor;
                        %                         self.vSpacing=presentationInfo.pauseBar.vSpacing;
                        %                         if(ischar(presentationInfo.pauseBar.activeRelativeYLocation))
                        %                             self.YPosition=presentationInfo.pauseBar.activeRelativeYLocation;
                        %                         else
                        %                             self.YPosition=presentationInfo.pauseBar.activeRelativeYLocation*presentationInfo.windowRect(4);
                        %                         end
                        %                         if(ischar(presentationInfo.pauseBar.activeRelativeXLocation))
                        %                             self.XPosition=presentationInfo.pauseBar.activeRelativeXLocation;
                        %                         else
                        %                             self.XPosition=presentationInfo.pauseBar.activeRelativeXLocation*presentationInfo.windowRect(3);
                        %                         end
                        %                         self.WholeMatrix=false;
                    case 'drawBackgroundMatrix'
                        
                        self.text=' ';
                        
                        %                     case {'TargetIndicator','DecisionIndicator','CopyTaskTargetIndicator'}
                        %                         self.textSize=presentationInfo.(type).TextSize;
                        %                         if(presentationInfo.(type).Enabled)
                        %                             self.text=[presentationInfo.(type).Text repmat(' ',1,(ceil(presentationInfo.StimulusTextSize/self.textSize)+length(presentationInfo.(type).Text)))];
                        %                         else
                        %                             self.text='';
                        %                         end
                        %                         % disp(self.text)
                        %                         %self.vSpacing=presentationInfo.nonMatrixElementsVSpacing+(self.textSize-100)*(7/200);
                        %                         self.textColor=presentationInfo.(type).Color;
                        %
                        %                         self.WholeMatrix=false;
                        
                        %                     case 'typingFeedback'
                        %                         if(ischar(text))
                        %                             self.text=text;
                        %                             self.textColor=presentationInfo.typingFeedbackBar.neutralColor;
                        %                         else
                        %                             self.text=text.text;
                        %                             switch text.mood
                        %                                 case 'neutral'
                        %                                     self.textColor=presentationInfo.typingFeedbackBar.neutralColor;
                        %                                 case 'positive'
                        %                                     self.textColor=presentationInfo.typingFeedbackBar.positiveColor;
                        %                                 case 'negative'
                        %                                     self.textColor=presentationInfo.typingFeedbackBar.negativeColor;
                        %                             end
                        %                             self.textSize=presentationInfo.typingFeedbackBar.TextSize;
                        %                             self.vSpacing=presentationInfo.typingFeedbackBar.vSpacing;
                        %                             self.XPosition=0;
                        %                             self.YPosition=0;
                        %
                        %                         end
                        %                         self.WholeMatrix=false;
                        
                end
                
                if self.WholeMatrix
                    self.textSize=presentationInfo.ERPStimulusTextSize;
                end
                % Buffering the type and required information to present
                % nonmatrix elements.
                if nargin>3
                    self.nonMatrixElementType=nonMatrixElementType;
                    
                    
                    if ~iscell(text)
                        
                        if ~isempty(text)
                            if(ischar(text))
                                self.imgAdress=text;
                                self.nonMatrixElementType='Text';
                            else
                                self.nonMatrixElementType=text.Type;
                                if strcmp(text.Type,'Image')
                                    self.imgAdress=text.Stimulus;
                                    self.image=presentationInfo.imageTextures.image{strcmpi(presentationInfo.imageTextures.Address,self.imgAdress)};
                                    self.tex=presentationInfo.imageTextures.tex{strcmpi(presentationInfo.imageTextures.Address,self.imgAdress)};
                                    
                                end
                                
                            end
                        end
                        
                        
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
                    case 'matrixElement'
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
                
                if self.MatrixPresentation || self.WholeMatrix
                   Screen('TextSize',self.windowHandle, self.MatrixElementSize); 
                    
                    % Forming the matrix of symbols.
                    for i = 1 : length(self.symbols)
                        
                        % Image type elements will be resized to the
                        % textSize.
                        switch self.symbolsType{i}
                            case 'Image'
                                
                                
                             
                                
                                tex=self.tex{find(strcmp(self.imgAdress,self.symbols{i}))};
                                
                                if sum(strcmp(self.symbols{i},self.text))>=1
                                    %Screen('FillRect', self.windowHandle ,[10,240,1], self.imageRect)
                                    Screen('DrawTexture', self.windowHandle, tex, [],self.MatrixSymbolRects{i},[],[],1,self.matrixForeColor);
                                else
                                    if self.WholeMatrix
                                        %Screen('FillRect', self.windowHandle ,[234,10,1], self.imageRect)
                                        Screen('DrawTexture', self.windowHandle, tex, [],self.MatrixSymbolRects{i},[],[],1,self.matrixBackColor);
                                    end
                                end
                                
                                
                            case 'Text'
                                
                             
                                
                                
                                if sum(strcmp(self.symbols{i},self.text))>=1
                                    %Screen('FillRect', self.windowHandle ,[10,240,1], self.imageRect)
                                    [self.XCursor, self.YCursor, self.textBounds] = DrawFormattedText(self.windowHandle, self.symbols{i},'center','center',self.matrixForeColor,[],[],[],[],[],self.MatrixSymbolRects{i}-[0,1,0,1]*.2*self.MatrixElementSize);
                                else
                                    if self.WholeMatrix
                                        %Screen('FillRect', self.windowHandle ,[234,10,1], self.imageRect)
                                        [self.XCursor, self.YCursor, self.textBounds] = DrawFormattedText(self.windowHandle, self.symbols{i},'center','center',self.matrixBackColor,[],[],[],[],[],self.MatrixSymbolRects{i}-[0,1,0,1]*.2*self.MatrixElementSize);
                                    end
                                end
                                
                        end
                        
                    end
                    
                else
                    % Drawing and writing nonmatrix elements on the screen.
                    if ~iscell(self.text)
                        
                        switch self.nonMatrixElementType
                            case 'Image'
                                
                                if(~isempty(self.Parent))
                                    switch class(self.Parent)
                                        case 'imageElement'
                                            self.XPosition=self.Parent.XCursor;
                                            self.YPosition=self.Parent.YCursor;
                                    end
                                end
                                rect=[self.XPosition,self.YPosition];
                                if ischar(self.imgSize)
                                    self.imgSize=max(size(self.image));
                                end
                                
                                
                                rect(2)=rect(2)+round(self.imgSize*.2);
                                self.imageRect=[rect,rect+self.imgSize];
                                
                                
                                if(isempty(self.imgAdress))
                                    self.XCursor=self.XPosition;
                                    self.YCursor=self.YPosition;
                                    self.imageRect=[self.XCursor,self.YCursor,self.XCursor,self.YCursor];
                                else
                                    
                                    Screen('DrawTexture', self.windowHandle, self.tex, [],self.imageRect,[],[],1,self.textColor);
                                    
                                    
                                end
                                
                                
                            case 'Text'
                                if(length(self.text)>=2 && strcmp(self.text(1:2),'\n'))
                                    
                                    
                                    [self.XCursor, self.YCursor, self.textBounds] = DrawFormattedText(self.windowHandle, self.text,0,self.YPosition,self.textColor,[],[],[],self.vSpacing);
                                else
                                    [self.XCursor, self.YCursor, self.textBounds] = DrawFormattedText(self.windowHandle, self.text,self.XPosition,self.YPosition,self.textColor,[],[],[],self.vSpacing);
                                end
                        end
                        
                        
                        
                    end
                    
                end
            end
            
            currentNode=self.Children.Head;
            for(elementIndex=1:self.Children.elementCount)
                currentNode.Data.Draw;
                currentNode=currentNode.Next;
            end
        end
        
        function copyObject=copy(self)
            copyObject=matrixElement;
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
