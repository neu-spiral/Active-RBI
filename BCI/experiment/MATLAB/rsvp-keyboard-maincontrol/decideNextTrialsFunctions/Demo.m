clear all
close all


bci_path = 'C:\Users\CSL_common_use\Desktop\Git\rsvp_keyboard\rsvp-keyboard-maincontrol';
addpath(genpath(bci_path));


fusion = @RSVPCalculateLikelihoods;
query_method = @decideNextTrialsERP;

evidenceEvalClass('ERP',fusion,query_method)