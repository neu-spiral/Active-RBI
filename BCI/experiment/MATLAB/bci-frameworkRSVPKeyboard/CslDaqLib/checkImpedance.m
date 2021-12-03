escFlag=0;
while ~escFlag
    [success,impedances]=getImpedance(amplifierStruct);
    impedances
    [keyisdown,secs,keycode] = KbCheck;
    if keycode(27)
        escFlag = 1;
    end
end

