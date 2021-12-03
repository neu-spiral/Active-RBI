function [ITR, speed, performance, seq_phrase, seq_letter, prob_phrase, numCompPhrase] = offlineAnalysis_copyphrase(rsvp_keyboard_path, fileDirectory, fileName, calibFileDirectory)

% Number of the trials in a sequence predefined in the userParameters
numTrials = 5;
% Total number of characters in the language model
numChar = 28;

imageStructs = xls_to_struct([rsvp_keyboard_path, '\Parameters\imageList.xls']);

BCIframeworkDir = rsvp_keyboard_path;
addpath(genpath(rsvp_keyboard_path));

% [fileName2,fileDirectory2] = uigetfile({'*.csv','Raw data (.csv)';'*.bin','Raw data (.bin)';'*.daq','Raw data (.daq)';'*.mat','Preprocessed Data (.mat)'},'Please select the file to be used in offline analysis','MultiSelect', 'on','..\..\Data');

task_history = strcat(fileDirectory,'\taskHistory.mat');
load(task_history,'-mat')

% Classification related offline analysis

[rawData,triggerSignal,fs,channelNames,filterInfo,daqInfos,sessionFolder]=loadSessionDataBin('daqFileName',[fileDirectory fileName],'sessionFolder', fileDirectory);
initializeOfflineAnalysis
[afterFrontendFilterData,afterFrontendFilterTrigger]=applyFrontendFilter(rawData,triggerSignal,frontendFilteringFlag,frontendFilter);
[~,completedSequenceCount,trialSampleTimeIndices,trialTargetness,trialLabels]=triggerDecoder_M(afterFrontendFilterTrigger,triggerPartitioner, imageStructs, sessionInfo);
wn=(0:(triggerPartitioner.windowLengthinSamples-1))';
trialData=permute(reshape(afterFrontendFilterData(bsxfun(@plus,trialSampleTimeIndices,wn),:),[length(wn),length(trialSampleTimeIndices),size(afterFrontendFilterData,2)]),[1 3 2]);

num_seq = 0;

for idx = 1 : length(sessionInfo.taskHistory)
    for idx_epoch = 1 : length(sessionInfo.taskHistory{1,idx}.epochList)
        num_seq = num_seq + length(sessionInfo.taskHistory{1,idx}.epochList{idx_epoch}.sequenceHistory);
    end
end

sessionID = 2;
RSVPKeyboardParameters

% Load Calibration File
machineCalibrationFile = 'calibrationFileERP.mat';
sessionFolder = calibFileDirectory;
initialize_model
AUC_calib = scoreStruct.AUC;

scores=crossValidationObject.apply(featureExtractionProcessFlow,trialData,trialTargetness);

neg_kde_calibration = scoreStruct.conditionalpdf4nontargetKDE;
pos_kde_calibration = scoreStruct.conditionalpdf4targetKDE;
neg_kde_copy_phrase = kde1d(scores(trialTargetness==0));
pos_kde_copy_phrase = kde1d(scores(trialTargetness==1));

x_linspace = min(scores):(max(scores)-min(scores))/1000:max(scores);

prob_calib_neg = neg_kde_calibration.probs(x_linspace);
prob_calib_pos = pos_kde_calibration.probs(x_linspace);
prob_copy_phrase_neg = neg_kde_copy_phrase.probs(x_linspace);
prob_copy_phrase_pos = pos_kde_copy_phrase.probs(x_linspace);
y_max = max([max(prob_calib_neg),max(prob_calib_pos),max(prob_copy_phrase_neg),max(prob_copy_phrase_pos)]);

figure();
subplot(2,1,1);
plot(x_linspace,prob_calib_neg,'r','LineWidth',2)
hold();
plot(x_linspace,prob_calib_pos,'b','LineWidth',2)
legend('negative','positive')
xlabel('score');
ylabel('p(score)');
ylim([0 y_max]);
xlim([min(x_linspace) max(x_linspace)])
title('calibration scores');
subplot(2,1,2);
plot(x_linspace,prob_copy_phrase_neg,'r','LineWidth',2)
hold();
plot(x_linspace,prob_copy_phrase_pos,'b','LineWidth',2)
legend('negative','positive')
xlabel('score');
ylabel('p(score)');
ylim([0 y_max]);
xlim([min(x_linspace) max(x_linspace)])
title('copy phrase scores');

[AUC_copyphrase,stdAuc]=calculateAuc(scores,trialTargetness,crossValidationObject.crossValidationPartitioning,crossValidationObject.K);
disp(strcat('AUC mean:',num2str(AUC_copyphrase),' - ','var:',num2str(stdAuc)))

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

%Typing related offline analysis
letter_session = [];
session_seq = [];

incorrect_selection = 0;
correct_selection = 0;
sentence_completion = false(1, length(sessionInfo.taskHistory));
meanNumSeq_phrase = zeros(1, length(sessionInfo.taskHistory));
varNumSeq_phrase = zeros(1, length(sessionInfo.taskHistory));
stdNumSeq_phrase = zeros(1, length(sessionInfo.taskHistory));
nSeq = 0;
numCorrect = 0;
numTotal = 0;
true_idx = 0;
max_post = [];
max_prior = [];

for idx = 1 : length(sessionInfo.taskHistory)
    
    % state is what the user typed so far.
    % Initial state of Copy Phrase is predefined. Assign the information to state.
    state = sessionInfo.taskHistory{1,idx}.preTarget;
    
    aim = strcat(sessionInfo.taskHistory{1,idx}.preTarget,sessionInfo.taskHistory{1,idx}.target);
    letter_session = [letter_session,sessionInfo.taskHistory{1,idx}.target];
    letter_seq_vec = zeros(1,length(sessionInfo.taskHistory{1,idx}.target));
    letter_seq_idx = 1;
    correct_flag = 0;
    
    % Hower over all epochs
    phrase_history = [];
    letter_history = [];
    correct_session_seq = [];
    m = 1;
    for idx_epoch = 1 : length(sessionInfo.taskHistory{1,idx}.epochList)
              
        % Chosen letter for the epoch
        update_state = imageStructs(sessionInfo.taskHistory{1,idx}.epochList{idx_epoch}.decided).Name;
        
        if strcmp(update_state, 'DeleteCharacter')
            phrase_history(idx_epoch) = '<';
            letter_history = [letter_history, '<'];
        elseif strcmp(update_state, 'Space')
            phrase_history(idx_epoch) = '_';
            letter_history = [letter_history, '_'];
        else
            phrase_history(idx_epoch) = update_state;
            letter_history = [letter_history, update_state];
        end
        
        % If '<' remove final letter, if '_' insert '-', else insert the
        % update parameter to the state
        
        if strcmp(update_state, 'DeleteCharacter')
            state = state(1:end-1);
        elseif strcmp(update_state, 'Space')
            state = strcat(state,'_');
        else
            state = strcat(state,update_state);
        end
        
        if length(aim) >= length(state)
            if strcmp(aim(1:length(state)),state)
                
                if ~strcmp(update_state, 'DeleteCharacter')
                    letter_seq_vec(letter_seq_idx) = letter_seq_vec(letter_seq_idx) + length(sessionInfo.taskHistory{1,idx}.epochList{idx_epoch}.sequenceHistory);
                    letter_seq_idx = letter_seq_idx + 1;
                    prob_letter{idx}(m) = 1/length(letter_history);
                    m = m + 1;
                    letter_history = [];
                    
                elseif correct_flag == 1
                    letter_seq_idx = letter_seq_idx - 1;
                    letter_seq_vec(letter_seq_idx) = letter_seq_vec(letter_seq_idx) + length(sessionInfo.taskHistory{1,idx}.epochList{idx_epoch}.sequenceHistory);
                end
                
                max_post = [max_post max(sessionInfo.taskHistory{idx}.epochList{idx_epoch}.posteriorProbs)];
                max_prior = [max_prior sessionInfo.taskHistory{idx}.epochList{idx_epoch}.LMprobs(sessionInfo.taskHistory{idx}.epochList{idx_epoch}.decided)]; 
                correct_selection = correct_selection + 1;
                correct_flag = 1;
            
            else
                if strcmp(update_state, 'DeleteCharacter')
                    max_post = [max_post max(sessionInfo.taskHistory{idx}.epochList{idx_epoch}.posteriorProbs)];
                    max_prior = [max_prior sessionInfo.taskHistory{idx}.epochList{idx_epoch}.LMprobs(sessionInfo.taskHistory{idx}.epochList{idx_epoch}.decided)];
                    correct_selection = correct_selection + 1;
                else
                    incorrect_selection = incorrect_selection + 1;
                end
            letter_seq_vec(letter_seq_idx) = letter_seq_vec(letter_seq_idx) + length(sessionInfo.taskHistory{1,idx}.epochList{idx_epoch}.sequenceHistory);
            correct_flag = 0;
            end
        end
        
    end
    
    phrase_history = char(phrase_history);
    targetPhrase = sessionInfo.taskHistory{1,idx}.target;
    prob_phrase(idx) = length(targetPhrase)/length(phrase_history);
    numCorrectType(idx) = length(targetPhrase);
    numTotalType(idx) = length(phrase_history);
    
    if strcmp(aim, state)
        true_idx = true_idx + 1;
        sentence_completion(idx) = true;
        meanNumSeq_phrase(true_idx) = mean(letter_seq_vec);
        varNumSeq_phrase(true_idx) = var(letter_seq_vec);
        stdNumSeq_phrase(true_idx) = std(letter_seq_vec);
        nSeq(true_idx) = sum(letter_seq_vec);
        correct_session_seq = [correct_session_seq, nSeq(true_idx)];
        numCorrect = numCorrect + numCorrectType(idx);
        numTotal = numTotal + numTotalType(idx);
    end
    
    numSeq(idx) = sum(letter_seq_vec);
    session_seq = [session_seq, letter_seq_vec];
end

for idx = 1: length(letter_session)
    letter_session_cell{idx} = letter_session(idx);
end

speed(1) = 1/(mean(nSeq));
speed(2) = 1/(mean(session_seq));

p = numCorrect/numTotal; 
ACC = correct_selection/(correct_selection+incorrect_selection);

if ACC == 1
    ACC = ACC - 0.01;
end

ITR(1) = (log2(numChar) + p*log2(p) + (1-p)*log2((1-p)/(numChar - 1)))*speed(1);
ITR(2) = (log2(numChar) + ACC*log2(ACC) + (1-ACC)*log2((1-ACC)/(numChar - 1)))*speed(2);
info_gain = sum(max_post.*log(max_post./max_prior));
ITR(3) = info_gain/sum(session_seq);

seq_phrase = [sum(nSeq), mean(correct_session_seq), std(correct_session_seq)];
seq_letter = [sum(numSeq), mean(session_seq), std(session_seq)];
performance = [AUC_calib, AUC_copyphrase, ACC, p];
numCompPhrase = true_idx;

figure
subplot(2,1,1)
bar(session_seq)
ylabel('# Sequence')
xlabel('Letters')
set(gca, 'XTick', 1:length(session_seq))
set(gca, 'XTickLabel', letter_session_cell)

disp(strcat('Accuracy in session:',num2str(correct_selection/(correct_selection+incorrect_selection))))

