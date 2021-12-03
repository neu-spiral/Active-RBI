import numpy as np
import random
import warnings

eps = np.power(.1, 15)


class RatioStop(object):
    """ Stopping criteria based on ratio of two most likely candidates """

    def __init__(self, tau):
        self.tau = tau

    def decide(self, p):
        """ Decides to stop or not
            Args:
                p(ndarray[float]): final probability distribution
            Return:
                d(boolean): True if decision is made, False if not """

        candidates = [p[idx] for idx in list(np.argsort(p)[-2:])]
        stopping_rule = np.abs(candidates[0] - candidates[1])
        d = stopping_rule > self.tau

        return d

    def reset(self):
        pass


class RenyiStop:
    """ Stopping criteria based on Renyi entropy on the simplex
        Renyi entropy for infinity and 1 norms are special forms.
        Attr:
            alpha(float): a non-negative order for the entropy
            tau(float): decision threshold
            """

    def __init__(self, alpha, tau):
        self.alpha = alpha
        self.tau = tau

    def decide(self, p):
        """ Decides to stop or not
            Args:
                p(ndarray[float]): final probability distribution
            Return:
                d(boolean): True if decision is made, False if not """

        # If Renyi order is 1 or infinity, calculate closed forms
        tmp_p = np.ones(len(p)) * (1 - self.tau) / len(p)
        tmp_p[0] = self.tau
        if self.alpha == 1:
            tmp = -np.sum(p * np.log2(p))
            tau_ = -np.sum(tmp_p * np.log2(tmp_p))
        elif self.alpha == np.inf:
            tmp = -np.log2(np.max(p))
            tau_ = -np.log2(self.tau)
        else:
            tmp = np.power(p, self.alpha)
            tmp = 1. / (1 - self.alpha) * np.log2(np.sum(tmp))
            tau_ = 1. / (1 - self.alpha) * np.log2(
                np.sum(np.power(tmp_p, self.alpha)))

        stopping_rule = tmp
        d = stopping_rule < tau_

        return d

    def reset(self):
        pass


class RenyiMomentumStop:
    """ Stopping criteria based on Renyi entropy on the simplex
        Renyi entropy for infinity and 1 norms are special forms.
        Attr:
            alpha(float): a non-negative order for the entropy
            tau(float): decision threshold
            """

    def __init__(self, alpha, tau, lam):
        self.alpha = alpha
        self.lam = lam
        self.tau = tau
        self.prob_history = []

    def reset(self):
        """ resets the history related items in stopping method
        """
        self.prob_history = []

    def decide(self, p):
        """ Decides to stop or not
            Args:
                p(ndarray[float]): final probability distribution
            Return:
                d(boolean): True if decision is made, False if not """

        self.prob_history.append(p)
        tmp_p = np.ones(len(p)) * (1 - self.tau) / (len(p) - 1)
        tmp_p[0] = self.tau
        # If Renyi order is 1 or infinity, calculate closed forms
        if self.alpha == 1:
            tmp = -np.sum(p * np.log2(p + eps))
            tau_ = -np.sum(tmp_p * np.log2(tmp_p + eps))
        elif self.alpha == np.inf:
            tmp = -np.log2(np.max(p))
            tau_ = -np.log2(self.tau)
        else:
            tmp = np.power(p, self.alpha)
            tmp = 1. / (1 - self.alpha) * np.log2(np.sum(tmp))
            tau_ = 1. / (1 - self.alpha) * np.log2(
                np.sum(np.power(tmp_p, self.alpha)))

        if len(self.prob_history) > 1:
            stopping_rule = tmp - self.lam * self.Renyimomentum()
        else:
            stopping_rule = tmp

        d = stopping_rule < tau_

        return d

    def Renyimomentum(self):
        """ momentum is updated with the particular probability history of the system.
            WARNING!: if called twice without a probability update, will update
            momentum using the same information twice """

        # momentum = current_mass * mass_displacement
        tmp = np.array(self.prob_history)
        if self.alpha == 1:
            mom_ = tmp[1:] * (
                    np.log(tmp[1:] + eps) - np.log(tmp[:-1] + eps))
        elif self.alpha == 0:
            mom_ = - np.log(tmp[:-1] + eps)
        elif self.alpha == np.inf:
            mom_ = np.maximum(np.log(tmp[1:] + eps) - np.log(tmp[:-1] + eps), 0)
        else:
            tmp1 = np.power(tmp[1:], self.alpha)
            tmp2 = np.power(tmp[:-1], (self.alpha - 1))
            try:
                mom_ = 1 / (self.alpha - 1) * np.log(tmp1 / (tmp2 + eps))
            except:
                import pdb

        momentum = np.linalg.norm(mom_) / len(self.prob_history)
        # print(momentum)

        return momentum
