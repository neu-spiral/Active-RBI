from __future__ import division, print_function
from simulation.python.modules.query_methods import MomentumQuerying
from simulation.python.modules.stopping_criteria import RenyiStop
import matplotlib.pyplot as plt
from matplotlib import gridspec
import numpy as np

eps = np.power(.1, 7)


def alphabet():
    """Alphabet.

    Function used to standardize the symbols we use as alphabet.

    Returns
    -------
        array of letters.
    """

    return ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
            'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
            '_', '<']


# TODO: Decide if this method should be inside decision maker class!
def form_delta(state):
    """ Forms the state information or the user that fits to the
        display. Basically takes '.' and '<' into consideration and rewrites
        the state
        Args:
            state(str): state string
        Return:
            displayed_state(str): state without '<,.' and removes
                backspaced letters """
    tmp = ''
    for i in state:
        if i == '<':
            tmp = tmp[0:-1]
        elif i != '.':
            tmp += i

    return tmp


class EvidenceFusion(object):
    """ Fuses likelihood evidences provided by the inference
        Attr:
            evidence_history(dict{list[ndarray]}): Dictionary of difference
                evidence types in list. Lists are ordered using the arrival
                time.
            likelihood(ndarray[]): current probability distribution over the
                set. Gets updated once new evidence arrives. """

    def __init__(self, list_name_evidence, len_dist):
        self.evidence_history = {name: [] for name in list_name_evidence}
        self.likelihood = np.ones(len_dist) / len_dist

    def update_and_fuse(self, dict_evidence):
        """ Updates the probability distribution
            Args:
                dict_evidence(dict{name: ndarray[float]}): dictionary of
                    evidences (EEG and other likelihoods)
                """

        for key in dict_evidence.keys():
            tmp = dict_evidence[key][:][:]
            self.evidence_history[key].append(tmp)

        # TODO: Current rule is to multiply
        for value in dict_evidence.values():
            self.likelihood *= value[:]
        self.likelihood = self.likelihood / (np.sum(self.likelihood) + eps)
        self.likelihood[np.isnan(self.likelihood)] = 1

        likelihood = self.likelihood[:]

        return likelihood

    def reset_history(self):
        """ Clears evidence history """
        for value in self.evidence_history.values():
            del value[:]
        self.likelihood = np.ones(len(self.likelihood)) / len(self.likelihood)

    def save_history(self):
        """ Saves the current likelihood history """
        return 0


class DecisionMaker(object):
    """ Scheduler of the entire framework
        Attr:
            state(str): state of the framework, which increases in size
                by 1 after each sequence. Elements are alphabet, ".,_,<"
                where ".": null_sequence(no decision made)
                      "_": space bar
                      "<": back space
            displayed_state(str): visualization of the state to the user
                only includes the alphabet and "_"
            alphabet(list[str]): list of symbols used by the framework. Can
                be switched with location of images or one hot encoded images.
            time(float): system time
            evidence(list[str]): list of evidences used in the framework
            list_priority_evidence(list[]): priority list for the evidences
            sequence_counter(dict[str(val=float)]): number of sequences
                passed for each particular evidence
            list_epoch(list[epoch]): List of stimuli in each sequence
                epoch(dict{items}):
                    - target(str): target of the epoch
                    - time_spent(ndarray[float]): |num_trials|x1
                      time spent on the sequence
                    - list_sti(list[list[str]]): presented symbols in each
                      sequence
                    - list_distribution(list[ndarray[float]]): list of |alp|x1
                        arrays with prob. dist. over alp
            min_num_seq(int): minimum number of sequences before a decision
            max_num_seq(int): maximum number of sequences for a decision
            query_method(query_method): specified query method for the decision
                maker. for further specifications check, query methods.
            stopping_actor(stopping_criteria): specified stopping criteria

        Functions:
            decide():
                Checks the criteria for making and epoch, using all
                evidences and decides to do an epoch or to collect more
                evidence
            do_epoch():
                Once committed an epoch perform updates to condition the
                distribution on the previous letter.
            schedule_sequence():
                schedule the next sequence using the current information
            decide_state_update():
                If committed to an epoch update the state using a decision
                metric.
                (e.g. pick the letter with highest likelihood)
            prepare_stimuli():
                prepares the query set for the next sequence
                (e.g pick n-highest likely letters and randomly shuffle)
        """

    def __init__(self, state='', len_query=4,
                 query_method=MomentumQuerying(space_query=alphabet()),
                 stopping_actor=RenyiStop(alpha=np.inf, tau=-np.log2(.85)),
                 alp=alphabet(), is_txt_sti=True):
        self.state = state
        self.displayed_state = form_delta(state)

        # TODO: read from parameters file
        self.alphabet = alp
        self.is_txt_sti = is_txt_sti

        self.list_epoch = [{'target': None, 'time_spent': 0,
                            'list_sti': [], 'list_distribution': []}]
        self.time = 0
        self.sequence_counter = 0

        # Stopping Criteria
        self.stopping_actor = stopping_actor
        # TODO: Read from parameters
        self.min_num_seq = 10
        self.max_num_seq = 20

        self.query_method = query_method

        # number of trials in a sequence
        self.len_query = len_query

    def reset(self, state=''):
        """ Resets the decision maker with the initial state
            Args:
                state(str): current state of the system """
        self.state = state
        self.displayed_state = form_delta(self.state)

        self.list_epoch = [{'target': None, 'time_spent': 0,
                            'list_sti': [], 'list_distribution': []}]
        self.time = 0
        self.sequence_counter = 0

    def update(self, state=''):
        self.state = state
        self.displayed_state = form_delta(state)

    def decide(self, p, p_label=[0.]):
        """ Once evidence is collected, decision_maker makes a decision to
            stop or not by leveraging the information of the stopping
            criteria. Can decide to do an epoch or schedule another sequence.
            Args:
                p(ndarray[float]): |A| x 1 distribution array
                    |A|: cardinality of the alphabet
            Return:
                commitment(bin): True if a letter is a commitment is made
                                 False if requires more evidence
                args(dict[]): Extra arguments depending on the decision
                """

        self.list_epoch[-1]['list_distribution'].append(p[:])
        commitment = self.stopping_actor.decide(p)
        self.p_label = p_label
        if commitment == True:
            asd = 1

        # Check stopping criteria
        if self.sequence_counter < self.min_num_seq or \
                not (self.sequence_counter >= self.max_num_seq or
                     commitment):

            stimuli = self.schedule_sequence()
            commitment = False
            return commitment, stimuli
        else:
            self.do_epoch()
            commitment = True
            return commitment, []

    def do_epoch(self):
        """ Epoch refers to a commitment to a decision.
            If made, state is updated, displayed state is updated
            a new epoch is appended. """
        self.sequence_counter = 0
        self.query_method.reset()
        self.stopping_actor.reset()
        decision = self.decide_state_update()
        self.list_epoch[-1]['decision'] = decision
        self.state += decision
        self.displayed_state = form_delta(self.state)

        # Initialize next epoch
        self.list_epoch.append({'target': None, 'time_spent': 0,
                                'list_sti': [], 'list_distribution': [],
                                'decision': None})

    def schedule_sequence(self):
        """ Schedules next sequence """
        self.state += '.'
        stimuli = self.prepare_stimuli()
        self.list_epoch[-1]['list_sti'].append(stimuli)
        self.sequence_counter += 1

        return stimuli

    def decide_state_update(self):
        """ Checks stopping criteria to commit to an epoch """
        try:
            idx = np.argmax(self.list_epoch[-1]['list_distribution'][-1])
        except:
            import pdb
            pdb.set_trace()
        decision = self.alphabet[idx]
        return decision

    def prepare_stimuli(self):
        """ Given the alphabet, under a rule, prepares a stimuli for
            the next sequence
            Return:
                stimuli(tuple[list[char],list[float],list[str]]): tuple of
                    stimuli information. [0]: letter, [1]: timing, [2]: color
                """
        tmp = self.list_epoch[-1]['list_distribution'][-1][:]
        stimuli = self.query_method.update_query(tmp[:], self.p_label)
        return stimuli


def taskVisuallization(posterior, query, alp=alphabet()):
    x = np.arange(len(alp))
    mng = plt.get_current_fig_manager()
    figS = np.array(mng.window.maxsize()) * np.array([.5, .4])
    figSize = tuple(figS.astype(int))
    # mng.resize(*figSize)
    fig = plt.figure(figsize=[20, 5])
    gs = gridspec.GridSpec(1, 2, width_ratios=[3, 1])
    # ax1
    ax1 = plt.subplot(gs[0])
    ax1.set_xticks(x)
    ax1.bar(x, posterior, color=[0., 0., 0.])
    # Hide the right and top spines
    ax1.spines['right'].set_visible(False)
    ax1.spines['top'].set_visible(False)
    # Only show ticks on the left and bottom spines
    ax1.yaxis.set_ticks_position('left')
    ax1.xaxis.set_ticks_position('bottom')
    ax1.set_xticklabels(alp)
    ax1.set_title('Posterior Probability', fontsize=18)
    ax1.set_ylabel('Probability', fontsize=16)
    ax1.set_xlabel('Symbols', fontsize=16)
    ax1.set_ylim(0, 1)
    # ax2
    ax2 = plt.subplot(gs[1], aspect=1)
    # Hide the right and top spines
    ax2.spines['right'].set_visible(False)
    ax2.spines['left'].set_visible(False)
    ax2.spines['top'].set_visible(False)
    ax2.spines['bottom'].set_visible(False)
    ax2.set_xticks([])
    ax2.set_yticks([])
    # ax2.axis('off')
    ax2.set_facecolor((0., 0., 0.))
    # build a rectangle in axes coords
    left, width = .25, .5
    bottom, height = .25, .5
    right = left + width
    top = bottom + height
    # placing the query in the middle fo the screen
    ax2.text(0.5 * (left + right), 0.5 * (bottom + top), query,
             horizontalalignment='center',
             verticalalignment='center',
             fontsize=40, color='yellow',
             transform=ax2.transAxes)

    ax2.axis('equal')
    # show the plot
    # return fig
