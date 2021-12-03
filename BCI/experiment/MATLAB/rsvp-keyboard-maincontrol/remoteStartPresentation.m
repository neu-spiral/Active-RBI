%% remoteStartPresentation
%   is a script that creates main2presentation TCPIP object and calls
%   the decisionMaker function for making decison with featureExtraction
%   result.
%
%   See also sender2receiverCommInitialize
%   generateArtificialTriggers
%%

dos('startPresentation.bat &');

[~,main2presentationCommObjectStruct,BCIPacketStruct] = sender2receiverCommInitialize('main','presentation',false,[],RSVPKeyboardParams.IP_presentation,RSVPKeyboardParams.port_mainAndPresentation);
tmpStruct.decideNextFlag=1;
tmpStruct.trialLabels=[];
tmpStruct.completedSequenceCount=0;
tmpStruct.duration=0;

for evidenceIndex=1:length(RSVPKeyboardParams.evidenceEval.evidences)
    if ~(exist('sessionID','var') && sessionID==1) || strcmp(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex},'ERP')
        results.(RSVPKeyboardParams.evidenceEval.evidences{evidenceIndex})=tmpStruct;
    end
end
% results.ERP.decideNextFlag=1;
% results.ERP.trialLabels=[];
% results.ERP.completedSequenceCount=0;
% results.ERP.duration=0;
% if ~(exist('sessionID','var') && sessionID==1)
%     results.FRP=results.ERP;
% end
[~,decision] = decisionMaker(results,RSVPKeyboardTaskObject,main2presentationCommObjectStruct,BCIPacketStruct);

if(strcmp(daqStruct.DAQType,'noAmp'))
    if isfield(decision,'nextSequence') && isfield(decision.nextSequence,'Type')
        generateArtificialTriggers(DAQClassObj,decision,artificialsTriggersParams.(decision.nextSequence.Type))
    else
        generateArtificialTriggers(DAQClassObj,decision,artificialsTriggersParams.ERP)
    end
    %generateArtificialTriggers(DAQClassObj,decision,artificialsTriggersParams)
end