import os

import matplotlib.pyplot as plt
import numpy as np
import scipy.io as sio
from simulation.python.modules.main_frame import DecisionMaker, EvidenceFusion
from simulation.python.modules.main_frame import alphabet
from simulation.python.modules.oracle import BinaryRSVPOracle, \
    BinaryGaussianOracle
from tqdm import tqdm
from simulation.python.modules.query_methods import randomQuery, \
    RenyiMomentumQuery, MomentumQueryingLog, MomentumQueryingLog2
from simulation.python.modules.stopping_criteria import RenyiMomentumStop, \
    RatioStop
from scipy.stats import iqr
from sklearn.neighbors.kde import KernelDensity
from scipy.stats import norm


class DummyGaussDist(object):

    def __init__(self, mean, std):
        self.dist = norm(mean, std)

    def score_samples(self, s):
        return np.array([self.dist.pdf(i_el) for i_el in s])


save_flag = True
save_path = 'D:/data/proper_momentum/ex4/'

eps = np.power(.1, 10)
target_color = [1, .38, 0.01]
target_color2 = [1, .2, 0.]
filename = "AM04241994_IRB130107_ERPCalibration.mat"  # "AL12311987_IRB130107_ERPCalibration.mat"
path = "../../data/"

alp = alphabet()
len_query = 8
len_alp = len(alp)
evidence_names = ['LM', 'Eps']

list_phrase = ['IT_', 'IT_O', '']
target_letter = ['O', 'C', 'A']
fig, axs = plt.subplots(2, len(list_phrase), gridspec_kw={'wspace': 0.25})
fig.subplots_adjust(wspace=.35)
target_loc = [14, 2, 17]
target_loc = np.subtract(27, target_loc)
backspace_prob = 1. / 100.
bp_loc = 1
pp_loc = 0

abs_path_fst = os.path.abspath(
    "./modules/language_model_folder/fst/brown_closure.n5.kn.fst")

max_num_mc = 10000
delta = 20

conjugator = EvidenceFusion(evidence_names, len_dist=len_alp)

tmp = sio.loadmat(path + filename)
x = tmp['scores']
y = tmp['trialTargetness']
sc_threshold = 1000000

# modify data for outliers
y = y[x > -sc_threshold]
x = x[x > -sc_threshold]
y = y[x < sc_threshold]
x = x[x < sc_threshold]

x[y == 1] += delta

alphabet = alphabet()
alphabet[-2] = '-'

list_alpha = [.2, .5, 1., 2., 5., 10.]
lam_query = [1., .7, .4, .2, .01]
# lam_query = [.01]
lam_stopping = lam_query
list_lambda = lam_stopping
gam = 1.
dlam = [0] * len(list_alpha)
tau_threshold = .75
tau_ratio = 2 * tau_threshold - 1

# Flag parameters
lm_flag = 0  # 1 if language model is active

lm_fixed_prior = np.array([
    [0.0597, 0.0315, 0.0584, 0.0507, 0.0293, 0.0307, 0.0290, 0.0681, 0.2167,
     0.0264, 0.0125, 0.0302, 0.0546, 0.0249,
     0.0050, 0.0301, 0.0092, 0.0400, 0.0619, 0.0405, 0.0155, 0.0093, 0.0414,
     0.0001, 0.0006, 0.0002, 0.0001, 0.0236],
    [0.0014, 0.0000, 0.8131, 0.0000, 0.0361, 0.0000, 0.0000, 0.0013, 0.0005,
     0.0000, 0.0009, 0.0004, 0.0008, 0.0000,
     0.0090, 0.0000, 0.0000, 0.0007, 0.0000, 0.0854, 0.0002, 0.0000, 0.0000,
     0.0000, 0.0000, 0.0000, 0.0001, 0.0500],
    np.ones(len(alphabet)) / len(alphabet)]) + eps

# P(l=1 | sigma , phi)
p_label = np.zeros((2, len(alp), len(alp)))
for c in range(2):
    p_label[1, :, :] = np.eye(len(alp))

tmp_p = np.ones(len_alp) * (1 - tau_threshold) / len_alp
tmp_p[0] = tau_threshold

num_query = 2 + len(list_alpha)
# min_num_seq = [[21,23,18,18,18],[10,4,3,3,4,4]]
# max_num_seq = [[40,21,23,18,18,18],[10,4,3,3,4,4]]
min_num_seq = [list(map(int, np.ones(num_query) * 3)),
               list(map(int, np.ones(num_query) * 3)),
               list(map(int, np.ones(num_query) * 3))]
max_num_seq = [list(map(int, np.ones(num_query) * 50)),
               list(map(int, np.ones(num_query) * 50)),
               list(map(int, np.ones(num_query) * 50))]

gaussian_mean = [0, .7]
gaussian_std = [.5, .4]
gaussian_mean_model = gaussian_mean
gaussian_std_model = gaussian_std
if save_flag:
    np.savetxt(
        save_path + 'means_stds_tau_' + str(round(tau_threshold, 2)) + '.txt',
        np.concatenate([gaussian_mean, gaussian_std]))

for idx_phrase in [1, 2]:
    pre_phrase = list_phrase[idx_phrase]
    phrase = list_phrase[idx_phrase] + target_letter[idx_phrase]
    oracle = BinaryRSVPOracle(x, y, phrase=phrase, alp=alp)
    # oracle = BinaryGaussianOracle(gaussian_mean, gaussian_std, phrase=phrase,
    #                               alp=alp)
    decision_maker = DecisionMaker(state='', len_query=len_query, alp=alp)

    # query_methods = [RenyiMomentumQuery(space_query=alp,
    #                                     len_query=len_query,
    #                                     alph=1, lam=0.,
    #                                     update_lam_flag=False)] * 5

    query_methods = [
        MomentumQueryingLog(space_query=alp, len_query=len_query, gam=1.,
                            lam=1., dlam=dlam, shift=0, update_lam_flag=False),
        MomentumQueryingLog2(space_query=alp, len_query=len_query, gam=1.,
                             lam=1., dlam=dlam, shift=0, update_lam_flag=False)]

    stopping_methods = [
        RenyiMomentumStop(alpha=np.inf, lam=0., tau=tau_threshold),
        RenyiMomentumStop(alpha=np.inf, lam=0., tau=tau_threshold)]

    # stopping_methods = [
    #     RatioStop(alpha=np.inf, tau=tau_ratio),
    #     RenyiMomentumStop(alpha=np.inf, lam=0., tau=tau_threshold),
    #     RenyiMomentumStop(alpha=4, lam=0., tau=tau_threshold),
    #     RenyiMomentumStop(alpha=2, lam=0., tau=tau_threshold),
    #     RenyiMomentumStop(alpha=0.8, lam=0., tau=tau_threshold)]

    # this is the dummy eeg_modelling part
    bandwidth = 1.06 * min(np.std(x),
                           iqr(x) / 1.34) * np.power(x.shape[0], -0.2)
    classes = np.unique(y)
    cls_dep_x = [x[np.where(y == classes[i])] for i in range(len(classes))]

    # dist = []
    # for i in range(len(gaussian_mean)):
    #     dist.append(
    #         DummyGaussDist(gaussian_mean_model[i], gaussian_std_model[i]))

    dist = []
    for i in range(len(classes)):
        dist.append(KernelDensity(bandwidth=bandwidth))

        dat = np.expand_dims(cls_dep_x[i], axis=1)
        dist[i].fit(dat)

    seq_holder = [[] for i in range(len(query_methods))]
    acc_holder = [[] for i in range(len(query_methods))]
    target_dist = [[] for i in range(len(query_methods))]
    l = max_num_mc * len(query_methods)
    bar_counter = 0
    method_count = 0

    list_letter = [[] for i in range(len(query_methods))]
    list_prob = [[] for i in range(len(query_methods))]

    for method_ind in range(len(query_methods)):

        decision_maker.min_num_seq = min_num_seq[idx_phrase][method_ind]
        decision_maker.max_num_seq = max_num_seq[idx_phrase][method_ind]
        decision_maker.query_method = query_methods[method_ind]
        sum_seq_till_correct = np.zeros(len(phrase))

        decision_maker.stopping_actor = stopping_methods[method_ind]

        entropy_holder, seq_elapsed = [], []
        correct_sel = 0

        for idx in tqdm(range(max_num_mc)):

            decision_maker.reset(state=pre_phrase)
            oracle.reset()
            oracle.update_state(decision_maker.displayed_state)

            seq_till_correct = [0] * len(phrase)
            d_counter = 0
            while decision_maker.displayed_state != phrase:

                # get prior information from language model
                tmp_displayed_state = "_" + decision_maker.displayed_state
                # use language model if language model flag is on
                if lm_flag:
                    idx_final_space = len(tmp_displayed_state) - \
                                      list(tmp_displayed_state)[
                                      ::-1].index(
                                          "_") - 1
                    lang_model.set_reset(
                        tmp_displayed_state[idx_final_space + 1:])
                    lang_model.set_reset(
                        decision_maker.displayed_state.replace('_', ' '))
                    lm_prior = lang_model.get_prob()
                else:
                    lm_prior = lm_fixed_prior[idx_phrase]
                    lm_prior += 0.1 * np.random.randn(len(lm_prior),)
                    lm_prior = np.abs(lm_prior) / np.sum(np.abs(lm_prior))

                prob = conjugator.update_and_fuse({'LM': lm_prior})
                prob_new = np.array([i for i in prob])
                d, sti = decision_maker.decide(prob_new)
                list_letter[method_count].append([sti])
                list_prob[method_count].append([prob_new])
                while True:
                    # get answers from the user
                    score = oracle.answer(sti)

                    # get the likelihoods for the scores
                    likelihood = []
                    for i in score:
                        dat = np.squeeze(i)
                        dens_0 = dist[0].score_samples(dat.reshape(1, -1))[
                            0]
                        dens_1 = dist[1].score_samples(dat.reshape(1, -1))[
                            0]
                        likelihood.append(np.asarray([dens_0, dens_1]))
                    likelihood = np.array(likelihood)
                    # compute likelihood ratio for the query
                    lr = np.exp(likelihood[:, 1] - likelihood[:, 0])

                    # initialize evidence with all ones
                    evidence = np.ones(len_alp)

                    c = 0
                    # update evidence of the queries that are asked
                    for q in sti:
                        idx = alp.index(q)
                        evidence[idx] = lr[c]
                        c += 1

                    # update posterior and decide what to do
                    prob = conjugator.update_and_fuse({'Eps': evidence})
                    prob_new = np.array([i for i in prob])
                    d, sti = decision_maker.decide(prob_new)
                    list_letter[method_count].append([sti])
                    list_prob[method_count].append([prob_new])

                    # print('\r State:{}'.format(decision_maker.state)),

                    if d:
                        try:
                            tmp_dist = list(np.array(
                                decision_maker.list_epoch[-2][
                                    'list_distribution'])[:,
                                            alp.index(oracle.state)])
                            target_dist[method_count].append(tmp_dist)
                        except:
                            import pdb

                            pdb.set_trace()

                        break
                # Reset the conjugator before starting a new epoch
                conjugator.reset_history()
                seq_till_correct[d_counter] += len(
                    decision_maker.list_epoch[-2]['list_sti'])
                if (decision_maker.list_epoch[-2][
                    'decision'] == oracle.state):
                    correct_sel += 1
                    d_counter += 1

                break
                # after decision update the user about the current delta
                oracle.update_state(decision_maker.displayed_state)

            seq_holder[method_count].append(seq_till_correct[0])
            bar_counter += 1

        acc_holder[method_count].append(1. * correct_sel / max_num_mc)
        method_count += 1
    print(np.mean(seq_holder, 1))
    print(acc_holder)

    # Prints the average number of sequences for each method
    if save_flag:
        np.savetxt(save_path + 'seq_sent_' + str(
            idx_phrase) + '.txt', np.array(seq_holder))
        np.savetxt(save_path + 'acc_sent_' + str(
            idx_phrase) + '.txt', np.array(acc_holder))
