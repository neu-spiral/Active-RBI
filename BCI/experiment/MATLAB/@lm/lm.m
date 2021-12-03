
classdef lm < handle

    properties (Hidden)
        serverURL = '';  % the url used to call the web service.
    end

    properties
    end

    methods
        function obj = lm(ip)
        %  obj = lm(ip)
        %    Creates a new LM object to communicate with language model server.
        %    The IP address of LM server is specified upon construction.
        %    TODO: It could be defined as some preset parameter.
        %
        % Use 'clear obj' to release resources and dispose of the LM object.
            obj.serverURL = strcat('http://', ip, ':5000/');
            obj.init();
        end

        function init(obj)
        % obj.init
        %   Initilize the LM sever.
        %
        % Example: obj.init();
            url = strcat(obj.serverURL, 'init');

            % The init function will fail if it is called when the server is
            % being brought up. We would wait in such case.
            % TODO: Add maximum times of attemtping.
            is_server_up = false;
            while ~is_server_up
              is_server_up = true;
              try
                webread(url);
              catch
                disp('waiting for language model server...')
                pause(3)
                is_server_up = false;
              end
            end
        end

        function reset(obj)
        % obj.reset
        %   Resets the object to its initialized state.
        %
        % Example: obj.rest();
            obj.init();
        end

        function alloc(obj)
        % obj.alloc
        %   Does nothing but provides backward compatibility.
        %
        end

        function undo(obj)
        % obj.undo()
        %   Undoes or deletes the most recent symbol update.
        %
        % Example:
        %   a.update('t')
        %   a.update('h')
        %   a.undo()
            url = strcat(obj.serverURL, 'undo');
            response = webread(url);
            % TODO: Check the return value for error handling.
        end

        function update(obj, symbol)
        % obj.update(symbol)
        %   Updates the language model and adds symbol to the decision
        %   history.
        %
        % Example:
        %   a.update('t')
        %   a.update('h')
            url = strcat(obj.serverURL, 'update');
            response = urlread(url, 'Post', {'decision', symbol});
            % TODO: Check the return value for error handling.
        end

        function logprob = probs(obj)
        % logprob = obj.probs()
        %   Returns an Nx1 array of double that holds -log(prob(symbol{i}))
        %   where 1 <= i <= N and the model has N symbols. These are the
        %   probabilities that symbol{i} will occur next, given the history.
        %
        % Example:
        %   p = obj.probs;
        %   sum(exp(-p))
        %
        % The result of the summation should be 1.0.
            url = strcat(obj.serverURL, 'get-prior');
            response = webread(url);
            logprob = response.prior;
        end

        function sym = symbol(obj)
        % sym = obj.symbol()
        %   Returns an Nx1 array of characters that holds the possible symbols
        %   from the language model.
        %
        % Example:
        %   symbols = obj.symbols()
          url = strcat(obj.serverURL, 'symbol');
          response = webread(url);
          sym = response.syms;
        end
    end
end
