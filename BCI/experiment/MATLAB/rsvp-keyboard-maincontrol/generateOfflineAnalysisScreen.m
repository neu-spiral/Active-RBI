%% generateOfflineAnalysisScreen
% Generates the information figure following the offlineAnalysis. It can be enabled/disabled using
% RSVPKeyboardParams.OfflineAnalysisScreen.Enabled. The figure has multiple tabs containing the
% average ERP plots, simulation results.
%%

if(RSVPKeyboardParams.OfflineAnalysisScreen.Enabled )
    screenSize = get(0,'ScreenSize');
    horizontalMargin=15;
    verticalMargin=100;
    offlineAnalysisScreenfig=figure;
    set(offlineAnalysisScreenfig,'Name','Offline Analysis Screen');
    set(offlineAnalysisScreenfig,'Position',[horizontalMargin+1 verticalMargin+1 screenSize(3)-2*horizontalMargin screenSize(4)-2*verticalMargin]);
    
    hTabGroup=uitabgroup('Parent',offlineAnalysisScreenfig);
    
    if(RSVPKeyboardParams.OfflineAnalysisScreen.AverageERPPlotsEnabled && (strcmp(filetype,'daq')|| strcmp(filetype,'bin')))
        timeVector=wn/fs*1000;
        targetERPs=squeeze(mean(trialData(:,:,trialTargetness==1),3)); %for ERP evidence-P300; for FRP evidence-Correct
        nontargetERPs=squeeze(mean(trialData(:,:,trialTargetness==0),3));%for ERP evidence-noP300; for FRP evidence-Incorrect
        if strfind(fileName,'FRP')
        ERPPlotsTab=uitab(hTabGroup,'title','FRP Plots');
        else
        ERPPlotsTab=uitab(hTabGroup,'title','ERP Plots');
        end
        %        ERPPlotsPanelPosition=[0.01,0.01,0.48,0.98];
        % ERPPlotsPanel=uipanel(offlineAnalysisScreenfig,'Title','ERP Plots','BackgroundColor','white','Position',ERPPlotsPanelPosition);
        
        %targetERPAxes=axes(ERPPlotsPanel,'Position',[0,0,1,1]);
        ymax=max(max(targetERPs(:)),max(nontargetERPs(:)))*1e6;
        ymin=min(min(targetERPs(:)),min(nontargetERPs(:)))*1e6;
        
        subplot(2,1,1,'Parent',ERPPlotsTab);
        plot(timeVector,nontargetERPs*1e6);
        if strfind(fileName,'FRP')
        title('Mean negative FRP- (incorrect) (averaged over trials in the calibration data)');
        else
        title('Mean distractor ERP (averaged over trials in the calibration data)');
        end
        xlabel('Time (ms)');
        ylabel('Magnitude (uV)');
        ylim([ymin ymax]);
        subplot(2,1,2,'Parent',ERPPlotsTab);
        plot(timeVector,targetERPs*1e6);
        if strfind(fileName,'FRP')
        title('Mean positive FRP- (correct) (averaged over trials in the calibration data)');
        else
        title('Mean target ERP (averaged over trials in the calibration data)');
        end
        xlabel('Time (ms)');
        ylabel('Magnitude (uV)');
        ylim([ymin ymax]);
    end
    
%     if(RSVPKeyboardParams.Simulation.Enabled)
%         if(length(RSVPKeyboardParams.Simulation.HyperparameterNames)==1)
%             simulationResultsTab=uitab(hTabGroup,'title','Simulation Results');
%             simulationResultPanel1a=uipanel(simulationResultsTab,'title','Estimated Number of Sequences per Target Symbol','Position',[0.01,0.51,0.48,0.48]);
%             simulationResultPanel1b=uipanel(simulationResultsTab,'title','Estimated Task Duration (min)','Position',[0.51,0.51,0.98,0.48]);
%             simulationResultPanel2=uipanel(simulationResultsTab,'title','Estimated Probability of Phrase Completion','Position',[0.01,0.01,0.98,0.48]);
%             
%             dimensionIndices=1;
%             nameList=cell(1,length(dimensionIndices));
%             for(dimensionIndex=1:length(dimensionIndices))
%                 nameList{dimensionIndex}=cell(1,length(RSVPKeyboardParams.Simulation.HyperparameterValues{dimensionIndex}));
%                 hyperparameterName=RSVPKeyboardParams.Simulation.HyperparameterNames{dimensionIndex}(find(RSVPKeyboardParams.Simulation.HyperparameterNames{dimensionIndex}=='.',1,'last')+1:end);
%                 for(nameIndex=1:length(RSVPKeyboardParams.Simulation.HyperparameterValues{dimensionIndex}))
%                     nameList{dimensionIndex}{nameIndex}=[hyperparameterName ' = ' num2str(RSVPKeyboardParams.Simulation.HyperparameterValues{dimensionIndex}(nameIndex))];
%                 end
%             end
%             
%             uitable(simulationResultPanel1a,'Data',statistics2display.meanNumberOfSequencesPerTarget,'RowName',nameList{dimensionIndices(1)},'Units','Normalized','Position',[0.01,0.01,0.98,0.98]);
%             uitable(simulationResultPanel1b,'Data',statistics2display.meanTotalTypingDuration/60,'RowName',nameList{dimensionIndices(1)},'Units','Normalized','Position',[0.01,0.01,0.98,0.98]);
%             uitable(simulationResultPanel2,'Data',statistics2display.probabilityofSuccessfulPhraseCompletion,'RowName',nameList{dimensionIndices(1)},'Units','Normalized','Position',[0.01,0.01,0.98,0.98]);
%             
%             
%         elseif(length(RSVPKeyboardParams.Simulation.HyperparameterNames)==2)
%             simulationResultsTab=uitab(hTabGroup,'title','Simulation Results');
%             simulationResultPanel1a=uipanel(simulationResultsTab,'title','Estimated Number of Sequences per Target Symbol','Position',[0.01,0.51,0.48,0.48]);
%             simulationResultPanel1b=uipanel(simulationResultsTab,'title','Estimated Task Duration (min)','Position',[0.51,0.51,0.98,0.48]);
%             simulationResultPanel2=uipanel(simulationResultsTab,'title','Estimated Probability of Phrase Completion','Position',[0.01,0.01,0.98,0.48]);
%             
%             dimensionIndices=1:2;
%             nameList=cell(1,length(dimensionIndices));
%             for(dimensionIndex=1:length(dimensionIndices))
%                 nameList{dimensionIndex}=cell(1,length(RSVPKeyboardParams.Simulation.HyperparameterValues{dimensionIndex}));
%                 hyperparameterName=RSVPKeyboardParams.Simulation.HyperparameterNames{dimensionIndex}(find(RSVPKeyboardParams.Simulation.HyperparameterNames{dimensionIndex}=='.',1,'last')+1:end);
%                 for(nameIndex=1:length(RSVPKeyboardParams.Simulation.HyperparameterValues{dimensionIndex}))
%                     nameList{dimensionIndex}{nameIndex}=[hyperparameterName ' = ' num2str(RSVPKeyboardParams.Simulation.HyperparameterValues{dimensionIndex}(nameIndex))];
%                 end
%             end
%             
%             uitable(simulationResultPanel1a,'Data',statistics2display.meanNumberOfSequencesPerTarget,'RowName',nameList{dimensionIndices(1)},'ColumnName',nameList{dimensionIndices(2)},'Units','Normalized','Position',[0.01,0.01,0.98,0.98]);
%             uitable(simulationResultPanel1b,'Data',statistics2display.meanTotalTypingDuration/60,'RowName',nameList{dimensionIndices(1)},'ColumnName',nameList{dimensionIndices(2)},'Units','Normalized','Position',[0.01,0.01,0.98,0.98]);
%             uitable(simulationResultPanel2,'Data',statistics2display.probabilityofSuccessfulPhraseCompletion,'RowName',nameList{dimensionIndices(1)},'ColumnName',nameList{dimensionIndices(2)},'Units','Normalized','Position',[0.01,0.01,0.98,0.98]);
%             
%             
%         elseif(length(RSVPKeyboardParams.Simulation.HyperparameterNames)>2)
%             try,clear temp;catch,end
%             
%             [temp{1:length(RSVPKeyboardParams.Simulation.HyperparameterValues)-2}]=ndgrid(RSVPKeyboardParams.Simulation.HyperparameterValues{3:length(RSVPKeyboardParams.Simulation.HyperparameterValues)});
%             
%             simulationGridSearchExtraHyperparameters = reshape(cat(length(temp)+1,temp{:}),numel(temp{1}),length(RSVPKeyboardParams.Simulation.HyperparameterValues)-2);
%             
%             simulationGridSearchExtraHyperparameterIndices=zeros(size(simulationGridSearchExtraHyperparameters));
%             for(hyperparameterIndex=1:size(simulationGridSearchExtraHyperparameterIndices,2))
%                 [~,simulationGridSearchExtraHyperparameterIndices(:,hyperparameterIndex)]=ismember(simulationGridSearchExtraHyperparameters(:,hyperparameterIndex),RSVPKeyboardParams.Simulation.HyperparameterValues{hyperparameterIndex+2});
%             end
%             
%             for(extraHyperparameterSetIndex=1:size(simulationGridSearchExtraHyperparameters,1))
%                 titleofTab='';
%                 for(hyperparameterIndex=1:size(simulationGridSearchExtraHyperparameters,2))
%                     hyperparameterName=RSVPKeyboardParams.Simulation.HyperparameterNames{2+hyperparameterIndex}(find(RSVPKeyboardParams.Simulation.HyperparameterNames{2+hyperparameterIndex}=='.',1,'last')+1:end);
%                     
%                     titleofTab=[titleofTab hyperparameterName '=' num2str(RSVPKeyboardParams.Simulation.HyperparameterValues{2+hyperparameterIndex}(simulationGridSearchExtraHyperparameterIndices(extraHyperparameterSetIndex,hyperparameterIndex))) ', '];
%                 end
%                 
%                 simulationResultsTab=uitab(hTabGroup,'title',titleofTab);
%                 
%                 simulationResultPanel1a=uipanel(simulationResultsTab,'title','Estimated Number of Sequences per Target Symbol','Position',[0.01,0.51,0.48,0.48]);
%                 simulationResultPanel1b=uipanel(simulationResultsTab,'title','Estimated Task Duration (min)','Position',[0.51,0.51,0.98,0.48]);
%                 simulationResultPanel2=uipanel(simulationResultsTab,'title','Estimated Probability of Phrase Completion','Position',[0.01,0.01,0.98,0.48]);
%                 
%                 
%                 
%                 dimensionIndices=1:2;
%                 nameList=cell(1,length(dimensionIndices));
%                 for(dimensionIndex=1:length(dimensionIndices))
%                     nameList{dimensionIndex}=cell(1,length(RSVPKeyboardParams.Simulation.HyperparameterValues{dimensionIndex}));
%                     hyperparameterName=RSVPKeyboardParams.Simulation.HyperparameterNames{dimensionIndex}(find(RSVPKeyboardParams.Simulation.HyperparameterNames{dimensionIndex}=='.',1,'last')+1:end);
%                     for(nameIndex=1:length(RSVPKeyboardParams.Simulation.HyperparameterValues{dimensionIndex}))
%                         nameList{dimensionIndex}{nameIndex}=[hyperparameterName ' = ' num2str(RSVPKeyboardParams.Simulation.HyperparameterValues{dimensionIndex}(nameIndex))];
%                     end
%                 end
%                 
% %                 cellstatistics2display.meanNumberOfSequencesPerTarget=num2cell(statistics2display.meanNumberOfSequencesPerTarget);
% %                 cellstatistics2display.probabilityofSuccessfulPhraseCompletion=num2cell(statistics2display.probabilityofSuccessfulPhraseCompletion);
% %                 currentStatistics2Display.meanNumberOfSequencesPerTarget=zeros(size(statistics2display.meanNumberOfSequencesPerTarget,1),size(statistics2display.meanNumberOfSequencesPerTarget,2));
% %                 currentStatistics2Display.probabilityofSuccessfulPhraseCompletion=currentStatistics2Display.meanNumberOfSequencesPerTarget;
% %                 for(rowIndex=1:size(statistics2display.meanNumberOfSequencesPerTarget,1))
% %                     for(columnIndex=1:size(statistics2display.meanNumberOfSequencesPerTarget,2))
% %                         currentStatistics2Display.meanNumberOfSequencesPerTarget(rowIndex,columnIndex)=cellstatistics2display.meanNumberOfSequencesPerTarget({num2cell[rowIndex,columnIndex,simulationGridSearchExtraHyperparameterIndices(extraHyperparameterSetIndex,:)]});
% %                         currentStatistics2Display.probabilityofSuccessfulPhraseCompletion(rowIndex,columnIndex)=cellstatistics2display.probabilityofSuccessfulPhraseCompletion{[rowIndex,columnIndex,simulationGridSearchExtraHyperparameterIndices(extraHyperparameterSetIndex,:)]};
% % 
% %                     end
% %                 end
%                 
%                 indexingCell=cat(2,{1:length(RSVPKeyboardParams.Simulation.HyperparameterValues{dimensionIndices(1)})},{1:length(RSVPKeyboardParams.Simulation.HyperparameterValues{dimensionIndices(2)})}, num2cell(simulationGridSearchExtraHyperparameterIndices(extraHyperparameterSetIndex,:)));
%                 uitable(simulationResultPanel1a,'Data',statistics2display.meanNumberOfSequencesPerTarget(indexingCell{:}),'RowName',nameList{dimensionIndices(1)},'ColumnName',nameList{dimensionIndices(2)},'Units','Normalized','Position',[0.01,0.01,0.98,0.98]);
%                 uitable(simulationResultPanel1b,'Data',statistics2display.meanTotalTypingDuration(indexingCell{:})/60,'RowName',nameList{dimensionIndices(1)},'ColumnName',nameList{dimensionIndices(2)},'Units','Normalized','Position',[0.01,0.01,0.98,0.98]);
%                 
%                 uitable(simulationResultPanel2,'Data',statistics2display.probabilityofSuccessfulPhraseCompletion(indexingCell{:}),'RowName',nameList{dimensionIndices(1)},'ColumnName',nameList{dimensionIndices(2)},'Units','Normalized','Position',[0.01,0.01,0.98,0.98]);
%                 
%                 
%                 
%                 
%                 
%             end
%             
%         end
%     end
    
    
end