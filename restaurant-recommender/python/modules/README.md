# Query Selection

This repository takes the low level letter selection into consideration, includes realizations of optimizing sequences.

In RSVPKeyboard, the dynamical system updates current belief by stimulating letters on a screen. Stimuli can be optimized using active/reinforcement learning
to satisfy more robust, faster and more accurate state estimation (users intended symbol).

Content:

* `.\oracle.py` is the implementation of the oracle of the system (which is user). Oracles updates its state by observing the displayed state on the system.
Responds to the query it is asked with a particular score drawn from the distributions.

* `.\main_frame.py` is the implementation of the RSVPKeyboard decision maker and evidence fusion. Evidence fusion keeps track of the likelihood history from different sources.
Decision maker is the brain of the system that decides to continue or makes a decision. Asks queries, prepares stimuli and stores the history.

* `.\query_methods.py` is the file where different quering methods are stored. Refer to each implementation for specifications.

* `.\progress_bar.py` is a supporting file, creates a progress bar that is filled through iterations (saves the user from seeing a blank screen).

* *language_model_folder* is the folder for language model and dependencies.
	
	-  `.\language_model_wrapper.py` is the wrapper that helps the language model in the docker container and the decision maker communicate.

