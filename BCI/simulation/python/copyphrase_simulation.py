import os
from modules.oracle import BinaryRSVPOracle
from modules.progress_bar import progress_bar
import scipy.io as sio
from modules.main_frame import DecisionMaker, EvidenceFusion
from scipy.stats import norm, iqr
from sklearn.neighbors.kde import KernelDensity
from modules.main_frame import alphabet, taskVisuallization
from modules.language_model_folder.language_model_wrapper import \
    LanguageModelWrapper
from modules.query_methods import randomQuery, MomentumQueryingLog, \
    ReyniQuery, RenyiMomentumQuery
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

eps = np.power(.1, 7)
target_color = [1, .38, 0.01]
target_color2 = [1, .2, 0.]
filename = "AL12311987_IRB130107_ERPCalibration.mat"  # "AL12311987_IRB130107_ERPCalibration.mat"
path = "../data/"

# these are prior for letters 'O', 'C', 'R' extracting from the old MATLAB language model
# The goal is to type 'OCCURED' in the following phrase IT_OCCURED_RANDMOLY

alp = alphabet()
lam = [1., .01]
gam = 1
dlam = [0.000005, 1]
shift = [0, 0, 0]
len_query = 8
len_alp = len(alp)
evidence_names = ['LM', 'Eps']

sentence = ['IT_', 'IT_OC']
target_letter = ['O', 'IT_OCO']
fig, axs = plt.subplots(2, len(sentence), gridspec_kw={'wspace': 0.25})
fig.subplots_adjust(wspace=.35)
target_loc = [14, 2, 17]
target_loc = np.subtract(27, target_loc)
backspace_prob = 1. / 100.
bp_loc = 1
pp_loc = 0

abs_path_fst = os.path.abspath(
    "./modules/language_model_folder/fst/brown_closure.n5.kn"
    ".fst")
# lang_model = LanguageModelWrapper(abs_path_fst, alp=alp, backspace_prob=backspace_prob)

max_num_mc = 10
min_num_seq = [50, 50, 50]
max_num_seq = [50, 50, 50]
delta = 4.5

# query_methods = [NBestQuery(alp=alp), MomentumQueryingLog(alp=alp, gam=gam), onlyMomentum(alp=alp, gam=gam)]
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

alph = [.5, 1., 2,np.inf]

# Flag parameters
lm_flag = 0  # 1 if language model is active

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

# lm_fixed_prior = np.array([
#     [0.0597, 0.0315, 0.0584, 0.0507, 0.0293, 0.0307, 0.0290, 0.0681, 0.1167,
#      0.0264, 0.0125, 0.0302, 0.0546, 0.0236,
#      0.0092, 0.0350, 0.0249, 0.0400, 0.0619, 0.0405, 0.0155, 0.0093, 0.1414,
#      0.0001, 0.0006, 0.0002, 0.0001, 0.0001],
#     [0.0014, 0.0000, 0.8131, 0.0000, 0.0361, 0.0000, 0.0000, 0.0013, 0.0005,
#      0.0000, 0.0009, 0.0004, 0.0008, 0.0000,
#      0.0090, 0.0000, 0.0000, 0.0007, 0.0000, 0.0854, 0.0002, 0.0000, 0.0000,
#      0.0000, 0.0000, 0.0000, 0.0001, 0.0500],
#     [0.0000, 0.0001, 0.0000, 0.0000, 0.0001, 0.0000, 0.0000, 0.0000, 0.0001,
#      0.0000, 0.0000, 0.0328, 0.0005, 0.0000,
#      0.0000, 0.5304, 0.0000, 0.3822, 0.0027, 0.0001, 0.0000, 0.0000, 0.0000,
#      0.0000, 0.0000, 0.0009, 0.0000,
#      0.0500]]) + eps

ylim = [[0, 1.05], [.5, 1.05]]

for loop in range(len(sentence)):
    pre_phrase = sentence[loop]
    phrase = target_letter[loop]
    oracle = BinaryRSVPOracle(x, y, phrase=phrase, alp=alp)
    decision_maker = DecisionMaker(state='', len_query=len_query, alp=alp)
    decision_maker.min_num_seq = min_num_seq[loop]
    decision_maker.max_num_seq = max_num_seq[loop]

    # RenyiQuery = [ReyniQuery(alp=alp, len_query=len_query, alph=i) for i in
    #               alph]
    #
    # query_methods = [
    #     MomentumQueryingLog(alp=alp, len_query=len_query, gam=gam, lam=0.,
    #                         updateLam=False)]
    #
    # query_methods = RenyiQuery + query_methods

    query_methods = [randomQuery(query=alp, len_query=len_query),
                     RenyiMomentumQuery(query=alp, gam=gam, len_query=len_query,
                                        alph=alph[0], lam=0., updateLam=False),
                     RenyiMomentumQuery(query=alp, gam=gam, len_query=len_query,
                                        alph=alph[0], lam=lam[loop],
                                        dlam=dlam[loop],
                                        shift=shift[loop], updateLam=True),
                     RenyiMomentumQuery(query=alp, gam=gam, len_query=len_query,
                                        alph=alph[1], lam=lam[loop],
                                        dlam=dlam[loop],
                                        shift=0, updateLam=True),
                     RenyiMomentumQuery(alp=alp, gam=gam, len_query=len_query,
                                        alph=alph[2], lam=lam[loop],
                                        dlam=dlam[loop],
                                        shift=0, updateLam=True),
                     RenyiMomentumQuery(alp=alp, gam=gam, len_query=len_query,
                                        alph=alph[3], lam=lam[loop],
                                        dlam=dlam[loop],
                                        shift=0, updateLam=True)                     ]
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

    # fig, ax = plt.subplots()
    # x_plot = np.linspace(np.min(x), np.max(x), 1000)[:, np.newaxis]
    # ax.plot(x[y == 0],
    #         -0.005 - 0.01 * np.random.random(x[y == 0].shape[0]),
    #         'ro', label='class(-)')
    # ax.plot(x[y == 1],
    #         -0.005 - 0.01 * np.random.random(x[y == 1].shape[0]),
    #         'go', label='class(+)')
    # for idx in range(len(dist)):
    #     log_dens = dist[idx].score_samples(x_plot)
    #     ax.plot(x_plot[:, 0], np.exp(log_dens),
    #             'r-' * (idx == 0) + 'g--' * (idx == 1), linewidth=2.0)
    # plt.show()

    seq_holder = [[] for i in range(len(query_methods))]
    target_dist = [[] for i in range(len(query_methods))]
    l = max_num_mc * len(query_methods)
    progress_bar(0, l, prefix='Progress:', suffix='Complete', length=50)
    bar_counter = 0
    method_count = 0

    list_letter = [[] for i in range(len(query_methods))]
    list_prob = [[] for i in range(len(query_methods))]

    for query in query_methods:

        decision_maker.query_method = query
        sum_seq_till_correct = np.zeros(len(phrase))

        entropy_holder = []
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
                        dens_0 = dist[0].score_samples(dat.reshape(1, -1))[0]
                        dens_1 = dist[1].score_samples(dat.reshape(1, -1))[0]
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
                            target_dist[method_count].append(tmp_dist)
                        except:
                            import pdb

                            pdb.set_trace()

                        break
                # Reset the conjugator before starting a new epoch for clear history
                conjugator.reset_history()
                seq_till_correct[d_counter] += len(
                    decision_maker.list_epoch[-2]['list_sti'])
                if (decision_maker.list_epoch[-2]['decision'] == phrase[
                    d_counter] and
                        decision_maker.displayed_state == phrase[0:len(
                            decision_maker.displayed_state)]):
                    d_counter += 1

                break

            seq_holder[method_count].append(seq_till_correct)
            bar_counter += 1

        method_count += 1

    mean_x = []
    std_x = []
    for idx in range(len(query_methods)):
        method_tar = target_dist[idx]
        tmp = np.array(
            [method_tar[i][0:min_num_seq[loop]] for i in
             range(len(method_tar))])
        mean_x.append(np.mean(tmp, axis=0))
        std_x.append(.1 * np.sqrt(np.var(tmp, axis=0)))

    line_space_x = np.linspace(1, mean_x[0].shape[0], mean_x[0].shape[0])

    RenyiTitle = ['Renyi(' + str(i) + ')' for i in alph]
    RenyiMomentum = [r'$Proposed(\alpha=$' + str(i) + ')' for i in alph]
    list_method = ['Random'] + ['MMI'] + RenyiMomentum
    line_style_list = [':', '--', '-', '-.', '--', '-', '-.', ':', '--', '-',
                       '-.', '--', '-', '-.']
    color_list = ['k', 'g', 'b', 'm', 'c', 'r', 'k', 'g', 'b', 'm', 'c', 'r']

    # LM prior porbability
    y_pos = np.arange(len(alp) + 2)
    lm_prior = np.concatenate((np.zeros(2), lm_prior), 0)
    performance = np.array(lm_prior)
    performance = np.flip(performance, 0)

    # Figure Settings
    gs = gridspec.GridSpec(4, 2)
    gs.update(hspace=0.5, wspace=0.2)

    axs1 = plt.subplot(gs[3, loop])

    barlist = axs1.bar(y_pos, performance, align='center', color='black')
    axs1.set_xticks(y_pos)

    states = [r'$\sigma$' + r'$_{' + str(i) + r'}$' for i in
              range(1, len(alp) + 1)]
    # axs1.set_xticklabels(states)
    axs1.set_ylabel(r'$p(\sigma|H_0)$', fontsize=12)

    axs1.set_xlabel(r'$States (\sigma)$', fontsize=12)

    # Hide the right and top spines
    axs1.spines['right'].set_visible(False)
    axs1.spines['top'].set_visible(False)
    barlist[target_loc[loop]].set_color(target_color)
    axs1.xaxis.get_ticklabels()[target_loc[loop]].set_color(target_color2)
    axs1.xaxis.set_tick_params(labelsize=8)
    axs1.set_ylim([0, .6])

    axs2 = plt.subplot(gs[:-1, loop])

    for idx in range(len(query_methods)):
        label = list_method[idx]
        line_style = line_style_list[idx]
        color = color_list[idx]
        axs2.fill_between(line_space_x, mean_x[idx] - std_x[idx],
                          mean_x[idx] +
                          std_x[idx], facecolor=color, alpha=0.1)
        axs2.plot(line_space_x, mean_x[idx], color=color,
                  linestyle=line_style,
                  linewidth=2, label=label)
        # axs[pp_loc,fig_ind+d_subfig].set(adjustable='box-forced', aspect='equal')

    axs2.set_ylabel((r"$p(\sigma_{%i})$" % target_loc[loop]), fontsize=14)
    axs2.set_xlabel('# Sequences', fontsize=14)
    # axs2.set_title((r"$\sigma= \sigma_{%i}$" % target_loc[loop]), fontsize=12)
    # Hide the right and top spines
    axs2.spines['right'].set_visible(False)
    axs2.spines['top'].set_visible(False)

    axs2.xaxis.set_tick_params(labelsize=14)

    axs2.legend(loc=4)

    axs2.set_ylim(ylim[loop])

figure = plt.gcf()  # get current figure
figure.set_size_inches(18, 10)

# plt.savefig('occured_highAUC_1.pdf', format='pdf', dpi=1000,
#             bbox_inches='tight')

plt.show()
