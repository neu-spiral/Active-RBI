from __future__ import division, print_function
from modules.query_methods import MomentumQuerying
import matplotlib.pyplot as plt
from matplotlib import gridspec
from matplotlib import animation
import numpy as np


left, width = .5, .5
bottom, height = .5, .5
right = left + width
top = bottom + height

def taskVisualization(posterior, query, alp):

    x = np.arange(len(alp))
    fig = plt.figure(figsize=(8, 6))
    gs = gridspec.GridSpec(1, 2, width_ratios=[3, 1])
    # ax1
    ax1 = plt.subplot(gs[0])
    ax1.set_xticks(x)
    # Hide the right and top spines
    ax1.spines['right'].set_visible(False)
    ax1.spines['top'].set_visible(False)
    # Only show ticks on the left and bottom spines
    ax1.yaxis.set_ticks_position('left')
    ax1.xaxis.set_ticks_position('bottom')
    ax1.set_xticklabels(alp)
    ax1.set_title('Posterior Probability')
    ax1.set_ylabel('Probability')
    ax1.set_xlabel('Symbols')
    plot1 = ax1.bar(x, posterior, color=[0., 0., 0.])
    # ax2
    ax2 = plt.subplot(gs[1], aspect=1)
    # Hide the right and top spines
    ax2.spines['right'].set_visible(False)
    ax2.spines['left'].set_visible(False)
    ax2.spines['top'].set_visible(False)
    ax2.spines['bottom'].set_visible(False)
    ax2.set_xticks([])
    ax2.set_yticks([])
    #ax2.axis('off')
    ax2.set_facecolor((0., 0., 0.))
    # build a rectangle in axes coords
    left, width = .25, .5
    bottom, height = .25, .5
    right = left + width
    top = bottom + height
    # placing the query in the middle fo the screen
    ax2.axis('equal')
    # show the plot
    mng = plt.get_current_fig_manager()
    figS = np.array(mng.window.maxsize())*np.array([.5, .4])
    figSize = tuple(figS.astype(int))
    mng.resize(*figSize)
    plot2 = ax2.text(0.5*(left+right), 0.5*(bottom+top), query,
                        horizontalalignment='center',
                        verticalalignment='center',
                        fontsize=40, color='yellow',
                        transform=ax2.transAxes)


    return fig, plot1, plot2

def makeMovie(posterior, query, alp):

    fig, plot1, plot2 = taskVisualization(np.zeros(len(alp)), '', alp)

    def init():
        _, plot1, plot2 = taskVisualization(np.zeros(len(alp)), '+', alp)
        return plot1, plot2

    def animate(i):

        len_query = len(query[i])
        p = posterior[i]
        max_p_val = np.sort(p)[::-1]
        max_p_val = max_p_val[0:len_query]

        if i == 0:
            for rect, y in zip(plot1, posterior[i][0]):
                rect.set_height(y)
                plot2.set_text('')
        else:
            for rect, y in zip(plot1, posterior[i][0]):
                rect.set_height(y)
                plot2.set_text(query[i][0])

        return plot1, plot2

    # call the animator.  blit=True means only re-draw the parts that have changed.
    anim = animation.FuncAnimation(fig, animate, init_func=init,
                               frames=50, interval=20, blit=True)
    plt.rcParams['animation.ffmpeg_path'] ='C:\\Users\\Yeganeh\\ffmpeg\\bin\\ffmpeg.exe'
    FFwriter = animation.FFMpegWriter(fps=30, extra_args=['-vcodec', 'libx264'])

    plt.show()
    anim.save('test.mp4', writer = FFwriter)








