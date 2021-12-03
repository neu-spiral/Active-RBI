classdef imageElement < handle
    properties
        XPosition='center'
        YPosition='center'
        image
        imageRect
        imgAdress
        imageColor = [];
        windowRect
        imgSize
        XCursor
        YCursor
        windowHandle
        Parent
        Children
        tex
    end
    methods
        function self=imageElement(type,imageAddress,presentationInfo)
            self.Children=linkedList;
            if(nargin>0)
                self.windowHandle=presentationInfo.window;
                self.windowRect=presentationInfo.windowRect;
                switch type
                    case {'LevelUpSign'}
                        if isfield(presentationInfo,'imageRectSize')
                            self.imgSize=presentationInfo.imageRectSize;
                        else
                            self.imgSize='Origin';
                        end
                        if(ischar(imageAddress))
                            self.imgAdress=imageAddress;
                        else
                            self.imgAdress=imageAddress.Stimulus;
                        end    
                        self.image=presentationInfo.imageTextures.image{strcmpi(presentationInfo.imageTextures.Address,self.imgAdress)};
                        self.tex=presentationInfo.imageTextures.tex{strcmpi(presentationInfo.imageTextures.Address,self.imgAdress)};
                    case {'ERPTrial','FRPTrial','ERPStimulus','FRPStimulus','Fixation','Target','Decision'}  
                       if isfield(presentationInfo,'imageRectSize')
                           self.imgSize=presentationInfo.imageRectSize;
                       else
                           if sum(strfind(type,'FRP'))>0
                               self.imgSize=presentationInfo.FRPStimulusTextSize;
                           else
                               self.imgSize=presentationInfo.ERPStimulusTextSize;
                           end
                       end
                        if(ischar(imageAddress))
                            self.imgAdress=imageAddress;
                        else
                            self.imgAdress=imageAddress.Stimulus;
                        end
                        self.image=presentationInfo.imageTextures.image{strcmpi(presentationInfo.imageTextures.Address,self.imgAdress)};
                        self.tex=presentationInfo.imageTextures.tex{strcmpi(presentationInfo.imageTextures.Address,self.imgAdress)};
                        
                        if(strcmpi(imageAddress.Color,'default'))
                            if(isfield(presentationInfo.Color,type))
                                self.imageColor=presentationInfo.Color.(type);
                            else
                                if sum(strfind(type,'FRP'))>0
                                    self.imageColor=presentationInfo.Color.FRPStimulus;
                                else
                                    self.imageColor=presentationInfo.Color.ERPStimulus;
                                end
                                
                            end
                        else
                            self.imageColor=[];
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
                    case 'imageElement'
                        self.XPosition=self.Parent.XCursor;
                        self.YPosition=self.Parent.YCursor;
                end
            end
            rect=round(self.windowRect/2);
            if ischar(self.imgSize)
                self.imgSize=max(size(self.image));
            end
            rect=rect(3:end);
            rect=rect-round(self.imgSize/2);
            rect(2)=rect(2)+round(self.imgSize*.2);
            self.imageRect=[rect,rect+self.imgSize];
            
            if isnumeric(self.XPosition)
                self.imageRect(1,1)= self.imageRect(1,1)+ self.XPosition;
                self.imageRect(1,3)= self.imageRect(1,3)+ self.XPosition;
                self.imageRect(1,2)= self.imageRect(1,2)+ self.YPosition;
                self.imageRect(1,4)= self.imageRect(1,4)+ self.YPosition;
            
            end
            if(isempty(self.imgAdress))
                self.XCursor=self.XPosition;
                self.YCursor=self.YPosition;
                self.imageRect=[self.XCursor,self.YCursor,self.XCursor,self.YCursor];
            else
            %tex=Screen('MakeTexture', self.windowHandle, self.image);
            Screen('DrawTexture', self.windowHandle, self.tex, [],self.imageRect,[],[],[],self.imageColor);
               
            
            end
            currentNode=self.Children.Head;
            for(elementIndex=1:self.Children.elementCount)
                currentNode.Data.Draw;
                currentNode=currentNode.Next;
            end
        end
        
        function copyObject=copy(self)
            copyObject=imageElement;
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