import os
from simulation.python.modules.oracle import BinaryRSVPOracle
from simulation.python.modules.progress_bar import progress_bar
import scipy.io as sio
from simulation.python.modules.main_frame import DecisionMaker, EvidenceFusion
from scipy.stats import norm, iqr
from sklearn.neighbors.kde import KernelDensity
from simulation.python.modules.main_frame import alphabet, taskVisuallization
from simulation.python.modules.stopping_criteria import RenyiMomentumStop
from simulation.python.modules.query_methods import randomQuery, \
    MomentumQueryingLog, ReyniQuery, RenyiMomentumQuery
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import pickle

eps = np.power(.1, 10)
target_color = [1, .38, 0.01]
target_color2 = [1, .2, 0.]
path = "../../data/"  # path to data (data should be in MATLAB)
list_filename = os.listdir(path)[1:21]
# filename = "AL12311987_IRB130107_ERPCalibration.mat"  # "AL12311987_IRB130107_ERPCalibration.mat"

# these are prior for letters 'O', 'C', 'R' extracting from the old MATLAB language model
# The goal is to type 'OCCURED' in the following phrase IT_OCCURED_RANDMOLY

alp = alphabet()
len_query = 8
len_alp = len(alp)
evidence_names = ['LM', 'Eps']
num_users = 2
sentence = ['IT_']
target_letter = ['O']
fig, axs = plt.subplots(2, len(sentence), gridspec_kw={'wspace': 0.25})
fig.subplots_adjust(wspace=.35)
# target_loc = [14, 2, 17]
# target_loc = np.subtract(27, target_loc)
target_loc = [12 for i in range(num_users)]
backspace_prob = 1. / 100.
bp_loc = 1
pp_loc = 0

abs_path_fst = os.path.abspath(
    "./modules/language_model_folder/fst/brown_closure.n5.kn"
    ".fst")
# lang_model = LanguageModelWrapper(abs_path_fst, alp=alp, backspace_prob=backspace_prob)


# min_num_seq = [[37, 24, 19, 23, 23, 50], [37, 24, 19, 23, 23, 50]]
#  [list(map(int, np.ones(6)*40)), list(map(int, np.ones(6)*40))]
# [[37, 24, 19, 23, 23, 50],[37, 24, 19, 23, 23, 50]]
# [37, 24, 19, 22.34, 23, 67]
# max_num_seq = [[37, 24, 19, 23, 23, 50], [37, 24, 19, 23, 23,
#                                           50]]  # [[37, 24, 19, 23, 23, 50],[37, 24, 19, 22, 23, 50]]  #[37, 24, 19, 22.34, 23, 67]

max_num_mc = 10
delta = 1

# query_methods = [NBestQuery(alp=alp), MomentumQueryingLog(alp=alp, gam=gam), onlyMomentum(alp=alp, gam=gam)]
conjugator = EvidenceFusion(evidence_names, len_dist=len_alp)

alphabet = alphabet()
alphabet[-2] = '-'

list_alpha = [1]
lam_query = [1, 1, 0]
lam_stopping = [0, 0.01, 0]
seq_lam = [5, 5]
gam = 1
dlam = [0, 0, 0]
tau_threshold = .9

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
    [0.0000, 0.0001, 0.0000, 0.0000, 0.0001, 0.0000, 0.0000, 0.0000, 0.0001,
     0.0000, 0.0000, 0.0328, 0.0005, 0.0000,
     0.0000, 0.5304, 0.0000, 0.3822, 0.0027, 0.0001, 0.0000, 0.0000, 0.0000,
     0.0000, 0.0000, 0.0009, 0.0000,
     0.0500]]) + eps

# P(l=1 | sigma , phi)
p_label = np.zeros((2, len(alp), len(alp)))
for c in range(2):
    p_label[1, :, :] = np.eye(len(alp))
    p_label[0, :, :] = 1 - p_label[1, :, :]

ylim = [[0, 1.05], [.5, 1.05]]
# ylim = [[0, 1.05], [0, 1.05]]

mean_acc = [[] for i in range(len(list_filename))]
mean_seq = [[] for i in range(len(list_filename))]
mean_ent_diff = [[] for i in range(len(list_filename))]
mean_itr = [[] for i in range(len(list_filename))]
file_count = 0

for filename in list_filename:
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

    tmp_p = np.ones(len_alp) * (1 - tau_threshold) / len_alp
    tmp_p[0] = tau_threshold

    num_query = 2 + len(list_alpha) + 1
    # min_num_seq = [[21,23,18,18,18],[10,4,3,3,4,4]]
    # max_num_seq = [[40,21,23,18,18,18],[10,4,3,3,4,4]]
    min_num_seq = [list(map(int, np.ones(num_query) * 2)),
                   list(map(int, np.ones(num_query) * 2))]
    max_num_seq = [list(map(int, np.ones(num_query) * 60)),
                   list(map(int, np.ones(num_query) * 60))]

    dist_mean = [[] for i in range(len(sentence))]
    dist_std = [[] for i in range(len(sentence))]

    for loop in range(len(sentence)):
        pre_phrase = sentence[loop]
        phrase = sentence[loop] + target_letter[loop]
        oracle = BinaryRSVPOracle(x, y, phrase=phrase, alp=alp)
        decision_maker = DecisionMaker(state='', len_query=len_query, alp=alp)

        query_methods = [randomQuery(space_query=alp, len_query=len_query),
                         RenyiMomentumQuery(space_query=alp, len_query=len_query,
                                            alph=1, lam=0.,
                                            update_lam_flag=False)]

        query_methods = query_methods + [RenyiMomentumQuery(space_query=alp,
                                                            len_query=len_query,
                                                            alph=list_alpha[ai],
                                                            lam=lam_query[loop],
                                                            dlam=dlam[ai],
                                                            update_lam_flag=True)
                                         for ai
                                         in range(len(list_alpha))]

        query_methods = query_methods + [RenyiMomentumQuery(space_query=alp,
                                                            len_query=len_query,
                                                            alph=.1,
                                                            lam=lam_query[loop],
                                                            dlam=dlam[0],
                                                            update_alpha_flag=True,
                                                            update_lam_flag=True)]

        stopping_methods = [
            RenyiMomentumStop(alpha=np.inf, lam=0., tau=tau_threshold),
            RenyiMomentumStop(alpha=np.inf, lam=0., tau=tau_threshold)]

        stopping_methods = stopping_methods + [
            RenyiMomentumStop(alpha=a, lam=lam_stopping[loop],
                              tau=tau_threshold)
            for a in
            list_alpha]

        stopping_methods = stopping_methods + [
            RenyiMomentumStop(alpha=list_alpha[0], lam=lam_stopping[loop],
                              tau=tau_threshold)]

        # RenyiMomentumQuery(alp=alp, gam=gam, len_query=len_query, alph=alph[2], lam=0., updateLam=False),
        # RenyiMomentumQuery(alp=alp, gam=gam, len_query=len_query, alph=alph[2], lam=lam, dlam=dlam[0], updateLam=True)]

        # this is the dummy eeg_modelling part
        bandwidth = 1.06 * min(np.std(x),
                               iqr(x) / 1.34) * np.power(x.shape[0], -0.2)
        classes = np.unique(y)
        cls_dep_x = [x[np.where(y == classes[i])] for i in range(len(classes))]
        dist = []

        for i in range(len(classes)):
            dist.append(KernelDensity(bandwidth=bandwidth))

            dat = np.expand_dims(cls_dep_x[i], axis=1)
            dist[i].fit(dat)

        seq_holder = [[] for i in range(len(query_methods))]
        acc_holder = [[] for i in range(len(query_methods))]
        target_dist = [[] for i in range(len(query_methods))]
        l = max_num_mc * len(query_methods)
        progress_bar(0, l, prefix='Progress:', suffix='Complete', length=50)
        bar_counter = 0
        method_count = 0

        list_letter = [[] for i in range(len(query_methods))]
        list_prob = [[] for i in range(len(query_methods))]
        target_dif_entropy = [[] for idx_duplicate in range(len(query_methods))]

        for method_ind in range(len(query_methods)):

            decision_maker.min_num_seq = min_num_seq[loop][method_ind]
            decision_maker.max_num_seq = max_num_seq[loop][method_ind]
            decision_maker.query_method = query_methods[method_ind]
            sum_seq_till_correct = np.zeros(len(phrase))

            decision_maker.stopping_actor = stopping_methods[method_ind]

            entropy_holder, seq_elapsed = [], []
            correct_sel = 0

            for idx in range(max_num_mc):

                progress_bar(bar_counter + 1, l, prefix='Progress:',
                             suffix='Complete',
                             length=50)

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
                        lm_prior = lm_fixed_prior[loop]
                    # lang_model.set_reset(tmp_displayed_state[idx_final_space + 1:])
                    # lang_model.set_reset(decision_maker.displayed_state.replace('_', ' '))
                    # lm_prior = lang_model.get_prob()

                    # lm_prior[alp.index(phrase)] = np.power(.1, 3)
                    # lm_prior = lm_prior / np.sum(lm_prior)

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

                        # after decision update the user about the current delta
                        oracle.update_state(decision_maker.displayed_state)

                        # print('\r State:{}'.format(decision_maker.state)),

                        if d:
                            try:
                                tmp_dist = list(np.array(
                                    decision_maker.list_epoch[-2][
                                        'list_distribution'])[:,
                                                alp.index(oracle.state)])
                                tmp_dist_all = np.array(
                                    decision_maker.list_epoch[-2][
                                        'list_distribution'])
                                target_dist[method_count].append(tmp_dist)

                                ent = (-1) * tmp_dist_all * np.log2(
                                    tmp_dist_all)
                                ent = np.sum(ent, axis=1)
                                diff_ent = - ent[1:] + ent[:-1]
                                target_dif_entropy[method_count].append(
                                    diff_ent)

                            except:
                                import pdb

                                pdb.set_trace()

                            break
                    # Reset the conjugator before starting a new epoch for clear history
                    conjugator.reset_history()
                    seq_till_correct[d_counter] += len(
                        decision_maker.list_epoch[-2]['list_sti'])
                    if (decision_maker.list_epoch[-2][
                        'decision'] == oracle.state):
                        correct_sel += 1
                        d_counter += 1

                    break

                seq_holder[method_count].append(seq_till_correct[0])
                bar_counter += 1

            acc_holder[method_count].append(1. * correct_sel / max_num_mc)
            method_count += 1

        # Prints the average number of sequences for each method
        print(np.mean(seq_holder, 1))
        print(acc_holder)
        min_seq = ([np.min([len(a) for a in target_dif_entropy[i]]) for i in
                    range(len(target_dif_entropy))])
        tmp_ent_diff = np.zeros(len(query_methods))
        itr = np.zeros(len(query_methods))
        for q in range(len(query_methods)):
            ent_diff = []
            ent_diff = np.array(
                [((target_dif_entropy[q][i][:min_seq[q]])) for i in
                 range(max_num_mc)])
            tmp_ent_diff[q] = np.mean(np.abs(np.mean(ent_diff, axis=0)))
            method_tar = target_dist[q]
            tmp = np.array(
                [method_tar[i][0:min_seq[q]] for i in
                 range(len(method_tar))])
            tmp = np.concatenate((lm_prior[target_loc[loop]] * np.ones(
                (1, min_seq[q])), tmp), 0)
            mean_p = np.mean(tmp, axis=0)[-1]
            itr[q] = mean_p * np.log(mean_p) + (1 - mean_p) * np.log(
                (1 - mean_p) / (len(alp) - 1)) + np.log(len(alp))

        mean_seq[file_count].append(np.mean(seq_holder, 1))
        mean_acc[file_count].append(acc_holder)
        mean_ent_diff[file_count].append(tmp_ent_diff)
        mean_itr[file_count].append(itr)
        file_count += 1

# pickle.dump({'dist_mean': dist_mean,'dist_std':dist_std,'list_method': list_method,
#              'target_loc': target_loc, 'max_num_seq': max_num_seq,
#              'min_num_seq':min_num_seq, 'list_alpha':list_alpha,
#              'acc_holder':acc_holder}, open("BCI_simulation.p", "wb"))
