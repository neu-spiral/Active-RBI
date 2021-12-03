function pInitProperties( obj )
%PINITPROPERTIES Initializes btlm object properties

     obj.model=pGetModelName(obj);
     obj.symbol=pGetSymbols(obj);
     
     try
        obj.indexMap=containers.Map();
        obj.hasContainers=1;
        for i=1:length(obj.symbol)
             obj.indexMap(obj.symbol{i})=i;
        end         
     catch
        obj.hasContainers=0;
     end
end
