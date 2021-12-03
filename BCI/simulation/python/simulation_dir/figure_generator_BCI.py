import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import pickle

eps = np.power(.1, 15)
data = pickle.load( open( "simulation_allDist.p", "rb" ) )
dist_mean = data['dist_mean']
dist_std = data['dist_std']
list_method = data['list_method']
target_loc = data['target_loc']
max_num_seq = data['max_num_seq']
min_num_seq = data['min_num_seq']
list_alpha = data['list_alpha']
accuracy = data['acc_holder']
lm_fixed_prior = data['lm_fixed_prior']

len_alp = 28
len_sentence = 3
len_query_methods = len(list_method)

target_color = [1, .38, 0.01]
ylim = [[0, 1.05], [0, 1.05], [0.5, 1.05]]

for loop in range(len(target_loc)):
    RenyiTitle = ['Renyi(' + str(i) + ')' for i in list_alpha]
    RenyiMomentum = ['Proposed(' + r'$\alpha=$'+ str(i) + ')' for i in list_alpha]
    list_method = ['Random'] + ['MMI'] + RenyiMomentum + ['Mixed']
    line_style_list = [':', '--', '-', '-.', '--', '-', '-.', ':', '--', '-',
                       '-.', '--', '-', '-.']
    color_list = ['k', 'g', 'b', 'm', 'c', 'r', 'k', 'g', 'b', 'm', 'c', 'r']

    # LM prior porbability
    lm_prior = lm_fixed_prior[loop]
    y_pos = np.arange(len_alp + 2)

    if loop == 0:
        lm_prior = np.array(
            [1. / (len_alp + 2) for a in range(len_alp + 2)]) + eps
    else:
        lm_prior = np.concatenate((np.zeros(2), lm_prior), 0)

    performance = np.array(lm_prior)
    # performance = np.flip(performance, 0)

    # Figure Settings
    gs = gridspec.GridSpec(4, len_sentence)
    gs.update(hspace=0.5, wspace=0.2)

    axs1 = plt.subplot(gs[3, loop])

    barlist = axs1.bar(y_pos, performance, align='center', color='black')
    axs1.set_xticks(y_pos)

    states = [r'$\sigma$' + r'$_{' + str(i) + r'}$' for i in
              range(1, len_alp + 2)]
    # axs1.set_xticklabels(states)
    axs1.set_ylabel(r'$p(\sigma|H_0)$', fontsize=12)

    axs1.set_xlabel(r'$State (\sigma)$', fontsize=12)

    # Hide the right and top spines
    axs1.spines['right'].set_visible(False)
    axs1.spines['top'].set_visible(False)
    barlist[target_loc[loop] + 2].set_color(target_color)
    axs1.xaxis.get_ticklabels()[target_loc[loop] + 2].set_color(target_color)
    axs1.xaxis.set_tick_params(labelsize=8)
    axs1.set_ylim([0, .6])
    axs1.set_xlim([-1, len_alp+2])

    axs2 = plt.subplot(gs[:-1, loop])

    mean_x = dist_mean[loop][0]
    std_x = dist_std[loop][0]

    for idx in range(len_query_methods):
        line_space_x = np.linspace(1, min_num_seq[loop][idx],
                                   min_num_seq[loop][idx])
        label = list_method[idx]
        line_style = line_style_list[idx]
        color = color_list[idx]
        axs2.fill_between(line_space_x, mean_x[idx] - std_x[loop][idx],
                          mean_x[idx] +
                          std_x[idx], facecolor=color, alpha=0.1)
        axs2.plot(line_space_x, mean_x[idx], color=color,
                  linestyle=line_style,
                  linewidth=2, label=label)
        # axs[pp_loc,fig_ind+d_subfig].set(adjustable='box-forced', aspect='equal')

    axs2.set_ylabel((r"$p(\sigma_{%i})$" % (target_loc[loop] + 2)), fontsize=14)
    axs2.set_xlabel('# Sequences', fontsize=14)
    # axs2.set_title((r"$\sigma= \sigma_{%i}$" % target_loc[loop]), fontsize=12)
    # Hide the right and top spines
    axs2.spines['right'].set_visible(False)
    axs2.spines['top'].set_visible(False)

    axs2.xaxis.set_tick_params(labelsize=14)

    axs2.legend(loc=0)
    axs2.set_xlim([1, max(max_num_seq[loop])])
    axs2.set_ylim(ylim[loop])


figure = plt.gcf()  # get current figure
figure.set_size_inches(18, 10)
plt.savefig('demo_plot.pdf', format='pdf', dpi=1000,
            bbox_inches='tight')


plt.show()




