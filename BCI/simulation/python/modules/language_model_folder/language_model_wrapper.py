from simulation.python.modules.main_frame import alphabet
from simulation.python.modules.language_model_folder.language_model import LangModel
import numpy as np


class LanguageModelWrapper(object):
    """ wrapper for the language model for reinforcement learning applications.
        original language model is developed by the RSVPKeyboard language modelling
        team.
        Attr:
            lang_model(LangModel): language model core
            alp(list[char]): alphabet of the language model
            backspace_prob(float): backspace probability
            """

    def __init__(self, abs_path_fst, alp=alphabet(), backspace_prob = 1. / 27.):
        local_fst = abs_path_fst
        self.backspace_prob = backspace_prob
        self.alp = alp
        # init LMWrapper
        self.lang_model = LangModel(local_fst, host='127.0.0.1', port='5000',
                                    logfile="lmwrap.log")
        self.lang_model.init()

        # TODO: Stupid flag, remove it!
        self.history_flag = 0

    def update(self, phrase):
        """ updates the language model with the given phrase, appends to the text
            Args:
                phrase(str): phrase to be appended to text """
        if len(phrase) != 0:
            self.history_flag = 1
            self.lang_model.state_update(list(phrase))

    def set_reset(self, phrase):
        """ resets the language model first then updates
            Args:
                phrase(str): phrase to be appended to text """
        self.lang_model.reset()
        if len(phrase) != 0:
            self.history_flag = 1
            self.lang_model.state_update(list(phrase))
        else:
            self.history_flag = 0

    def get_prob(self):
        """ given the current status, returns the probability distribution for the next
            letter.
            Return:
                prior(ndarray[float]): probability distribution over the alphabet
            """
        prior = np.ones(len(self.alp))

        if self.history_flag == 1:
            tmp = self.lang_model.recent_priors()['prior']
            for i in tmp:
                letter = i[0].upper()
                prior[self.alp.index(letter)] = np.exp(-i[1])

        prior[self.alp == "<"] = self.backspace_prob
        prior /= np.sum(prior)

        return prior
