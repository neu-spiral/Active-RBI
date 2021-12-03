clc,
close all,
clear,

mainPath = fileparts(fileparts(fileparts(...
    which('offlineAnalysis_allConditions_allSubjects.m'))));

addpath(genpath(fullfile(mainPath, './Data')));
fileLists = dir([mainPath,'\Data']);
format = '.csv';

nFile_rand = 0;
nFile_momen = 0;
nFile_mmi = 0;
nFile_mmim = 0;

for nFile = 51:length(fileLists)
    
    close all;
    idx_underScore = strfind(fileLists(nFile).name,'_');
    
    if ~isempty(idx_underScore)
        ID = fileLists(nFile).name(idx_underScore(2)+1:idx_underScore(3)-1);
        idx_calibFile = find(~cellfun(@isempty,strfind({fileLists.name}, ...
            [ID,'_IRB130107_ERPCalibration_'])));
    else
        continue;
    end
    
        
    dataDirectory = fullfile([mainPath,'\Data'], fileLists(nFile).name);
    dataDirectory = [dataDirectory,'\'];
    calibFileDirectory = [[mainPath,'\Data\'], fileLists(idx_calibFile).name, '\'];
    disp(['File name: ',fileLists(nFile).name])
    disp(['Calib. File name: ',fileLists(idx_calibFile).name])
    
    if strfind(fileLists(nFile).name, '_Random_') > 0
        nFile_rand = nFile_rand + 1; 
       file_name = [strrep(fileLists(nFile).name,'Random_',''), format];
       [random(nFile_rand).ITR, random(nFile_rand).speed, ...
           random(nFile_rand).classPerformance,random(nFile_rand).seq_phrase, ...
           random(nFile_rand).seq_letter, random(nFile_rand).p_phraseComp,...
           random(nFile_rand).numCompPhrase] = ...
       offlineAnalysis_copyphrase(mainPath, dataDirectory, file_name, ...
       calibFileDirectory);
    end
    
    if strfind(fileLists(nFile).name, '_Momentum_') > 0
        nFile_momen = nFile_momen + 1; 
        file_name = [strrep(fileLists(nFile).name,'Momentum_',''), format];
        [momentum(nFile_momen).ITR, momentum(nFile_momen).speed, ...
            momentum(nFile_momen).classPerformance, momentum(nFile_momen).seq_phrase, ...
            momentum(nFile_momen).seq_letter, momentum(nFile_momen).p_phraseComp,...
            momentum(nFile_momen).numCompPhrase] = ...
       offlineAnalysis_copyphrase(mainPath, dataDirectory, file_name, ...
       calibFileDirectory);
    end

    if strfind(fileLists(nFile).name, '_MMI_') > 0
        nFile_mmi = nFile_mmi + 1; 
        file_name = [strrep(fileLists(nFile).name,'MMI_',''), format];
        [mmi(nFile_mmi).ITR, mmi(nFile_mmi).speed, mmi(nFile_mmi).classPerformance, ...
            mmi(nFile_mmi).seq_phrase, mmi(nFile_mmi).seq_letter, ...
            mmi(nFile_mmi).p_phraseComp, mmi(nFile_mmi).numCompPhrase] = ...
       offlineAnalysis_copyphrase(mainPath, dataDirectory, file_name, ...
       calibFileDirectory);
    end

    if strfind(fileLists(nFile).name, '_MMIM_') > 0
       nFile_mmim = nFile_mmim + 1; 
       file_name = [strrep(fileLists(nFile).name,'MMIM_',''), format];
       [mmim(nFile_mmim).ITR, mmim(nFile_mmim).speed, mmim(nFile_mmim).classPerformance, ...
           mmim(nFile_mmim).seq_phrase, mmim(nFile_mmim).seq_letter, ...
           mmim(nFile_mmim).p_phraseComp, mmim(nFile_mmim).numCompPhrase] = ...
       offlineAnalysis_copyphrase(mainPath, dataDirectory, file_name, ...
       calibFileDirectory);
    end

end
%%
load('results_copyphrase_4.mat')
nUsers = size(mmim,2);

for u = 1:nUsers
    aucs_claib(u) = mmim(u).classPerformance(1);
    aucs_cp(u) = mean([random(u).classPerformance(2), ...
        momentum(u).classPerformance(2), mmi(u).classPerformance(2), ...
        mmim(u).classPerformance(2)]);
    acc_cp(u) = mean([random(u).classPerformance(3), ...
        momentum(u).classPerformance(3), mmi(u).classPerformance(2), ...
        mmim(u).classPerformance(3)]);
    for num = 1:3
        ITR(num,u,:) = [random(u).ITR(num), momentum(u).ITR(num), mmi(u).ITR(num), mmim(u).ITR(num)];
    end
end
%
ITR(isnan(ITR)) = 0;
[aucs, user_indx] = sort(aucs_claib,'descend');
color = {[220/255, 0, 0],'k',[0,0.6,0],[0,.5,1]};
% measure = [aucs_claib; aucs_cp; acc_cp];
for j = 2:2
    figure();
    subplot(211);
    barplot = bar(squeeze(ITR(j,user_indx,:)),0.7);
    for i = 1:4
        barplot(i).EdgeColor = color{i};
        barplot(i).FaceColor = color{i};
    end
    xlabel('Calibration AUC','fontsize',12)
    ylabel([{'ITR'},{'(bits/sequence)'}],'fontsize',12)
    legend('Random','Momentum','MMI','Proposed')
    legend boxoff
    set(gca,'XTickLabel',sprintfc('%.02f',aucs), 'FontSize', 10);
    box off
end
%%
load('results_copyphrase_4.mat')
nUsers = size(mmim,2);

for u = 1:nUsers
    aucs_claib(u) = mmim(u).classPerformance(1);
    aucs_cp(u) = mean([random(u).classPerformance(2), ...
        momentum(u).classPerformance(2), mmi(u).classPerformance(2), ...
        mmim(u).classPerformance(2)]);
    acc_cp(u) = mean([random(u).classPerformance(3), ...
        momentum(u).classPerformance(3), mmi(u).classPerformance(3), ...
        mmim(u).classPerformance(3)]);
    for num = 1:3
        ITR(num,u,:) = [random(u).ITR(num), momentum(u).ITR(num), mmi(u).ITR(num), mmim(u).ITR(num)];
    end
end
%
ITR(isnan(ITR)) = 0;
[aucs, user_indx] = sort(aucs_claib,'descend');
color = {[220/255, 0, 0],'k',[0,0.6,0],[0,.5,1]};
userID = sprintfc('%d',user_indx);
AUCs = sprintfc('%.02f',aucs);
x_label = cellfun(@(x,y)['U',x,':',y],userID,AUCs,'uni',false);
% measure = [aucs_claib; aucs_cp; acc_cp];
for j = 2:2
    figure();
    subplot(211);
    barplot = bar(squeeze(ITR(j,user_indx,:)),0.55);
    for i = 1:4
        barplot(i).EdgeColor = color{i};
        barplot(i).FaceColor = color{i};
    end
    x_labelGHz = cellfun(@(c)['U',c,':'],userID,'uni',false)
    set(gca,'XTickLabel',x_label,'FontSize', 9);
    box off
    xlabel('Calibration AUC','fontsize',11)
    ylabel([{'ITR'},{'(bits/sequence)'}],'fontsize',11)
    legend('Random','Momentum','MMI','Proposed')
    legend boxoff
end

