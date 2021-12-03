%% Constructing likelihood evaluation function handles for each evidence.
if(exist('sessionID','var')) && sessionID==1
    nonERPInd=find(strcmp(RSVPKeyboardParams.evidenceEval.evidences,'FRP'));
    
    %RSVPKeyboardParams.evidenceEval.evidences(~ERPInds)=[];
    RSVPKeyboardParams.evidenceEval.priorities(RSVPKeyboardParams.evidenceEval.priorities>=nonERPInd)=RSVPKeyboardParams.evidenceEval.priorities(RSVPKeyboardParams.evidenceEval.priorities>=nonERPInd)-nonERPInd;
    RSVPKeyboardParams.evidenceEval.priorities(RSVPKeyboardParams.evidenceEval.priorities==0)=[];
    % Setting LikelihoodEvalFunctions values
    if isfield(RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions,'Names') && length(RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.Names)>=nonERPInd
        RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.Names(nonERPInd)=[];
    end
    if isfield(RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions,'params') && length(RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params)>=nonERPInd
        RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params(nonERPInd)=[];
    end
    % Setting nextTrialFunctions values
    if isfield(RSVPKeyboardParams.evidenceEval.nextTrialFunctions,'Names') && length(RSVPKeyboardParams.evidenceEval.nextTrialFunctions.Names)>=nonERPInd
        RSVPKeyboardParams.evidenceEval.nextTrialFunctions.Names(nonERPInd)=[];
    end
    if isfield(RSVPKeyboardParams.evidenceEval.nextTrialFunctions,'params') && length(RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params)>=nonERPInd
        RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params(nonERPInd)=[];
    end
    RSVPKeyboardParams.evidenceEval.evidences(nonERPInd)=[];
end

%% Setting parameters for each evidence
for i=1:length(RSVPKeyboardParams.evidenceEval.evidences)
    switch  RSVPKeyboardParams.evidenceEval.evidences{i}
        case 'ERP'
            if(sessionID~=1) 
                if (sessionID==6) && ~RSVPKeyboardParams.loadRecursiveCalibrationFile
                    sessionFolder = '.\Parameters';
                    machineCalibrationFile = 'RecursiveCalibrationInitialClassifierInit.mat';
                else                    
                    [machineCalibrationFile,sessionFolder]=uigetfile('*.mat','Please Select the Calibration File','MultiSelect', 'off','Data\');                    
                end
                load([sessionFolder '\' machineCalibrationFile]);
                processingStruct.featureExtraction.ERP.Flow=featureExtractionProcessFlow;

            else
                calibrationDataStruct = [];
                calibrationArtifactParameters=[];
                scoreStruct=[];
            end
          
         RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{i}.scoreStruct=scoreStruct;
         RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{i}.isMatrix=RSVPKeyboardParams.matrixSpellerMode;
         RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{i}.matrixSpellerMode=RSVPKeyboardParams.matrixSpellerMode;
         RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{i}.matrixPresentationParadigm=RSVPKeyboardParams.matrixPresentationParadigm;
         RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{i}.matrixSize=RSVPKeyboardParams.matrixSize;
         RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{i}.symbolStructArray=imageStructs;
         if(exist('sessionID','var'))
             RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{i}.sessionID=sessionID;
             if sessionID==2
                 RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{i}.Typing.MaximumNumberofSequences=RSVPKeyboardParams.CalibrationFRP.maxNumberOfSequences;
             end
             if (sessionID ~=1 && sessionID ~=6)
                 RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{i}.isCalibration=0;
                 RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{i}.isCalibration=0;
             else
                 RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{i}.isCalibration=1;
                 RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{i}.isCalibration=1;
             end
         end
         
         RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{i}.typeID=i;
        %For typing cases using ERP
        
        case 'FRP'
            
            if(sessionID~=2) && (sessionID~=1)%If session is not calibration FRP 
                [machineCalibrationFile,sessionFolder]=uigetfile('*.mat','Please Select the Calibration File FRP','MultiSelect', 'off','Data\');
                load([sessionFolder '\calibrationFileFRP.mat']);
                processingStruct.featureExtraction.FRP.Flow=featureExtractionProcessFlow;
                if(RSVPKeyboardParams.matrixSpellerMode)
                    scoreStruct.isMatrix=1;
                else
                    scoreStruct.isMatrix=0;
                end
             else
                calibrationDataStructErrP = [];
                calibrationArtifactParametersErrP=[];
            end
            
        RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{i}.scoreStruct=scoreStruct;
        RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{i}.typeID=i;
        RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{i}.isMatrix=RSVPKeyboardParams.matrixSpellerMode;
        %For typing cases using FRP
        if((exist('sessionID','var')) && sessionID ~=2)
             RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{i}.isCalibration=0;
        else
            RSVPKeyboardParams.evidenceEval.nextTrialFunctions.params{i}.Typing.AllowAsFirstSequence=0;
             RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.params{i}.isCalibration=1;
        end
        
        
    end

    RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.Handle{i}=str2func(RSVPKeyboardParams.evidenceEval.likelihoodEvalFunctions.Names{i});

end


%% Constructing addTrials function handles.

for i=1:length(RSVPKeyboardParams.evidenceEval.evidences)

    RSVPKeyboardParams.evidenceEval.nextTrialFunctions.Handle{i}=str2func(RSVPKeyboardParams.evidenceEval.nextTrialFunctions.Names{i});

end
