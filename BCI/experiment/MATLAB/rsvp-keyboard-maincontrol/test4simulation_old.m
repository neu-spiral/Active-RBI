clear;
addpath(genpath('.'));

sessionType='CopyPhraseTask';
load('testCalibrationFile');
RSVPKeyboardParameters;
presentationParameters;
imageStructs=xls2Structs('imageList.xls');  %OK

%simulationResults=simulateTypingPerformance(scoreStruct,imageStructs,sessionType,RSVPKeyboardParams);
simulationResults=simulateTypingPerformance(imageStructs,sessionType,RSVPKeyboardParams,presentationStruct);