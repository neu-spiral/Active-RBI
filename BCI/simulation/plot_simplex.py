import ternary
import numpy as np
import itertools
import pickle

eps = np.power(.1, 17)


def slope(P1, P2):
    return (P2[1] - P1[1]) / (P2[0] - P1[0])


def y_intercept(P1, slope):
    # y = mx + b
    return P1[1] - slope * P1[0]


def find_intersect(m1, b1, m2, b2):
    f = 0
    x = 0
    y = 0
    if m1 == m2:
        f = 1;
    # y = mx + b
    # Set both lines equal to find the intersection point in the x direction
    x = (b2 - b1) / (m1 - m2)
    # Now solve for y -- use either line, because they are equal here
    # y = mx + b
    y = m1 * x + b1
    return x, y, f


def line_intersect(p1_1, p1_2, p2_1, p2_2):
    slope_A = slope(p1_1, p1_2)
    slope_B = slope(p2_1, p2_2)
    y_int_A = y_intercept(p1_1, slope_A)
    y_int_B = y_intercept(p2_1, slope_B)
    x_int, y_int, f = find_intersect(slope_A, y_int_A, slope_B, y_int_B)

    if f == 1:
        return None
    else:
        return np.array([x_int, y_int])


def project_point(p):
    """
    Maps (x,y,z) coordinates to planar simplex.
    Parameters
    ----------
    p: 3-tuple
        The point to be projected p = (x, y, z)
    permutation: string, None, equivalent to "012"
        The order of the coordinates, counterclockwise from the origin
    """
    a = p[0]
    b = p[1]
    x = a + b / 2.
    y = np.sqrt(3) / 2. * b
    return x, y


def inv_project_point(x, y):
    """
    Maps (x,y,z) coordinates to planar simplex.
    Parameters
    ----------
    p: 3-tuple
        The point to be projected p = (x, y, z)
    permutation: string, None, equivalent to "012"
        The order of the coordinates, counterclockwise from the origin
    """
    p = np.zeros(3)
    p[1] = 2 / np.sqrt(3) * y
    p[0] = x - p[1] / 2
    p[2] = 1 - p[0] - p[1]
    return p


def shannon_entropy(p):
    """ Computes the Shannon Entropy at a distribution in the simplex.
        p(ndarray[float]): probability distribution
    """
    s = 0.
    for i in range(len(p)):
        try:
            s += p[i] * np.log2(p[i] + eps)
        except ValueError:
            continue
    return -s


def Renyi_entropy(p, threshold, alpha):
    """ Given the threshold, plots the Renyi entropy boundary
            Args:
                threshold(float): in [0.5,1] threshold for confidence
                tax(ternary.figure): figure to plot curves
    """
    tmp_p = np.ones(len(p)) * (1 - threshold) / (len(p) - 1)
    tmp_p[0] = threshold

    if alpha == 1:
        entropy = shannon_entropy(p)
        new_threshold = -np.sum(tmp_p * np.log2(tmp_p + eps))
    elif alpha == np.inf:
        entropy = -np.log2(np.max(p) + eps)
        new_threshold = -np.log2(threshold + eps)

    else:
        p_alpha = np.power(p, alpha)
        entropy = 1. / (1 - alpha) * np.log2(np.sum(p_alpha) + eps)
        new_threshold = 1. / (1 - alpha) * np.log2(
            np.sum(np.power(tmp_p, alpha)) + eps)

    return entropy, new_threshold


def l1_norm_to_u(p):
    """ Computes the l1 norm to uniform distribution in the simplex.
        p(ndarray[float]): probability distribution
    """
    s = 0.
    for i in range(len(p)):
        try:
            s += np.abs(p[i] - 1. / 3)
        except ValueError:
            continue
    return s


def walk(num_dims, samples_per_dim):
    """ A generator that returns lattice points on an n-simplex.
    """
    values = 1. * np.arange(samples_per_dim) / (samples_per_dim - 1)
    for items in itertools.product(values, repeat=num_dims + 1):
        if sum(items) == 1.0:
            yield items


def plot_function_curves(threshold, function, tax, alpha=1, resolution=201,
                         linewidth=1., color='black', linestyle='-',
                         label=None):
    """ Given the threshold, plots the Shannon entropy curves.
        Args:
            threshold(float): in [0.5,1] threshold for the entropy
            function(str): name of the function to be used
            tax(ternary.figure): figure to plot curves
    """
    list_grid = list(walk(2, resolution))
    list_items = []

    if function == 'shannon':
        for el in list_grid:
            ent_el = shannon_entropy(np.array(el))
            if np.abs(ent_el - threshold) < .002:
                list_items.append(el)
    if function == 'Renyi':
        for el in list_grid:
            ent_el, new_threshold = Renyi_entropy(np.array(el), threshold,
                                                  alpha)
            if np.abs(ent_el - new_threshold) < .0005:
                list_items.append(el)

    if function == 'l1':
        for el in list_grid:
            ent_el = l1_norm_to_u(np.array(el))
            if np.abs(ent_el - threshold) < .005:
                list_items.append(el)

    list_items = np.array(list_items)
    tmp = list_items[np.where(list_items[:, 0] > list_items[:, 1])[0]]
    tmp = tmp[np.where(tmp[:, 1] > tmp[:, 2])[0]]

    tmp = np.concatenate((tmp, tmp[:, [0, 2, 1]][::-1]), axis=0)
    if np.any(tmp[:, 2] <= 2. / resolution):
        tax.plot(tmp, marker=None, color=color, linewidth=linewidth,
                 linestyle=linestyle, label=label)
        tax.plot(tmp[:, [1, 0, 2]], marker=None, color=color,
                 linewidth=linewidth, linestyle=linestyle)
        tax.plot(tmp[:, [2, 1, 0]], marker=None, color=color,
                 linewidth=linewidth, linestyle=linestyle)
    else:
        tmp_2 = np.concatenate((tmp, tmp[:, [2, 1, 0]][::-1],
                                tmp[:, [1, 0, 2]][::-1], [tmp[0, :]]), axis=0)
        tax.plot(tmp_2, marker=None, color=color, linewidth=linewidth,
                 linestyle=linestyle, label=label)

    # tmp_2 = np.concatenate((tmp, tmp[:, [2, 1, 0]][::-1],
    #                         tmp[:, [1, 0, 2]][::-1], [tmp[0, :]]), axis=0)
    # tax.plot(tmp_2, marker=None, color=color, linewidth=linewidth)


def plot_threshold_lines(threshold, tax, linewidth=1.):
    """ Given the threshold, plots the Renyi entropy infinity lines.
            Args:
                threshold(float): in [0.5,1] threshold for confidence
                tax(ternary.figure): figure to plot curves
    """
    tax.horizontal_line(threshold, linewidth=linewidth, color='black')
    tax.left_parallel_line(threshold, linewidth=linewidth, color='black')
    tax.right_parallel_line(threshold, linewidth=linewidth, color='black')


def plot_single_query(prob_point, query, tax):
    """ Given the probability point(s), plots a scatter plot of points. If there
        are more than one point, it can draw line between two points.
            Args:
                tax(ternary.figure): figure to plot curves
    """
    # query = np.expand_dims(query, axis=0)
    states = np.array([[1, 0, 0], [0, 1, 0], [0, 0, 1], [1, 0, 0]])
    px_0, py_0 = project_point(prob_point[0])
    vect_sum = np.array([0, 0])
    for i in range(len(states) - 1):
        sx, sy = project_point(states[i])
        vect = np.array([sx, sy]) - np.array([px_0, py_0])
        vect = vect / np.linalg.norm(vect) * query[i]
        vect_sum = vect_sum + vect

    query = vect_sum + [px_0, py_0]
    intersect_prob_points = []
    for i in range(len(states) - 1):
        sx0, sy0 = project_point(states[i])
        sx1, sy1 = project_point(states[i + 1])
        intersect_point = line_intersect([px_0, py_0], query, [sx1, sy1],
                                         [sx0, sy0])
        if intersect_point is not None:
            p1 = inv_project_point(intersect_point[0], intersect_point[1])
            p1 = np.array(
                [0 if np.abs(p_value) < 1e-15 else p_value for p_value in p1])
            notProb_flag = True
            negative_flag = [False if p_value < 0 else True for p_value in p1]
            if sum(p1) > 1:
                notProb_flag = False
            if all(negative_flag) and notProb_flag:
                intersect_prob_points.append(p1)

    p_query = inv_project_point(query[0], query[1])
    intersect_prob_points = np.array(intersect_prob_points)

    for s in states[:-1]:
        tax.line(prob_point[0], s, linewidth=.5, color='gray', linestyle="--")

    for point in intersect_prob_points:
        tax.line(prob_point[0], point, linewidth=.5, color='blue',
                 linestyle="--")

    tax.scatter(states, marker='o', color='green', label="States", s=20)
    tax.scatter(prob_point, marker='s', color='red', label="P", s=20)
    tax.scatter(intersect_prob_points, marker='o', color='black', s=8)
    tax.scatter([p_query], marker='o', color='black', s=8)


def plot_probability_points(prob_points, tax, drawline=True):
    """ Given the probability point(s), plots a scatter plot of points. If there
        are more than one point, it can draw line between two points.
            Args:
                prob_points(float): an array or matrix. 3xN
                tax(ternary.figure): figure to plot curves
                drawline: a boolean flag for drawing lines between points
    """
    N = prob_points.shape[1]
    if drawline and N > 1:
        for n in range(N):
            tax.line(prob_points[n, :], prob_points[n + 1, :], linewidth=.5,
                     marker='s', color='blue', markersize=3)
    else:
        tax.scatter(prob_points, marker='s', color='green', markersize=2)


# main
# Defines the range of the simplex axis, e.g. for probability simplex it should
# be 1.
scale = 1
# Posterior threshold
tau = .8
# Visualization resolution
resolution = 501
linewidth = 2
# Projection matrix from query to state space
query_projection = np.array([[1, 0, 0],
                             [0, 0, 1],
                             [0, 1, 0],
                             [.5, .5, 0],
                             [.5, 0, .5],
                             [0, .5, .5],
                             [.7, .2, .1],
                             [.1, .7, .2],
                             [.2, .1, .7]])
# Initial probability point
prob = np.array([[.05, .2, .75]])
# selected query
pick_query = 6

# prob_points = np.array([[.05, .2, .75],[.1, .4, .5],[.35, .5, .15],[.7, .2, .1]])
# Renyi entropy threshold according to the posterior threshold
tau_prime = -tau * np.log2(tau) - (1 - tau) * np.log2((1 - tau) / 2)

figure, tax = ternary.figure(scale=scale)
tax.boundary(linewidth=linewidth)
ax = tax.get_axes()
ax.axis('off')

alpha = [.05, .5, 1., 5]
color = ['lightcoral', 'mediumseagreen', 'c', 'goldenrod', 'orchid', 'y', 'r', 'g', 'b', 'm', 'c', 'r']
# list_linestyle = [(0, (1, 10)), ':', '-.', '--', (0, (3, 1, 1, 1, 1, 1))]
# plot_function_curves(tau_prime, 'shannon', tax, resolution=resolution,
#                      linewidth=linewidth)

tax.horizontal_line(tau, linewidth=linewidth, color='black')
tax.left_parallel_line(tau, linewidth=linewidth, color='black')
tax.right_parallel_line(tau, linewidth=linewidth, color='black')
for a in range(len(alpha)):
    print(a)
    plot_function_curves(tau, 'Renyi', tax, alpha=alpha[a],
                         resolution=resolution,
                         linewidth=linewidth, color=color[a],
                         linestyle='-',
                         label='a=' + str(alpha[a]))

# plot_single_query(prob, query_projection[pick_query,:], tax)
# tax.set_title("Probability simplex")
tax.legend()
tax.show()
