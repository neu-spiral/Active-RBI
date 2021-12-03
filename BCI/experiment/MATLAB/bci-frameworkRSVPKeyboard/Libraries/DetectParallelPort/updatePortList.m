if ~strcmpi(RSVPKeyboardParams.DAQType,'noAmp')
    prallelPortAdressExist=0;
    while ~prallelPortAdressExist
        if ~iscell(RSVPKeyboardParams.parallelPortIOList)
            RSVPKeyboardParams.parallelPortIOList={RSVPKeyboardParams.parallelPortIOList};
        end
        if sum(strcmpi(RSVPKeyboardParams.parallelPortIOList,'auto'))>0
            tmpPort=detectParallelPortNumberHex;
            if isempty(tmpPort)
                RSVPKeyboardParams.parallelPortIOList(strcmpi(RSVPKeyboardParams.parallelPortIOList,'auto'))=[];
            else
                RSVPKeyboardParams.parallelPortIOList{strcmpi(RSVPKeyboardParams.parallelPortIOList,'auto')}=tmpPort;
            end
            
            
        end
        prallelPortAdressExist=~isempty(RSVPKeyboardParams.parallelPortIOList);
    end
    
else
   RSVPKeyboardParams.parallelPortIOList={'4020'};
end