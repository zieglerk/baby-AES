r"""
Find a good differential trail

<optional long description>

INPUT:

- ``param1`` -- (default: foo) type of param1.
- ``param2`` -- type of param2.

OUTPUT:

- description of output.

EXAMPLES:

Show me the init::

    sage: 2+2
    4

AUTHORS:

- Konstantin Ziegler (2013-10-16): initial version

"""
#*****************************************************************************
#       Copyright (C) 2013 Konstantin Ziegler <zieglerk@bit.uni-bonn.de>
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  http://www.gnu.org/licenses/
#*****************************************************************************


load('baby-AES.sage')

dx = ['0110','0000','0000','1000']
du1 = ['0110','0000','0000','1000']
du2 = ['1110','0000','0000','0000']
du3 = ['1010','1100','0000','0000']
dy = ['0001','0000','0000','1111']

delta = [dx,dy]

M = S.difference_distribution_matrix()

def p_S(dx,dy):
    '''return the propagation ratio for dx->dy through SubBytes'''
    pSubBytes = [ M[int(dx[i],base=2),int(dy[i],base=2)]/M[0,0] for i in srange(4)]
    return prod(pSubBytes)

def prop_ratio(du1, du2, du3):
    '''return propagation ratio of 2-round differential du1->du3 along the path du1->du2->du3'''
    dU2 = bitstring2state(du2)
    dV1 = aes.shift_rows(aes.mix_columns(dU2))
    dv1 = state2bitstring(dV1)
    dU3 = bitstring2state(du3)
    dV2 = aes.shift_rows(aes.mix_columns(dU3))
    dv2 = state2bitstring(dV2)
    return p_S(du1,dv1)*p_S(du2,dv2)

def most_likely_word(dx):
    '''return the most likely answer of the S-Box on input dx'''
    row = M[int(dx,base=2)].list()
    return d2b(row.index(max(row)))

def sample_word(dx):
    '''randomly return output differential dy on input differential dx according to the S-Box's probability distribution'''
    row = M[int(dx,base=2)].list()
    X = GeneralDiscreteDistribution(row)
    return d2b(X.get_random_element())

def most_likely_state(dx):
    '''given a list of four words, return the list of most likely words after calling SubBytes'''
    return [most_likely_word(word) for word in dx]

def sample_state(dx):
    '''given a list of four words, randomly return a state after SubBytes according to the S-Boxs' probability distribution'''
    return [sample_word(word) for word in dx]

print 'check that dy is the most likely state:', dy == most_likely_state(dx)

# run dx through the first 2 rounds

print 'starting with dx as above, we enter the first ronud with\n',
prob = 1
print 'u1 =', dx
print 'after SubBytes the most likely state is (see above)\n',
v1 = most_likely_state(dx)
prob = prob*p_S(dx,v1)
print 'v1 =', v1
print 'after SR and MC this transitions into\n',
V1 = bitstring2state(v1)
W1 = aes.mix_columns(aes.shift_rows(V1))
w1 = state2bitstring(W1)
print 'w1 =', w1
print 'after SubBytes the most likely state is\n',
v2 = most_likely_state(w1)
prob = prob*p_S(w1,v2)
print 'v2 =', v2
print 'after SR and MC this transitions into\n',
V2 = bitstring2state(v2)
W2 = aes.mix_columns(aes.shift_rows(V2))
w2 = state2bitstring(W2)
print 'w2 =', w2
# w2 = ['1010', '1100', '0000', '0000']
print 'and this is u3, the state difference at the beginnig of round 3'
print 'the expected propagation ratio of this differential characteristic is', prob

# Appendix A: find all differentials with maximal "expected propagation ratio"

def find_max():
    '''find all differential characteristics with maximal "expected propagation ratio"'''
    '''ignore the trivial differential, and filter for least number of active words in last round'''
    max_prob = 0
    max_char = []
    max_weight = 4
    for dX in all_states:
        dx = state2bitstring(aes.state_array(list(dX)))
        prob = 1
        v1 = most_likely_state(dx)
        prob = prob*p_S(dx,v1)
        V1 = bitstring2state(v1)
        W1 = aes.mix_columns(aes.shift_rows(V1))
        w1 = state2bitstring(W1)
        v2 = most_likely_state(w1)
        prob = prob*p_S(w1,v2)
        V2 = bitstring2state(v2)
        W2 = aes.mix_columns(aes.shift_rows(V2))
        w2 = state2bitstring(W2)
        weight = 4-w2.count('0000')
        if max_prob < prob < 1:
            max_prob = prob
            max_char = []
            max_weight = weight
        if prob == max_prob:
            if weight == max_weight:
                max_char.append([dx,w2])
            if 0 < weight < max_weight:
                max_char = [[dx,w2]]
                max_weight = weight
    return max_char, max_prob

# Appendix B : computing the true propagation ratio of dx -> w2 (assuming independent roundkeys)
# find all trails that yield the given differential

def all_trails(du1, du3):
    '''find all differential trails du1->du2->du3 for the 2-round differential du1->du3 with corresponding propagation ratio'''
    intermediate_states = {}
    for dU2 in all_states:
        print dU2
        du2 = state2bitstring(aes.state_array(list(dU2)))
        print du2
        if prop_ratio(du1, du2, du3) > 0:
            intermediate_states[str(du2)] = prop_ratio(du1,du2,du3)
    return intermediate_states

# Appendix C: computing the true propagation ratio of dx -> w2 (for a fixed key)
# running over all (x,x^*) in D(Delta(x))

# TODO
