%% [featureExtractionProcessFlow,simulationResults,statistics2display]=offlineAnalysis(calibrationEnabled,fileName,fileDirectory)
%  offlineAnalysis(calibrationEnabled,sessionFilename) loads recorded data, calculates scores and
%  AUC using cross validation, estimates probability density functions for target and non-target
%  scores via kernel density estimation and their accepted thresholds. It calibrates the classifier
%  which is contained in a processFlow object. It saves these information in calibratioFile.mat at
%  the same directory.
%
%  If it is enabled from RSVPKeyboardParameters, it also conducts a simulation study to estimate the
%  typing performances in a copyphrase scenario. For simulations, EEG scores are sampled and used from the
%  conditional kernel density estimators.
%
%   The inputs of the function
%      calibrationEnabled - (0/1) boolean flag - If 1: result of
%                           calibration will be saved in a mat file. If 0:
%                           just calculate and display AUC without saving
%                           the results. (Default is 1)
%
%       fileName and fileDirectory - session file name and directory, if it is not specified file
%       selection dialog pops-up to make user select a file
%
%   The outputs of the function
%       featureExtractionProcessFlow - can be scoreStruct or empty depends
%                                     on the calibrationEnabled flag
%
%  See also crossValidationObject, calculateAuc, kde1d ,scoreThreshold,...
%%
function [featureExtractionProcessFlow]=offlineAnalysis(calibrationEnabled,fileName,fileDirectory)
if(nargin<1)
    calibrationEnabled=1;
end



addpath(genpath('.'));
disp('Loading data...');
if(~exist('fileName','var'))
    disp('Please select the file to be used in offline analysis');
    [fileName,fileDirectory]=uigetfile({'*.csv','Raw data (.csv)';'*.bin','Raw data (.bin)';'*.daq','Raw data (.daq)';'*.mat','Preprocessed Data (.mat)'},'Please select the file to be used in offline analysis','MultiSelect', 'on','Data\');
end
filetype=fileName(end-2:end);
switch filetype
    case {'daq','bin','csv'}
        if(strcmp(filetype,'bin') || strcmp(filetype,'csv'))
        [rawData,triggerSignal,fs,channelNames,filterInfo,daqInfos,sessionFolder]=loadSessionDataBin('daqFileName',[fileDirectory fileName],'sessionFolder', fileDirectory);
        else
        [rawData,triggerSignal,fs,channelNames,filterInfo,daqInfos,sessionFolder]=loadSessionData(fileName,fileDirectory);    
        end
        disp('Data is loaded');
        % Ad        ditional variable loading for matrixSpeller.
        vars = whos('-file',[fileDirectory 'taskHistory.mat']);
        
        if ismember('matrixSequences', {vars.name})
            system(['unzip ' fileDirectory 'Parameters.zip imageList.xls -d ' fileDirectory]); 
            load([fileDirectory 'taskHistory.mat'], 'matrixSequences');
            imgStruct=xls2Structs([fileDirectory 'imageList.xls']);
            if isfield(imgStruct,'showInMatrix');
                trialsID= cell2mat({imgStruct(find(cell2mat({imgStruct.showInMatrix}))).ID});
            else
                tmp={imgStruct.Stimulus};
                trialsID=cell2mat({imgStruct((1: find(strcmp(tmp,'+'))-1)).ID});
            end
            delete([fileDirectory 'imageList.xls']);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        disp('Calculating AUC...');
        initializeOfflineAnalysis
        
        [afterFrontendFilterData,afterFrontendFilterTrigger]=applyFrontendFilter(rawData,triggerSignal,frontendFilteringFlag,frontendFilter);
        clear rawData
        if exist('matrixSequences','var')
            
            [~,completedSequenceCount,trialSampleTimeIndices,trialTargetness,trialLabels]=triggerDecoder(afterFrontendFilterTrigger,triggerPartitioner,matrixSequences,trialsID);
        else
            [~,completedSequenceCount,trialSampleTimeIndices,trialTargetness,trialLabels]=triggerDecoder(afterFrontendFilterTrigger,triggerPartitioner);
        end
        %trialSampleTimeIndices=trialSampleTimeIndices+frontendFilter.groupDelay;
        clear triggerSignal
        
        wn=(0:(triggerPartitioner.windowLengthinSamples-1))';
        trialData=permute(reshape(afterFrontendFilterData(bsxfun(@plus,trialSampleTimeIndices,wn),:),[length(wn),length(trialSampleTimeIndices),size(afterFrontendFilterData,2)]),[1 3 2]);
        clear afterFrontendFilterData
        
        %         trialSampleTimeIndices=[trialSampleTimeIndices size(afterFrontendFilterTrigger,1)];
        
        %% Artifact Removal
        
        
        if RSVPKeyboardParams.artifactFiltering.enabled==1
            artifactFilteringParameters
            dataInBuffer=[];
            artifactFilteringParametersCalculation;
            
            [rejectedTrials,availableChannels] = artifactRemoval(dataInBuffer,...
                trialData,...
                fs,...
                artifactFilteringParams,...
                calibrationArtifactParameters,...
                RSVPKeyboardParams.artifactFiltering);
            
            trialData(:,:,rejectedTrials==1)=[];
            trialTargetness(rejectedTrials==1)=[];
            trialRejectionProbability=length(find(rejectedTrials==1))/length(rejectedTrials);
            
        else
            calibrationArtifactParameters=[];
            trialRejectionProbability=0;
        end
        
        
        %%
        tempTrialData=UnsupervisedProcessFlow.learn(trialData,trialTargetness);
        if RSVPKeyboardParams.formRecursiveProcessflow
            %             finalSupervisedProcessStruct=functionToOptimize(RSVPKeyboardParams.RecursiveSupervisedProccesses);
            %             featureExtractionProcessFlow=formProcessFlow(finalSupervisedProcessStruct,UnsupervisedProcessFlow);
            featureExtractionProcessFlow=formProcessFlow(RSVPKeyboardParams.RecursiveSupervisedProccesses,UnsupervisedProcessFlow);            
            featureExtractionProcessFlow.processList.Tail.Data.learn(tempTrialData,trialTargetness);
            featureExtractionProcessFlow.processList.Tail.Data.operate(tempTrialData);
            featureExtractionProcessFlow.processList.Tail.Data.operators.update([],trialTargetness);
            [recursiveUpdateObj, ~] = GetNodeHandle(featureExtractionProcessFlow,'ghm');
            scores=crossValidationObject.apply(featureExtractionProcessFlow,trialData,trialTargetness,recursiveUpdateObj,'ghm');
            [meanAuc,stdAuc]=calculateAuc(scores,trialTargetness,crossValidationObject.crossValidationPartitioning,crossValidationObject.K);            
        else
            switch RSVPKeyboardParams.SupervisedProccesses.optimizationMode
                % Defult values for parameters
                case 0
                    optimizedParameterValues=functionToOptimize(RSVPKeyboardParams.SupervisedProccesses);
                    % Using fmeansearch to find optimum parameters
                case 1
                    [prametersInitialValues xString]=functionToOptimize(RSVPKeyboardParams.SupervisedProccesses);
                    [optimizedParameterValues ~]=fminsearch(@(x) functionToOptimize(RSVPKeyboardParams.SupervisedProccesses,eval(xString),crossValidationObject,tempTrialData,trialTargetness),prametersInitialValues);
                    
                    % Using grid search to find the prameters
                case 2
                    [optimizedParameterValues,~] = gridSearch(RSVPKeyboardParams.SupervisedProccesses,crossValidationObject,tempTrialData,trialTargetness);
                    
            end
            
            display(optimizedParameterValues)
            finalSupervisedProcessStruct=functionToOptimize(RSVPKeyboardParams.SupervisedProccesses,optimizedParameterValues);
            featureExtractionProcessFlow=formProcessFlow(finalSupervisedProcessStruct,UnsupervisedProcessFlow);
            
            scores=crossValidationObject.apply(featureExtractionProcessFlow,trialData,trialTargetness);
            [meanAuc,stdAuc]=calculateAuc(scores,trialTargetness,crossValidationObject.crossValidationPartitioning,crossValidationObject.K);
            
            
            %%
            disp(['AUC calculation is completed. AUC is '  num2str(meanAuc) '.']);
            
            timeVector=wn/fs*1000;
            targetERPs=squeeze(mean(trialData(:,:,trialTargetness==1),3));
            nontargetERPs=squeeze(mean(trialData(:,:,trialTargetness==0),3));
            ymax=max(max(targetERPs(:)),max(nontargetERPs(:)))*1e6;
            ymin=min(min(targetERPs(:)),min(nontargetERPs(:)))*1e6;

            figure();
            subplot(2,1,1);
            plot(timeVector,nontargetERPs*1e6);
            xlabel('Time (ms)');
            ylabel('Magnitude (uV)');
            ylim([ymin ymax]);
            title('average-non-target');
            subplot(2,1,2);
            plot(timeVector,targetERPs*1e6);
            xlabel('Time (ms)');
            ylabel('Magnitude (uV)');
            ylim([ymin ymax]);
            title('average-target');
            
        end
        
        
        nontargetScores=scores(trialTargetness==0);
        targetScores=scores(trialTargetness==1);
        scoreStruct.conditionalpdf4targetKDE=kde1d(targetScores);
        scoreStruct.conditionalpdf4nontargetKDE=kde1d(nontargetScores);
        scoreStruct.probThresholdTarget=scoreThreshold(targetScores,scoreStruct.conditionalpdf4targetKDE.kernelWidth,0.99);
        scoreStruct.probThresholdNontarget=scoreThreshold(nontargetScores,scoreStruct.conditionalpdf4nontargetKDE.kernelWidth,0.99);
        scoreStruct.AUC=meanAuc;
        scoreStruct.trialRejectionProbability=trialRejectionProbability;
        
        if(calibrationEnabled)
            featureExtractionProcessFlow.learn(trialData,trialTargetness);
            calibrationDataStruct.trialData = trialData;
            calibrationDataStruct.trialTargetness = trialTargetness;
            if strfind(fileName,'FRP')
                evidenceType='FRP';
                save([sessionFolder '\calibrationFileFRP.mat'],'featureExtractionProcessFlow','scoreStruct','calibrationDataStruct','calibrationArtifactParameters','evidenceType');
            else
                evidenceType='ERP';
                save([sessionFolder '\calibrationFileERP.mat'],'featureExtractionProcessFlow','scoreStruct','calibrationDataStruct','calibrationArtifactParameters','evidenceType');   
            end

        else
            featureExtractionProcessFlow=[];
        end
        
    case 'mat'
        vars=whos('-file',[fileDirectory '\' fileName]);
        if ismember('isRawData', {vars.name})
            load([fileDirectory '\' fileName]);
            
            rawData=rawData;
            triggerSignal=triggerSignal;
            fs=sampleRate;
            channelNames=channelNames;
            filterInfo=filterInfo;
            daqInfos=daqInfos;
            sessionFolder=fileDirectory;
            
            disp('Data is loaded');
            
            % Additional variable loading for matrixSpeller.
            vars = whos('-file',[fileDirectory 'taskHistory.mat']);
           
            if ismember('matrixSequences', {vars.name})
                system(['unzip ' fileDirectory 'Parameters.zip imageList.xls -d ' fileDirectory]);
                load([fileDirectory 'taskHistory.mat'], 'matrixSequences');
                imgStruct=xls2Structs([fileDirectory 'imageList.xls']);
                if isfield(imgStruct,'showInMatrix');
                    trialsID= cell2mat({imgStruct(find(cell2mat({imgStruct.showInMatrix}))).ID});
                else
                    tmp={imgStruct.Stimulus};
                    trialsID=cell2mat({imgStruct((1: find(strcmp(tmp,'+'))-1)).ID});
                end
                delete([fileDirectory 'imageList.xls']);
            end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            disp('Calculating AUC...');
            initializeOfflineAnalysis
            
            [afterFrontendFilterData,afterFrontendFilterTrigger]=applyFrontendFilter(rawData,triggerSignal,frontendFilteringFlag,frontendFilter);
            clear rawData
            
            if exist('matrixSequences','var')
                
                [~,completedSequenceCount,trialSampleTimeIndices,trialTargetness,trialLabels]=triggerDecoder(afterFrontendFilterTrigger,triggerPartitioner,matrixSequences,trialsID);
            else
                [~,completedSequenceCount,trialSampleTimeIndices,trialTargetness,trialLabels]=triggerDecoder(afterFrontendFilterTrigger,triggerPartitioner);
            end
            %trialSampleTimeIndices=trialSampleTimeIndices+frontendFilter.groupDelay;
            clear triggerSignal
            
            wn=(0:(triggerPartitioner.windowLengthinSamples-1))';
            trialData=permute(reshape(afterFrontendFilterData(bsxfun(@plus,trialSampleTimeIndices,wn),:),[length(wn),length(trialSampleTimeIndices),size(afterFrontendFilterData,2)]),[1 3 2]);
            clear afterFrontendFilterData
            
            %         trialSampleTimeIndices=[trialSampleTimeIndices size(afterFrontendFilterTrigger,1)];
            
            %% Artifact Removal
            
            
            if RSVPKeyboardParams.artifactFiltering.enabled==1
                artifactFilteringParameters
                dataInBuffer=[];
                artifactFilteringParametersCalculation;
                
                [rejectedTrials,availableChannels] = artifactRemoval(dataInBuffer,...
                    trialData,...
                    fs,...
                    artifactFilteringParams,...
                    calibrationArtifactParameters,...
                    RSVPKeyboardParams.artifactFiltering);
                
                trialData(:,:,rejectedTrials==1)=[];
                trialTargetness(rejectedTrials==1)=[];
                trialRejectionProbability=length(find(rejectedTrials==1))/length(rejectedTrials);
                
            else
                calibrationArtifactParameters=[];
                trialRejectionProbability=0;
            end
            
            
            %%
            tempTrialData=UnsupervisedProcessFlow.learn(trialData,trialTargetness);
            
            switch RSVPKeyboardParams.SupervisedProccesses.optimizationMode
                % Defult values for parameters
                case 0
                    optimizedParameterValues=functionToOptimize(RSVPKeyboardParams.SupervisedProccesses);
                    % Using fmeansearch to find optimum parameters
                case 1
                    [prametersInitialValues xString]=functionToOptimize(RSVPKeyboardParams.SupervisedProccesses);
                    [optimizedParameterValues ~]=fminsearch(@(x) functionToOptimize(RSVPKeyboardParams.SupervisedProccesses,eval(xString),crossValidationObject,tempTrialData,trialTargetness),prametersInitialValues);
                    
                    % Using grid search to find the prameters
                case 2
                    [optimizedParameterValues,~] = gridSearch(RSVPKeyboardParams.SupervisedProccesses,crossValidationObject,tempTrialData,trialTargetness);
                    
            end
            
            display(optimizedParameterValues)
            finalSupervisedProcessStruct=functionToOptimize(RSVPKeyboardParams.SupervisedProccesses,optimizedParameterValues);
            featureExtractionProcessFlow=formProcessFlow( finalSupervisedProcessStruct,UnsupervisedProcessFlow );
            
            scores=crossValidationObject.apply(featureExtractionProcessFlow,trialData,trialTargetness);
            [meanAuc,stdAuc]=calculateAuc(scores,trialTargetness,crossValidationObject.crossValidationPartitioning,crossValidationObject.K);
            
            
            %%
            disp(['AUC calculation is completed. AUC is '  num2str(meanAuc) '.']);
            
            
            nontargetScores=scores(trialTargetness==0);
            targetScores=scores(trialTargetness==1);
            scoreStruct.conditionalpdf4targetKDE=kde1d(targetScores);
            scoreStruct.conditionalpdf4nontargetKDE=kde1d(nontargetScores);
            scoreStruct.probThresholdTarget=scoreThreshold(targetScores,scoreStruct.conditionalpdf4targetKDE.kernelWidth,0.99);
            scoreStruct.probThresholdNontarget=scoreThreshold(nontargetScores,scoreStruct.conditionalpdf4nontargetKDE.kernelWidth,0.99);
            scoreStruct.AUC=meanAuc;
            scoreStruct.trialRejectionProbability=trialRejectionProbability;
            
            if(calibrationEnabled)
                featureExtractionProcessFlow.learn(trialData,trialTargetness);
                calibrationDataStruct.trialData = trialData;
                calibrationDataStruct.trialTargetness = trialTargetness;
                if strfind(fileName,'FRP')
                evidenceType='FRP';
                save([sessionFolder '\calibrationFileFRP.mat'],'featureExtractionProcessFlow','scoreStruct','calibrationDataStruct','calibrationArtifactParameters','evidenceType');
                else
                evidenceType='ERP';
                save([sessionFolder '\calibrationFileERP.mat'],'featureExtractionProcessFlow','scoreStruct','calibrationDataStruct','calibrationArtifactParameters','evidenceType');    
                end
            else
                featureExtractionProcessFlow=[];
            end
            
        else
            load([fileDirectory '\' fileName],'scoreStruct');
            RSVPKeyboardParameters
            imageStructs = xls2Structs('imageList.xls');
            featureExtractionProcessFlow=[];
        end
end

% if(RSVPKeyboardParams.Simulation.Enabled)
%     simulationResults=simulateTypingPerformance(scoreStruct,imageStructs,'CopyPhraseTask',RSVPKeyboardParams);
%     statistics2display=calculateSimulationResultStatistics(simulationResults);
%     
%     if RSVPKeyboardParams.Simulation.ExportToExcel.Enabled
%         
%         if isempty(RSVPKeyboardParams.Simulation.ExportToExcel.Filename)
%             excelFileName = [fileDirectory 'simulationResults' datestr(now, 'yyyymmddHHMM') '.xls'];       
%         elseif isempty(RSVPKeyboardParams.Simulation.ExportToExcel.Folder)
%             excelFileName = [fileDirectory RSVPKeyboardParams.Simulation.ExportToExcel.Filename];       
%         else
%             excelFileName = [RSVPKeyboardParams.Simulation.ExportToExcel.Folder '\' RSVPKeyboardParams.Simulation.ExportToExcel.Filename]; 
%         end
%         
%         status = exportToExcel(excelFileName , ...
%             RSVPKeyboardParams.Simulation.HyperparameterNames, ...
%             RSVPKeyboardParams.Simulation.HyperparameterValues, statistics2display);
%         
%         if ~status
%             error('Failed to write Excel sheet');
%         end
%     end
%     
% else
%     simulationResults=[];
%     statistics2display=[];
% end

generateOfflineAnalysisScreen
%
% % saveas(offlineAnalysisScreenfig,[fileName fileDirectory], 'fig')
%                 close(offlineAnalysisScreenfig);



