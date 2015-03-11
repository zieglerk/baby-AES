r"""
Turn dictionary/dictionaries of frequencies into histogram (bar chart).

INPUT:

- ``file1`` -- .sobj-file containing first frequency distribution candidate keys.
- ``file2`` -- (default: none) .sobj-file containing second frequency distribution candidate keys.

OUTPUT:

- .eps-file of dictionary as bar chart.

EXAMPLES:

This is not optional::

    $ sage dict2hist.sage [filename]
    4
    $ sage dict2hist.sage [file1] [file2]
    <compare filtered and unfiltered>

AUTHORS:

- Konstantin Ziegler (2013-10-15): initial version
"""

import matplotlib.pyplot as plt
import numpy as np
import sys

var('a')

def F2b(element):
    '''
    COPY from baby-AES -> TODO from baby-AES import F2b

    transform element of F into 4-bit string

    sage: F2b(a^2+1)
    '0101'
    '''
    integer = sage_eval(str(element), {'a':2})
    bits = integer.binary()
    return bits.zfill(4)

def dict_to_hist(D1):
    '''input dictionary of candidates with counters, save resulting histogram'''
    LARGE = D1.items()
    # prepare x-values
    x_max = len(D1)
    X = np.arange(x_max)
    # prepare y-values
    LARGE.sort()
    Y_LARGE = np.array([l[1] for l in LARGE])
    # plot every 16th x-label
    Xpos = X[::16]
    Xlabels = np.array([ (F2b(data[0][0]) + ' ' + F2b(data[0][1])) for data in LARGE])[::16]
    plt.xticks(Xpos, (Xlabels), rotation='vertical', fontsize='small')
    # plt.xlabel('candidate keys')
    # plot Y vs. X
    plt.bar(X, Y_LARGE, width=1, color='r', align='center')
#    plt.bar(X, Y_small, width=1, color='g', linewidth=0, align='center')
    # plt.ylabel('associated counters')
    # rescale axes
#    ax = plt.gca()
#    ax.relim()
#    ax.autoscale_view()
    plt.xlim(-1,len(D1)+1)    # "manual alternative"
    # save result; raise dpi from default 100
    plt.savefig(str(file1)[:-5]+'.eps', dpi=600, bbox_inches='tight') # savefig overrides earlier dpi-settings with a default (100?); prevent that explicitely

def dicts_to_hist(D1, D2):
    '''input *two* dictionaries of frequencies, save resulting histogram'''
    assert len(D1) == len(D2)
    # sort the dictionaries by size and convert to lists of pairs
    if max(D1.values()) > max(D2.values()):
        LARGE = D1.items()
        small = D2.items()
    else:
        LARGE = D2.items()
        small = D1.items()
    # prepare x-values
    x_max = len(D1)
    X = np.arange(x_max)
    # prepare y-values
    LARGE.sort()
    small.sort()
    Y_LARGE = np.array([l[1] for l in LARGE])
    Y_small = np.array([l[1] for l in small])
    # plot every 16th x-label
    Xpos = X[::16]
    Xlabels = np.array([ (F2b(data[0][0]) + ' ' + F2b(data[0][1])) for data in LARGE])[::16]
    plt.xticks(Xpos, (Xlabels), rotation='vertical', fontsize='small')
    # plt.xlabel('candidate keys')
    # plot Y vs. X
    plt.bar(X, Y_LARGE, width=1, color='r', align='center')
    plt.bar(X, Y_small, width=1, color='g', linewidth=0, align='center')
    # plt.ylabel('associated counters')
    # rescale axes
    ax = plt.gca()
    ax.relim()
    ax.autoscale_view()
    #    plt.xlim(-1,len(L1)+1)    # "manual alternative"
    # save result; raise dpi from default 100
    plt.savefig(str(file1)[:17]+'.eps', dpi=600, bbox_inches='tight')

args = sys.argv
file1 = args[1]
D1 = load(file1)

if len(args) == 2:
    dict_to_hist(D1)
if len(args) == 3:
    file2 = args[2]
    D2 = load(file2)
    dicts_to_hist(D1, D2)
