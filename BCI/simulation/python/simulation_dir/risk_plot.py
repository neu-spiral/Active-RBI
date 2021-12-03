import os
from simulation.python.modules.progress_bar import progress_bar
from simulation.python.modules.oracle import BinaryRSVPOracle, \
    BinaryGaussianOracle
from simulation.python.modules.main_frame import DecisionMaker, EvidenceFusion
from simulation.python.modules.main_frame import alphabet, taskVisuallization
from simulation.python.modules.query_methods import randomQuery, \
    MomentumQueryingLog, ReyniQuery, RenyiMomentumQuery
from simulation.python.modules.stopping_criteria import RenyiMomentumStop, \
    RenyiStop
import scipy
import scipy.io as sio
import numpy as np
import pickle

# epsilon (a small number)
eps = np.power(.1, 7)

# System path parameters
abs_path_fst = os.path.abspath(  # language model path
    "./modules/language_model_folder/fst/brown_closure.n5.kn.fst")
save_name = "../out_dat/risk_query_stats_1.p"
idx_stop = 0
path = "../../data/"  # path to data (data should be in MATLAB)
path_save = "../fig/dat/individual/"  # path to save data
list_filename = os.listdir(path)[1:4]

# maximum number of sequences and minimum number of sequences for decision
min_num_seq = 1
max_num_seq = 130
# number of trials in a sequence (bathced querying)
len_query = 3

alp = alphabet()
len_alp = len(alp)  # length of alphabet

# List of query methods. If required, can be populated
list_alpha_query = [0, .1, .2, .5, .8, 1, 2, 5, 10, 100, np.inf]

list_query_method = [ReyniQuery(space_query=alp, len_query=len_query, alph=x)
                     for x in list_alpha_query]

# list_alpha = [np.inf, 10, 2, 1]
list_alpha_decision = [np.inf, 10, 2, 1]
list_tau = list(np.linspace(.3, .9, 20))
list_stopping_actor = [RenyiStop(alpha=x, tau=1) for x in list_alpha_decision]

evidence_names = ['LM', 'Eps']  # types of evidences during simulation_dir

# list_pre_phrase, list_target_phrase sizes need to match
list_pre_phrase = ['BOOK']  # what user have typed already
list_target_phrase = ['BOOKC']  # what user wants to type
backspace_prob = 1. / 100.  # probability of backspace at each sequence

# Flag parameters
lm_flag = 0  # 1 if language model is active
save_flag = 1  # 1 if findings will be saved afterwards
one_cycle_flag = 1  # 1 if system terminates after 1 sequence only

# fixed language model prior, in absence of language model
lm_fixed_prior = np.array([
    [0.0597, 0.0315, 0.0584, 0.0507, 0.0293, 0.0307, 0.0290, 0.0681, 0.1167,
     0.0264, 0.0125, 0.0302, 0.0546, 0.0236,
     0.0249, 0.0350, 0.0092, 0.0400, 0.0619, 0.0405, 0.0155, 0.0093, 0.1414,
     0.0001, 0.0006, 0.0002, 0.0001, 0.0001],
    [0.0014, 0.0000, 0.8131, 0.0000, 0.0361, 0.0000, 0.0000, 0.0013, 0.0005,
     0.0000, 0.0009, 0.0004, 0.0008, 0.0000,
     0.0090, 0.0000, 0.0000, 0.0007, 0.0000, 0.0854, 0.0002, 0.0000, 0.0000,
     0.0000, 0.0000, 0.0000, 0.0001, 0.0500],
    [0.0000, 0.0001, 0.0000, 0.0000, 0.0001, 0.0000, 0.0000, 0.0000, 0.0001,
     0.0000, 0.0000, 0.0328, 0.0005, 0.0000,
     0.0000, 0.5304, 0.0000, 0.3822, 0.0027, 0.0001, 0.0000, 0.0000, 0.0000,
     0.0000, 0.0000, 0.0009, 0.0000,
     0.0500]]) + eps

max_num_mc = 30  # maximum number of monte carlo simulations
delta = 1.  # amount of shift for positive distribution
sc_threshold = 10000  # remove redundant samples

conjugator = EvidenceFusion(evidence_names, len_dist=len_alp)
seq_stat_holder, acc_stat_holder, auc_stat_holder, itr_holder = [], [], [], []
alphabet = alphabet()
alphabet[-2] = '-'

# initialize bar-graph and length of iterations
len_exp = 1 * len(list_tau) * len(list_alpha_query)
len_bar = max_num_mc * len(list_target_phrase) * len_exp
progress_bar(0, len_bar, prefix='Progress:', suffix='Complete', length=50)
bar_counter = 0

index_user = 0
# accuracy, sequence_spend lists for the application
# all will have the shape [num_users x num_alpha x num_mc_samples]
acc_overall, seq_overall, target_posterior_overall, itr_overall = [], [], [], []

# filename = list_filename[0]
# # load filename and initialize the user from MATLAB file
# tmp = sio.loadmat(path + filename)
# x = tmp['scores']
# y = tmp['trialTargetness']
# auc_user = tmp['meanAuc'][0][0]
# auc_stat_holder.append(auc_user)
#
# # modify data for outliers
# y = y[x > -sc_threshold]
# x = x[x > -sc_threshold]
# y = y[x < sc_threshold]
# x = x[x < sc_threshold]
# x[y == 1] += delta

mean = np.array([1, 3])
std = np.array([.3, 1])

a = (1. / (2 * std[0] ** 2)) - (1. / (2 * std[1] ** 2))
b = (mean[1] / (std[1] ** 2)) - (mean[0] / (std[0] ** 2))
c = (mean[0] ** 2 / (2 * std[0] ** 2)) - (
        mean[1] ** 2 / (2 * std[1] ** 2) - np.log(std[1] / std[0]))

if a != 0:
    intersection = (-b + np.sqrt(b ** 2 - 4 * a * c)) / (2 * a)
    if mean[1] > intersection > mean[0]:
        pass
    else:
        intersection = (-b - np.sqrt(b ** 2 - 4 * a * c)) / (2 * a)
else:
    intersection = -c / b

h_0_0 = scipy.stats.norm(mean[0], std[0]).cdf(intersection)
h_1_1 = 1 - scipy.stats.norm(mean[1], std[1]).cdf(intersection)

# create the oracle for the user
oracle = BinaryGaussianOracle(mean, std, phrase='A', alp=alp)
#
# # create an EEG model that fits   the user explicitly
# bandwidth = 1.06 * min(np.std(x),
#                        iqr(x) / 1.34) * np.power(x.shape[0], -0.2)
# classes = np.unique(y)
# cls_dep_x = [x[np.where(y == classes[i])] for i in range(len(classes))]
# dist = []  # distributions for positive and negative classes
# for i in range(len(classes)):
#     dist.append(KernelDensity(bandwidth=bandwidth))
#
#     dat = np.expand_dims(cls_dep_x[i], axis=1)
#     dist[i].fit(dat)

for threshold in list_tau:

    tmp_p = np.ones(len_alp) * (1 - threshold) / len_alp
    tmp_p[0] = threshold

    # iterate over given phrases
    for idx_phrase in range(len(list_pre_phrase)):
        # initialize pre-phrase and phrase of the iteration
        pre_phrase = list_pre_phrase[idx_phrase]
        phrase = list_target_phrase[idx_phrase]
        oracle.phrase = phrase

        # create the oracle and the decision maker.
        decision_maker = DecisionMaker(state='', len_query=len_query, alp=alp)

        # arrays to hold sequence and accuracy information
        seq_holder, acc_holder = [], []
        # have shapes [num_alpha x num_mc_samples], [num_mc_samples]
        target_dist = [[] for idx_duplicate in range(len(list_alpha_query))]
        target_dif_entropy = [[] for idx_duplicate in
                              range(len(list_alpha_query))]
        target_dif_momentum = [[] for idx_duplicate in
                               range(len(list_alpha_query))]
        list_itr = [[] for idx_duplicate in range(len(list_alpha_query))]

        list_letter = [[] for idx_duplicate in range(len(list_alpha_query))]
        list_prob = [[] for idx_duplicate in range(len(list_alpha_query))]

        query_count = 0
        # for alpha in list_alpha:
        alpha_count = 0
        for query in list_query_method:

            decision_maker.query_method = query

            for stopping_actor in [list_stopping_actor[idx_stop]]:

                if stopping_actor.alpha == np.inf:
                    stopping_actor.tau = -np.log2(threshold)
                elif stopping_actor.alpha == 1:
                    stopping_actor.tau = -np.sum(tmp_p * np.log2(tmp_p))
                else:
                    stopping_actor.tau = 1. / (
                            1 - stopping_actor.alpha) * np.log2(
                        np.sum(np.power(tmp_p, stopping_actor.alpha)))

                decision_maker.stopping_actor = stopping_actor

                # Adjust maximum and minimum number of sequences before decision
                decision_maker.min_num_seq = min_num_seq
                decision_maker.max_num_seq = max_num_seq

                entropy_holder, seq_elapsed = [], []
                correct_sel = 0
                for idx in range(max_num_mc):
                    progress_bar(bar_counter + 1, len_bar, prefix='Progress:',
                                 suffix='Complete', length=50)

                    decision_maker.reset(state=pre_phrase)
                    oracle.reset()
                    oracle.update_state(decision_maker.displayed_state)

                    seq_till_correct = [0] * (len(phrase) - len(pre_phrase))
                    d_counter = 0
                    while decision_maker.displayed_state != phrase:

                        # update displayed state from the user
                        tmp_displayed_state = "_" + \
                                              decision_maker.displayed_state

                        lm_prior = lm_fixed_prior[idx_phrase]

                        # lm_prior[alp.index(phrase)] = np.power(.1, 3)
                        # lm_prior = lm_prior / np.sum(lm_prior)

                        prob = conjugator.update_and_fuse({'LM': lm_prior})
                        prob_new = np.array([i for i in prob])
                        d, sti = decision_maker.decide(prob_new)
                        list_letter[alpha_count].append([sti])

                        list_prob[alpha_count].append([prob_new])
                        while True:
                            # get answers from the user
                            score = oracle.answer(sti)

                            # get the likelihoods for the scores
                            likelihood = []
                            for i in score:
                                dat = np.squeeze(i)
                                dens_0 = 1 / (std[0] * np.sqrt(
                                    2 * np.pi)) * np.exp(
                                    - (dat - mean[0]) ** 2 / (2 * std[0] ** 2))
                                dens_1 = 1 / (std[1] * np.sqrt(
                                    2 * np.pi)) * np.exp(
                                    - (dat - mean[1]) ** 2 / (2 * std[1] ** 2))
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
                            list_letter[alpha_count].append([sti])
                            list_prob[alpha_count].append([prob_new])

                            # after decision update the user about the current delta
                            oracle.update_state(decision_maker.displayed_state)

                            if d:
                                tmp_dist = np.array(
                                    decision_maker.list_epoch[-2][
                                        'list_distribution'])
                                tmp_post = np.mean(tmp_dist, axis=0)
                                itr = (np.log2(len(alp)) + tmp_post * np.log2(
                                    tmp_post) + (1 - tmp_post) * np.log2(
                                    (np.maximum(eps, 1 - tmp_post)) / (
                                            len_alp - 1)))
                                target_dist[alpha_count].append(
                                    list(tmp_dist[:, alp.index(oracle.state)]))

                                ent = (-1) * tmp_dist * np.log2(tmp_dist)
                                ent = np.sum(ent, axis=1)
                                diff_ent = - ent[1:] + ent[:-1]

                                diff_m = tmp_dist[:-1] * (np.log(tmp_dist[1:]) -
                                                          np.log(tmp_dist[:-1]))
                                diff_m = np.sum(diff_m, axis=1)

                                target_dif_entropy[alpha_count].append(diff_ent)
                                target_dif_momentum[alpha_count].append(diff_m)
                                list_itr[alpha_count].append(itr)

                                break
                        # Reset the conjugator before starting a new epoch
                        # Starts the new task with a clear history
                        conjugator.reset_history()
                        seq_till_correct[d_counter] += len(
                            decision_maker.list_epoch[-2]['list_sti'])
                        if (decision_maker.list_epoch[-2]['decision'] == phrase[
                            len(list_pre_phrase[idx_phrase]) + d_counter] and
                                decision_maker.displayed_state == phrase[0:len(
                                    decision_maker.displayed_state)]):
                            correct_sel += 1
                            d_counter += 1

                        # if number of sequences is fixed then hold time series
                        if max_num_seq == min_num_seq:
                            asd = 1

                        if one_cycle_flag:
                            break

                    # store number of sequences spent for correct decision
                    seq_elapsed.append(seq_till_correct[0])
                    # one of the iterations is completed! update wait-bar
                    bar_counter += 1

                seq_holder.append(seq_elapsed)
                acc_holder.append(1. * correct_sel / max_num_mc)

                alpha_count += 1
            query_count += 1

    target_posterior_overall.append(target_dist)
    itr_overall.append(list_itr)
    seq_overall.append(seq_holder)
    acc_overall.append(acc_holder)
    index_user += 1

if save_flag:
    save_dictionary = {"sequence_overall": seq_overall,
                       "accuracy_overall": acc_overall,
                       "auc_overall": auc_stat_holder,
                       "target_posterior_overall": target_posterior_overall,
                       "list_tau": list_tau,
                       "list_alpha_query": list_alpha_query,
                       "alpha_decision": list_alpha_decision[idx_stop],
                       "list_h": [h_0_0, h_1_1]}
    pickle.dump(save_dictionary, open(save_name, "wb"))
