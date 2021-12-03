function [thetaPower,alphaPower,lateralEyeMovement,eyeBlinkRate]=calculateVigilanceMeasures(trialData,channelNames,fs)


Index=[];
channelIndices={'Fp1','Fp2','Fc1','Fc2','F3','F4','Fz','Cz','F7','F8'};

for count=1:length(channelIndices)
    if ~isempty(find(strcmpi(channelNames,channelIndices{count}),1))
        Index=[Index;find(strcmpi(channelNames,channelIndices{count}))];
    end
    
end

ind1=find(Index<9);
ind2=find(Index<8);
ind3=find(Index>8 & Index<11);
ind4=find(Index>0 & Index<3);

frequencyRange=[0.2:0.05:2,2.5:0.5:12];
windowLength=fs/2;
overLap=windowLength-1;

if ~isempty(Index)
    allPowersAllChannels=zeros(length(frequencyRange),size(trialData,1)-overLap,length(Index));
    
    for channelCount=1:length(Index)
        allPowersAllChannels(:,:,channelCount) = abs(spectrogram(trialData(:,channelCount),windowLength,overLap,frequencyRange,fs));
    end
    
    if ~isempty(ind1)
        thetaPower(:,:)=mean(mean(allPowersAllChannels((find(frequencyRange>=4 & frequencyRange<8)),:,ind1),3));
    else
        thetaPower=zeros(1,size(trialData,1)-overLap);
    end
    
    if ~isempty(ind2)
        alphaPower(:,:)=mean(mean(allPowersAllChannels((find(frequencyRange>=8 & frequencyRange<12)),:,ind2),3));
    else
        alphaPower=zeros(1,size(trialData,1)-overLap);
    end
    
    if ~isempty(ind3)
        lateralEyeMovement(:,:)=mean(mean(allPowersAllChannels((find(frequencyRange>=0.2 & frequencyRange<=1.5)),:,ind3),3));
    else
        lateralEyeMovement=zeros(1,size(trialData,1)-overLap);
    end
    
    if ~isempty(ind4)
        eyeBlinkRate(:,:)=mean(mean(allPowersAllChannels((find(frequencyRange>=0.2 & frequencyRange<4)),:,ind4),3));
    else
        eyeBlinkRate=zeros(1,size(trialData,1)-overLap);
    end
 
else
    eyeBlinkRate=zeros(1,size(trialData,1)-overLap);
    lateralEyeMovement=zeros(1,size(trialData,1)-overLap);
    alphaPower=zeros(1,size(trialData,1)-overLap);
    thetaPower=zeros(1,size(trialData,1)-overLap);
    
end











