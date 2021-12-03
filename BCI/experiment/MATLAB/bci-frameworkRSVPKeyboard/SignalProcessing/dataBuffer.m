%% DATABUFFER   Data buffer class.
%A dataBuffer is an object that contains a data structure. When a
%   dataBuffer is constructed, a matrix with the corresponding buffer size is allocated. The constructor returns a handle to this object. When a
%   handle to a dataBuffer object is copied, for example during assignment or when passed
%   to a MATLAB function, the handle is copied but not the underlying
%   object property values.
%
% dataBuffer properties:
%   filledStatus        - Boolean flag to represent if the buffer had filled before.
%   lastIndex           - The position of the last sample placed in the buffer (important only for the circular buffer).
%   data                - Data matrix for the object with the dimensions of (bufferSize+shiftLength) x numberOfChannels.
%   numberofChannels    - The number of channels for the dataBuffer object.
%   bufferSize          - The size of the buffer in samples.
%   type                - Type of the buffer: 0 for circular, 1 for linear.
%                         Note: Usage of linear buffer requires might cause a
%                         slow addData operation, if the buffer size is
%                         large.
%   shiftLength         - (default 0) Internal shift on the buffer. When
%                         getOrderedData function is called, it shifts the data before returning based in shiftLength.
%                         Ex: Trigger buffer is expected to be shifted by the group delay.
%   lastSampleTimeIndex     - Sample time index of the last sample put inside
%                         the buffer. It represents the time of the latest data in the buffer in
%                         samples. This can be used to keep track of operations while the buffer
%                         is filling.
%
% dataBuffer methods:
%   addData             - Adds new data to the buffer.
%   getOrderedData      - Returns ordered data matrix.
%

%% Class definition: dataBuffer inherits the handle class to allow data referencing

classdef dataBuffer  < handle
    
    %% Properties of the dataBuffer class
    properties
        %Boolean flag to represent if the buffer had filled before.
        filledStatus
        
        %The position of the last sample placed in the buffer (important only for the circular buffer).
        lastIndex
        
        %Data matrix for the object with the dimensions of (bufferSize+shiftLength) x numberOfChannels.
        data
        
        %The number of channels for the dataBuffer object.
        numberofChannels
        
        %The size of the buffer in samples.
        bufferSize
        
        %Type of the buffer: 0 for circular, 1 for linear. Note: Usage of
        %linear buffer requires might cause a slow addData operation, if
        %the buffer size is large.
        type
        
        %(default 0) Internal shift on the buffer. When getOrderedData
        %function is called, it shifts the data before returning based in
        %shiftLength. Ex: Trigger buffer is expected to be shifted by the
        %group delay.
        shiftLength
        
        %Sample time index of the last sample put inside the buffer. It
        %represents the time of the latest data in the buffer in samples.
        %This can be used to keep track of operations while the buffer is
        %filling.
        lastSampleTimeIndex
    end
    
    properties (Access=private)
       uncorrectedLastSampleTimeIndex 
    end
    
    %% Methods of the dataBuffer class
    methods
        %% dataBuffer(bufferSize,numberOfChannels,type,shiftLength)
        %Constructor for the dataBuffer object. It initializes the empty data
        % buffer with the parameters bufferSize, numberOfChannels, type and
        % shiftLength. If shiftLength is not specified, it is initialized as
        % zero.
        function self=dataBuffer(bufferSize,numberOfChannels,type,shiftLength)
            if(nargin<4)
                shiftLength=0;
            end
            self.filledStatus=0;
            self.lastIndex=0;
            self.numberofChannels=numberOfChannels;
            self.bufferSize=bufferSize+shiftLength;
            self.type=type;
            self.shiftLength=shiftLength;
            self.uncorrectedLastSampleTimeIndex=0;
            self.lastSampleTimeIndex=0;%-shiftLength;
            self.data=zeros(self.bufferSize,numberOfChannels);
            self.addData(zeros(self.shiftLength,self.numberofChannels));
        end
        
        function addData(self,newData)
            %% addData(newData)
            %addData(newData) function adds newData matrix to the buffer. newData
            % should be a matrix of size (N x numberOfChannels) matrix, where numberOfChannels should match with the original setting of the buffer and N is number of new samples to be added into the buffer.
            
            %Updates the time index of the last sample.
            %self.lastSampleTimeIndex=self.lastSampleTimeIndex+size(newData,1);
            self.uncorrectedLastSampleTimeIndex=self.uncorrectedLastSampleTimeIndex+size(newData,1);
            %self.lastSampleTimeIndex=self.uncorrectedLastSampleTimeIndex-self.shiftLength;
            
            %If the buffer is a circular buffer,
            if(self.type==0)
                %If the size of the new data is larger than the buffer
                %size, it writes as much as it can to the buffer keeping the latest ones.
                if(size(newData,1)>=self.bufferSize)
                    self.data=newData(size(newData,1)-self.bufferSize+1:end,:);
                    self.filledStatus=1;
                    self.lastIndex=self.bufferSize;
                else
                    %If the buffer is large enough, all of the new data will be
                    %written into buffer.
                    if(size(newData,1)+self.lastIndex<size(self.data,1))
                        %If the addition of the new data does not reach to
                        %the physical end of the buffer, it is placed to its corresponding place and lastIndex is updated accordingly.
                        self.data((self.lastIndex+1):(size(newData,1)+self.lastIndex),:)=newData;
                        self.lastIndex=(size(newData,1)+self.lastIndex);
                    else
                        %If the addition of the new data exceeds the
                        %physical end of the buffer, the new data is divided into two
                        %parts, so that the first part just ends at the
                        %physical end of the buffer. Second part is written
                        %starting from the physical beginning of the
                        %buffer. lastIndex is set to the end of second
                        %part.
                        self.filledStatus=1;
                        
                        %First part
                        self.data((self.lastIndex+1):end,:)=newData(1:(self.bufferSize-self.lastIndex),:);
                        
                        %Second part
                        self.data(1:(size(newData,1)+self.lastIndex-self.bufferSize),:)=newData((self.bufferSize-self.lastIndex+1):end,:);
                        self.lastIndex=(size(newData,1)+self.lastIndex-self.bufferSize);
                    end
                end
            else
                % If the buffer is linear
                if(size(newData,1)>=self.bufferSize)
                    %If the size of the new data is larger than the buffer
                    %size, it writes as much as it can to the buffer keeping the latest ones.
                    self.data=newData(size(newData,1)-self.bufferSize+1:end,:);
                else
                    %If the buffer is large enough, all of the new data will be
                    %written into buffer.
                    self.data=[self.data(size(newData,1)+1:end,:);newData];
                end
            end
        end
        
        
        %% X=getOrderedData(timeBeginIndex,timeEndIndex)
        %X=getOrderedData(timeBeginIndex,timeEndIndex) function returns the
        %data matrix corresponding to the sample interval [timeBeginIndex,
        %timeEndIndex]. If timeEndIndex is not specified, it is set to the
        %the final accessible data point. If timeBeginIndex is not
        %specified, it is set to the first data point in the buffer.
        %If the type of the buffer is linear, timeBeginIndex and
        %timeEndIndex are ignored and the full buffer is returned.
        % output X is a (numberOfSamples x numberOfChannels) matrix, where
        % numberOfSamples is at most timeEndIndex-timeBeginIndex+1.
        %On the occasions where timeEndIndex or timeBeginIndex contain
        %inaccassible indices, as much data as possible is returned.
        %
        function X=getOrderedData(self,varargin)%timeBeginIndex,timeEndIndex)
            if(self.type==0)
                [relativeBeginIndex,relativeEndIndex]=self.getRelativeTimeIndices(varargin);%timeBeginIndex,timeEndIndex);
                if(relativeBeginIndex==-1 || relativeEndIndex==-1)
                    X=[];
                elseif(relativeBeginIndex>self.lastIndex && relativeEndIndex<=self.lastIndex)
                    X=[self.data(relativeBeginIndex:self.bufferSize,:);self.data(1:relativeEndIndex,:)];
                else
                    X=self.data(relativeBeginIndex:relativeEndIndex,:);
                end
            else
                X=self.data(1:end-self.shiftLength,:);
            end
        end

        function lastSampleTimeIndex=get.lastSampleTimeIndex(self)
           lastSampleTimeIndex=self.uncorrectedLastSampleTimeIndex-self.shiftLength;
        end
        
        
        
        %% [relativeBeginIndex,relativeEndIndex]=getRelativeTimeIndices(self,args)
        %[relativeBeginIndex,relativeEndIndex]=getRelativeTimeIndices(self,args)
        %calculates the relative locations in the buffer corresponding to
        %given time indices for circular buffer. args={timeBeginIndex,timeEndIndex}
        function [relativeBeginIndex,relativeEndIndex]=getRelativeTimeIndices(self,args)%timeBeginIndex,timeEndIndex)
            relativeBeginIndex=-1;
            relativeEndIndex=-1;
            if(length(args)<2)
                relativeEndIndex=self.lastIndex-self.shiftLength;
            else
                timeBeginIndex=args{1};
                timeEndIndex=args{2};
                if(timeBeginIndex>timeEndIndex || self.bufferSize<self.uncorrectedLastSampleTimeIndex-timeEndIndex)
                    return;
                end
                if(timeEndIndex>self.lastSampleTimeIndex)
                    timeEndIndex=self.lastSampleTimeIndex;
                end
                relativeEndIndex=self.lastIndex-self.uncorrectedLastSampleTimeIndex+timeEndIndex;
                if(relativeEndIndex<=0)
                    relativeEndIndex=relativeEndIndex+self.bufferSize;
                end
            end
            if(length(args)<1)
                if(self.filledStatus)
                    relativeBeginIndex=self.lastIndex+1;
                else
                    relativeBeginIndex=1;
                end
            else
                if(length(args)==1)
                    timeBeginIndex=args{1};
                end
                if(self.bufferSize<=self.uncorrectedLastSampleTimeIndex-timeBeginIndex)
                    relativeBeginIndex=self.lastIndex+1;
                elseif(self.lastSampleTimeIndex<timeBeginIndex)
                    return;
                else
                    relativeBeginIndex=self.lastIndex-self.uncorrectedLastSampleTimeIndex+timeBeginIndex;
                end
                if(relativeBeginIndex<=0)
                    relativeBeginIndex=relativeBeginIndex+self.bufferSize;
                end
            end
        end
        
        
        
    end
    
    
    
end