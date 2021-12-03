clear;
clc;
addpath(genpath('.'));
RSVPKeyboardParameters;
updatePortList;
remoteGUIClient = RemoteSignalMonitorGUI();
remoteGUIClient.runClient(RSVPKeyboardParams.IP_main,RSVPKeyboardParams.port_mainAndGUI);