%% [active,passive]=getAdjustedDuration(duration,interFlipInterval,dutycycle)
% getAdjustedDuration calculates the duration which the symbol is shown and the duration of the
% blank screen using refresh rate of the monitor, duty cycle of the symbol and the duration of the
% symbol.
%
%   Inputs: 
%
% * duration - the total duration of the symbol including following blank screen (in seconds) 
% * interFlipInterval - vertical trace duration of symbol = 1/refresh rate (in seconds)
% * dutycycle - duty cycle of the symbol = duration of the symbol/(total duration of the symbol
% including the blank screen) (in seconds)
%
%   Outputs:
%
% * active - duration which the symbol will be on the screen
% * passive -duration which the screen will be blank after the symbol
%

function [active,passive]=getAdjustedDuration(duration,interFlipInterval,dutycycle)
active=round(duration*dutycycle/interFlipInterval)*interFlipInterval;
passive=round(duration*(1-dutycycle)/interFlipInterval)*interFlipInterval;