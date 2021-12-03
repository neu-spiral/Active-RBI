%BTLM object interface to a binary typing language model.
%
%  Given a language model and a history of selected symbols, the
%  BTLM object provides, for each symbol, the probability of that
%  symbol occuring next.
%
%  obj = btlm
%    Creates a new BTLM object.
%
%  obj = btlm(modelFile)
%    Creates a new BTLM object and calls the initLocal method to
%    load modelFile into the current process space.
%
%  obj = btlm(modelFile,wordFile)
%    Creates a new BTLM object and calls the initLocal method to
%    load modelFile and word-based language model wordFile into the
%    current process space.
%
%  obj = btlm(hostname, port, password)
%    Creates a new BTLM object and calls the initRemote method to
%    attach it to a remote BTLM server.
%
%  Example: Select the most likely symbol and print the resulting
%           string. "btlmserv modelFilename" is assumed to be
%           running on the same machine.
%
%     a = btlm;       % create a new BTLM object
%     a.initRemote;   % connect to the default server (localhost)
%     a.alloc;        % allocate an initial language model state
%     for i=1:64
%       s=a.sortedSymbols;   % s{1} is the most likely next symbol
%       fprintf('%s',s{1});
%       a.update(s{1});      % select the top candidate
%     end
%     fprintf('\n');
%     clear a;        % disconnect from the server and destroy the object
%
%  PROPERTIES
%    model  - the name of the language model file
%    state  - state ID of the last state allocated, -1 if no states
%               have been allocated
%    previousStates - list of state IDs allocated since the last reset
%    symbol - cell array containing the symbol set used with the
%               current language model.  Use obj.symbol{index} to map
%               from symbol a symbol index to an actual symbol string
%
%  METHODS
%    alloc         - allocates a new language model state
%    index         - maps from symbol strings to symbol indices
%    initLocal     - initialize the object with an in-process
%                      language model
%    initRemote    - initialize the object and attach it to a remote language
%                      model server
%    probs         - returns -log(prob(symbol{i})) for all symbols
%                      in the model
%    reset         - resets the object to its initial state
%    shutdown      - requests server shutdown
%    sortedIndices - returns the symbol indices for a given state
%                      in decending order of likelihood of occuring next
%    sortedSymbols - returns the symbols for a given state in
%                      decending order of likelihood of occuring
%                      next
%    undo          - undoes/deletes most recent symbol update
%    update        - updates the language model when a symbol has
%                      been selected
%    version       - returns BTLM library version: major.minor.patch
%
% HELP btlm.method for additional details.

classdef btlm < handle

    properties (Hidden)
        id=uint64(0);
        indexMap;
        hasContainers=0;
    end
    
    properties
        model='';
        state=int32(-1);
        previousStates=int32([])
        symbol='';
    end
    
    methods
        function obj = btlm(a, b, c)
        %  obj = btlm
        %    Creates a new BTLM object.
        %
        %  obj = btlm(modelFile)
        %    Creates a new BTLM object and calls the initLocal method to
        %    load modelFile into the current process space.
        %
        %  obj = btlm(modelFile,wordFile)
        %    Creates a new BTLM object and calls the initLocal method to
        %    load modelFile and word-based language model wordFile into the
        %    current process space.
        %
        %  obj = btlm(hostname, port, password)
        %    Creates a new BTLM object and calls the initRemote method to
        %    attach it to a remote BTLM server.        
        %
        % Use 'clear obj' to release resources and dispose of the
        % BTLM object.
            if nargin==1
              obj.initLocal(a);
            elseif nargin==2
              obj.initLocal(a,b);
            elseif nargin==3
              obj.initRemote(a,b,c);
            end
        end
        
        
        function delete(obj)
        % obj.delete
        %   Class destructor called when references to the object
        %   are cleared.  Releases all BTLM resources.
           if obj.id ~= 0
             pClose(obj);
           end
        end
        
        
        function newState = alloc(obj, K, P)
        % newState = obj.alloc(K, P)
        %   Allocates a new language model state with optional
        %   parameters K (default 1.0) and P (default 0.05).
        %   Returns the new state handle and keeps a copy in
        %   the obj.state parameter.
        %
        % Example: state=obj.alloc;
            assert(obj.id~=0, 'object has not been initialized');
            if nargin<2, K=1.00;, end
            if nargin<3, P=0.05;, end
            newState=pAlloc(obj,K,P);
            obj.previousStates(end+1)=obj.state;
            obj.state=newState;
        end
        
        
        function idx = index(obj, symbol)
        % idx = obj.index(symbol)
        %   Returns the symbol index associated with the symbol
        %   string.
        %
        % Example: idx=obj.index('t');
            if obj.hasContainers
                idx=obj.indexMap(symbol);
            else
                idx=strmatch(symbol, obj.symbol,'exact');
            end
        end
        
        
        function initLocal(obj, modelpath, wordpath)
        % obj.initLocal(modelPath, wordPath)
        %   Initializes the BTLM object to use an in-process
        %   language model (and optional word-based language model,
        %   if the wordPath argument is given.)
        %
        % Example: obj.initLocal('../models/nyt.200.36char.m3.fromfst.mod');
            assert(obj.id==0, 'object has already been initialized');
            if(nargin==2)
                pInitLocal(obj, modelpath);
            else
                pInitLocal(obj, modelpath, wordpath);
            end
            pInitProperties(obj);
        end
        
        
        function initRemote(obj, host, port, pass)
        % obj.initRemote(hostname, port, password)
        %   Initializes the BTLM object and connects it to the BTLM
        %   server at hostname:port using password for
        %   authentication.
        %   If hostname, port or password are absent or an empty
        %   string, the default values (as determined by the BTLM
        %   library) are used instead.
        %   The default hostname is 'localhost' and the port is
        %   '7331'
        %
        % Example: obj.initRemote('slurm.csee.ogi.edu','1234');
        %   Connects to the BTLM server on slurm.csee.ogi.edu:1234
        %   with the default password.
            assert(obj.id==0, 'object has already been initialized');
            if nargin<2, host='';, end
            if nargin<3, port='';, end
            if nargin<4, pass='';, end
            pInitRemote(obj, host, port, pass);
            pInitProperties(obj);
        end
        
        
        function logprob = probs(obj, state)
        % logprob = probs(state)
        %   Returns an Nx1 array of double that holds
        %   -log(prob(symbol{i})) where 1<=i<=N and the model has N
        %   symbols.  These are the probabilities that symbol{i}
        %   will occur next, given the state history.
        %   If state is not specified, obj.state (i.e. the current
        %   state) is used instead.
        %
        % Example:
        %   p=obj.probs;
        %   sum(exp(-p))
        %
        % The result of the summation should be 1.0.
            assert(obj.id~=0, 'object has not been initialized');
            if nargin==1, state=obj.state;, end
            logprob=pGetLogProbs(obj,state);
        end


        function reset(obj)
        % obj.reset
        %   Resets the object to its initialized state.
        %   This is functionally equivalent to clearing and
        %   recreating the object, but with less overhead.
        %
        % Example: obj.reset;
            assert(obj.id~=0, 'object has not been initialized');
            pReset(obj);
            obj.state=int32(-1);
            obj.previousStates=int32([]);
        end


        function shutdown(obj)
        % obj.shutdown
        %   Sends a shutdown request to the attached BTLM server.
        %   The server will shut down once no client connections
        %   are active.
        %
        % Example: obj.shutdown
            assert(obj.id~=0, 'object has not been initialized');
            pShutdown(obj);
        end
        
        
        function indices = sortedIndices(obj, state)
        % indices = obj.sortedIndices(state)
        %   Returns the symbol indices for a given language model
        %   state in decending order of the likelihood of occuring
        %   next.
        %   The state argument is optional, if it is not supplied,
        %   the current state (obj.state) will be used instead.
        %
        % Example:
        %   a=btlm;
        %   a.initRemote;
        %   a.alloc;
        %   idx=a.sortedIndices;
        %
        % At this point idx(1) contains the index of the symbol
        % most likely to occur at the start of a sequence.
            assert(obj.id~=0, 'object has not been initialized');
            if nargin==1
                assert(obj.state>=0, ['no states have been ' ...
                                    'allocated']);
                state=obj.state;
            end
            indices=pGetSortedIndices(obj, state);
        end
        
        
        function symbols = sortedSymbols(obj, state)
        % symbols = obj.sortedSymbols(state)
        %   Returns a cell array containing the symbols of the
        %   language model in decending order of the likelihood of
        %   occuring next.
        %   The state argument is optional, if not supplied, the
        %   current state (obj.state) will be used instead.
        %
        % Example:
        %   a=btlm;
        %   a.initRemote;
        %   a.alloc;
        %   sym=a.sortedSymbols;
        %   sym{1}
        %
        % At this point sym{1} contains the symbol most likely to
        % occur at the start of a sequence.
            assert(obj.id~=0, 'object has not been initialized');
            if nargin==1,
                assert(obj.state>=0, ['no states have been ' ...
                                    'allocated']);
                state=obj.state;
            end
            indices=pGetSortedIndices(obj, state);
            for i=1:length(indices)
                symbols{i,:}=obj.symbol{indices(i)};
            end
        end
        
        
        function newState = undo(obj)
        % newState = obj.undo()
        %   Sets obj.state to the previous model state ID and
        %   returns this value. This effectively undoes/deletes the
        %   most recent symbol update.
        %
        % Example:
        %   a=btlm;
        %   a.initRemote;
        %   a.alloc;
        %   a.update('t');
        %   a.sortedSymbols
        %   a.update('h');
        %   a.sortedSymbols
        %   a.undo;
        %   a.sortedSymbols
            assert(length(obj.previousStates)>0,['no states have ' ...
                                'been allocated']);
            obj.state=obj.previousStates(end);
            obj.previousStates=obj.previousStates(1:end-1);
            %obj.state
        end
        
        
        function [newState K P] = update(obj, symbol, state)
        % [newState K P] = obj.update(symbol, state)
        %   Updates the language model and adds symbol to the
        %   selection history.  Returns a new language model state
        %   and saves this state to obj.state.
        %   Symbol is either a symbol index or an actual symbol
        %   string.
        %   The state input parameter is optional, if not supplied,
        %   the current state (obj.state) will be used instead.
        %   K and P are language model parameters, typically 1.0
        %   and 0.05.
        %
        % Example:
        %   a=btlm;
        %   a.initRemote;
        %   a.alloc;
        %   a.update('t');
        %   sym=a.sortedSymbols;
        %
        % sym{1} will now contain the symbol most likely to follow a
        % 't' at the start of a sequence.
            assert(obj.id~=0, 'object has not been initialized');
            
            if ~isnumeric(symbol), symbol=obj.index(symbol);, end
            if nargin==2, state=obj.state;, end
            [newState K P]=pUpdate(obj, state, symbol);
            obj.previousStates(end+1)=obj.state;
            obj.state=newState;
        end
        
        
        function version = version(obj)
        % string = obj.version
        %   Returns the BTLM library version number in the form:
        %    major.minor.patch
            version = pVersion();
        end
        
        
    end
    
end
