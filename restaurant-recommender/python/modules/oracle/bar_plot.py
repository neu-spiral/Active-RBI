import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from io import StringIO

values_1 = [0.8278, 0.8108]
values_2 = [8.6050, 7.8753]

fig = plt.figure()  # Create matplotlib figure

ax = fig.add_subplot(211)  # Create matplotlib axes
ax2 = ax.twinx()  # Create another axes that shares the same x-axis as ax.
ax.set_ylim(0,1)

width = 0.1

ax.bar(x=[0], height=values_1[0], color='black', width=width)
ax.bar(x=[.4], height=values_1[1], color='black', width=width)
ax2.bar(x=[.1], height=values_2[0], color='gray', width=width)
ax2.bar(x=[.5], height=values_2[1], color='gray', width=width)

ax.set_ylabel('Accuracy')
ax2.set_ylabel('# Sequences')

plt.show()
