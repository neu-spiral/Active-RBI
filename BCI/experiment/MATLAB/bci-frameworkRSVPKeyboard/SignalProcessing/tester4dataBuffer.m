N=10000;
shiftLengthList=[0,5,10];
bufferSize=100;
numberOfChannels=1;
type=0;
testCount=1;
addRange=10;
X=(1:N)';
timeTrialCount=10;

for(shiftLengthIndex=1:length(shiftLengthList))
    shiftLength=shiftLengthList(shiftLengthIndex);

for(testIndex=1:testCount)   
    myDataBuffer=dataBuffer(bufferSize,numberOfChannels,type,shiftLength);
    myDataBuffer.addData(zeros(shiftLength,numberOfChannels));

    totalAddedAmount=0;
    for(addTrial=1:100)
       addAmount=randi(addRange);
       try
       myDataBuffer.addData(X(totalAddedAmount+(1:addAmount)));
       catch
           myDataBuffer.addData(X(totalAddedAmount+(1:addAmount)));
       end
           
       totalAddedAmount=totalAddedAmount+addAmount;
       
       for(timeEndCounter=1:timeTrialCount)
           if(totalAddedAmount>myDataBuffer.bufferSize)
               timeEndIndex=randi(bufferSize)+(totalAddedAmount-myDataBuffer.bufferSize);
           else
               timeEndIndex=randi(totalAddedAmount);
           end
          for(timeBeginCounter=1:timeEndCounter)
              if(totalAddedAmount>myDataBuffer.bufferSize)
               timeBeginIndex=randi(timeEndIndex-totalAddedAmount+myDataBuffer.bufferSize)+(totalAddedAmount-myDataBuffer.bufferSize);
           else
               timeBeginIndex=randi(timeEndIndex);
           end
              disp([timeBeginIndex, timeEndIndex,totalAddedAmount]);
                  %timeBeginIndex=max(floor((totalAddedAmount-1)/myDataBuffer.bufferSize),0)*myDataBuffer.bufferSize+randi(timeEndIndex-floor((totalAddedAmount-1)/myDataBuffer.bufferSize)*myDataBuffer.bufferSize);
              try
                Y=myDataBuffer.getOrderedData(timeBeginIndex,timeEndIndex);
              catch
                  Y=myDataBuffer.getOrderedData(timeBeginIndex,timeEndIndex);
              end
                
                if(length(Y)~=timeEndIndex-timeBeginIndex+1 || sum(Y~=(timeBeginIndex:timeEndIndex)'))
                   Y=myDataBuffer.getOrderedData(timeBeginIndex,timeEndIndex);
                end
          end
       end

    end
    delete(myDataBuffer);   
end

end


