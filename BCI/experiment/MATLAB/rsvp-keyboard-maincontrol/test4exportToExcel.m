%% Test exportToExcel routine
clear

%% Testing mode 1 of the exportToExcel function
fprintf('Testing mode 1:\n');

fileName = 'test4exportToExcel.xls';
if exist(fileName,'file')
    delete(fileName);
end

% Creat test vectors, structs and cells to export to excel
nValues = 10;

paramaterNames = {'Param 1', 'Param 2'};
parameterValues{1} = linspace(0,1,nValues);
parameterValues{2} = linspace(10,20,nValues);

functionData.field1 = parameterValues{1} + parameterValues{2};
functionData.field2 = parameterValues{1} .* parameterValues{2};
functionData.field3 = parameterValues{1} - parameterValues{2};

% Try to launch function
try
    fprintf('\tTest 0: Function launch \t..........\t');
    exportToExcel(fileName, paramaterNames, parameterValues, functionData);
catch exception
    fprintf('Failed\n')
    error(exception.message);
end

fprintf('Passed!\n');

% First test: check if file was created
fprintf('\tTest 1: File existence \t..........\t');
if exist(fileName,'file')
    fprintf('Passed!\n');
    
    fprintf('\tTest 2: Comparing data \t..........\t');
    sheetNames = fieldnames(functionData);
    
    nSheets = numel(sheetNames);
    
    for idxSheet = 1:nSheets
    	[dataFromExcel,~,~] = xlsread(fileName, sheetNames{idxSheet});
        
        trueData = [reshape(cell2mat(parameterValues), nValues, []) functionData.(sheetNames{idxSheet})(:)];
        if any(trueData(:)~=dataFromExcel(:))
             fprintf('Failed!\n');
             error('Data from Excel is not the same as ground truth');
        end        
    end
    
    fprintf('Passed!\n');
    
    delete(fileName);
else
    fprintf('Failed: ');
    fprintf('No xls created');
end

%% testing mode 1 of the exportToExcel function
fprintf('Testing mode 2:\n');
fileName = 'test4exportToExcel.xls';

if exist(fileName,'file')
    delete(fileName);
end

RSVPKeyboardParams.Simulation.HyperparameterNames = {'Typing.MaximumNumberofSequences', 'languageModelWrapper.fixedProbability.DeleteCharacter', 'Typing.NumberofTrials', 'Typing.ConfidenceThreshold'};
RSVPKeyboardParams.Simulation.HyperparameterValues = {[4 5], [0.01 0.02], [10 12], [0.9 0.8]};

nValues = cellfun(@numel, RSVPKeyboardParams.Simulation.HyperparameterValues);

statistics2display.probabilityofSuccessfulPhraseCompletion = reshape(1:prod(nValues), nValues);
statistics2display.meanTotalTypingDuration = reshape(1:prod(nValues), nValues);
statistics2display.stdTotalTypingDuration = reshape(1:prod(nValues), nValues);
statistics2display.meanNumberOfSequencesPerTarget = reshape(1:prod(nValues), nValues);
statistics2display.stdNumberOfSequencesPerTarget = reshape(1:prod(nValues), nValues);

% Try to launch function
try
    fprintf('\tTest 0: Function launch \t..........\t');
    exportToExcel(fileName, RSVPKeyboardParams.Simulation.HyperparameterNames, RSVPKeyboardParams.Simulation.HyperparameterValues, statistics2display);
catch exception
    fprintf('Failed\n')
    error(exception.message);
end

fprintf('Passed!\n');

% First test: check if file was created
fprintf('\tTest 1: File existence \t..........\t');
if exist(fileName,'file')
    fprintf('Passed!\n');
    
    fprintf('\tTest 2: Comparing data \t..........\t');
    sheetNames = fieldnames(statistics2display);
    
    parameterValueGrid = permuteVectors(RSVPKeyboardParams.Simulation.HyperparameterValues);
    
    nSheets = numel(sheetNames);
    
    for idxSheet = 1:nSheets
    	[dataFromExcel,~,~] = xlsread(fileName, sheetNames{idxSheet}( max(end-30,1) : end ));

        trueData = [parameterValueGrid statistics2display.(sheetNames{idxSheet})(:)];
        if any(trueData(:)~=dataFromExcel(:))
             fprintf('Failed!\n');
             error('Data from Excel is not the same as ground truth');
        end        
    end
    
    fprintf('Passed!\n');
    
    delete(fileName);
else
    fprintf('Failed: ');
    fprintf('No xls created');
end


