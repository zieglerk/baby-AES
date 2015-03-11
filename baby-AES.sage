# CAVE: states are read and printed column-wise

# Given: mq.SR works with polynomials over rings and has methods for hex presentations
# Philosophy: compute with them, but print words and states as bitstrings
# Naming convention: lowercase x, y, k for bitstrings and X, Y, K for the corresponding states

# definition and parameters of baby-AES
# =====================================

rounds = 3
rows = 2
cols = 2    # 2x2 states
exponent = 4    # 4-bit words
aes = mq.SR(rounds, rows, cols, exponent, allow_zero_inversions=True, star=True)
# - allow_zero_inversions :: suppresses errors when the S-box does just that
# - star :: modifies the last round as specified for Rijndael, but some algebraic attacks might prefer differently

# to debug lin ca, we also define a 1 round and a 2 round version
aes1 = mq.SR(1, rows, cols, exponent, allow_zero_inversions=True, star=True)
aes2 = mq.SR(2, rows, cols, exponent, allow_zero_inversions=True, star=True)

F = aes.base_ring()
a = F.gen()



# TOOLBOX: string methods
# =======================
# Want: states are represented as lists of 4-bit strings
# CAVE: requires strings '0100', because 0100 is read as octal (64) and therefore fails to convert properly to binary

def h2b(hex):
    '''take a single hex digit and return the corresponding 4 bit string

    sage: h2b('A')
    '1010'
    '''
    integer = ZZ(int(hex,16))
    bits = integer.binary()
    return bits.zfill(4)

def d2b(dec):
    return ZZ(dec).binary().zfill(4)

def b2F(bits):
    '''transform 4-bits to an element of F

    sage: b2F('0101')
    a^2 + 1
    '''
    prefixed = int(str(bits),2)
    return F.fetch_int(prefixed)

def F2b(element):
    '''transform element of F into 4-bit string

    sage: F2b(a^2+1)
    '0101'
    '''
    integer = sage_eval(str(element), {'a':2})
    bits = integer.binary()
    return bits.zfill(4)

def scalarproduct(a, b):
    '''for two bitstring a and b we define the scalar product; this should be possible with native methods, but I can't turn a string of bits into a bitstring for which & works.'''
    selected = [int(a[i]) for i in range(len(b)) if b[i] == '1']
    return sum(selected)%2

def bitstring2state(bitstring):
    '''transform a list of 4 nibbles (each as string '0100') to the corresponding a 2x2 aes state matrix (colum-wise)'''
    return aes.state_array([b2F(bitstring[i]) for i in range(4)])

def state2bitstring(state):
    '''given a 2x2 aes state matrix, return a list of 4 nibbles'''
    hexstate = aes.hex_str(state, typ='vector')
    return [h2b(hexstate[i]) for i in range(4)]



# TOOLBOX: iterate over all states
# ================================

from itertools import *
all_states = product(F,repeat=4)
pairs_of_words = product(F,repeat=2)



# APPENDIX A: step-by-step AES
# ============================
# Motivation: To find intermediate states (and to have the option to randomize the key schedule)

def my_aes(X, K):
    '''for comparison -- and output of intermediate states -- step by step encryption of m with k

    sage: x = bitstring2state(['0000', '0000', '0000', '0000'])
    sage: k = bitstring2state(['0001','0001','0001','0001'])
    sage: my_aes(x,k)
    '''
    # initial round
    Y = aes.add_round_key(X, K)
    print Y
    # rounds 1 to rounds-1
    for r in range(1, rounds):
        K = aes.key_schedule(K, r)
        Y = aes.sub_bytes(Y)
        Y = aes.shift_rows(Y)
        Y = aes.mix_columns(Y)
        Y = aes.add_round_key(Y, K)
        print Y
    # last round
    K = aes.key_schedule(K, rounds)
    Y = aes.sub_bytes(Y)
    Y = aes.shift_rows(Y)
    Y = aes.add_round_key(Y, K)
    print Y
    return Y

def aes_rand(X, K):
    '''TODO: different/more non-linear key schedule???'''
    # initial round
    y = aes.add_round_key(x, k)
    # rounds 1 to rounds-1
    for r in range(1, rounds):
        k = aes.key_schedule(k, r)
        y = aes.sub_bytes(y)
        y = aes.shift_rows(y)
        y = aes.mix_columns(y)
        nil = aes.state_array()    # all zero intermediate roundkeys
        y = aes.add_round_key(y, nil)
    # last round
    k = aes.key_schedule(k, rounds)
    y = aes.sub_bytes(y)
    y = aes.shift_rows(y)
    y = aes.add_round_key(y, k)
    return y

'''
x = bitstring2state(['0001', '0000', '1010', '1011'])
k = bitstring2state(['1101','1100','1110','1111'])    # key1
my_aes(x,k) == aes(x,k)
'''


# APPENDIX B: step-by-step keyschedule
# ====================================
# Motivation: To check our description (and to display the targetted roundkey of the last round); TODO inverse keyschedule

# reference: Appendix A of CidMurphyRobshaw2005
# lk = # cols in secret key -> 2 for baby-AES, 4 for AES-128
# lr = # rounds (excluding initial round) -> 3 for baby-AES, 10 for AES-128
# requirement for key schedule:
# - lr+1 roundkeys or equivalently lk(lr+1) cols

# TODO: revert key schedule

# for comparsion the "official" key expansion
def key_expand(K, R=3):
    '''
    sage: key_schedule([0,0,0,0])
    [
    [0 0]  [a^2 + a + 1 a^2 + a + 1]  [        a   a^2 + 1]
    [0 0], [    a^2 + a     a^2 + a], [a^3 + a^2   a^3 + a],

    [  a^3 + 1 a^3 + a^2]
    [        a       a^3]
    ]

    sage: key_expand([0,1,a,a^2])
    [
    [  0   a]  [a + 1     1]  [      a^2 + a + 1           a^2 + a]
    [  1 a^2], [  a^2     0], [a^3 + a^2 + a + 1 a^3 + a^2 + a + 1],

    [  a^3 + a + 1 a^3 + a^2 + 1]
    [          a^3   a^2 + a + 1]
    ]
    '''
    E = [aes.state_array(list(K))]
    for r in range(1, R+1):
	E.append(aes.key_schedule(E[-1],r))
    return E

# my own step-by-step key expansion
def my_key_expand(K, R=3):
    '''
    IN: secret key k given as quadruple of field elements
    OUT: sequence of R+1 round keys -- each a quadruple of field elements

    sage: my_key_expand([0,0,0,0])
    [
    [0 0]  [a^2 + a + 1 a^2 + a + 1]  [          a     a^2 + 1]
    [0 0], [    a^2 + a     a^2 + a], [          1 a^2 + a + 1],

    [    a^3 + a^2       a^3 + 1]
    [      a^3 + a a^3 + a^2 + 1]
    ]

    sage: my_key_expand([0,0,0,0])
    [
    [0 0]  [a^2 + a + 1 a^2 + a + 1]  [      a     a^2]  [  1   1]
    [0 0], [    a^2 + a     a^2 + a], [      0 a^2 + a], [  a a^2]
    ]
    '''
    E = [aes.state_array(list(K))]
    for r in range(1, R+1):
        previous = E[-1]
        s0 = S(previous[1][1])
        s1 = S(previous[0][1])
        current = Matrix(F, 2, 2)    # use matrices instead of state_arrays because the former are mutable; but careful: Matrix is row-before-col
        q = 0    # left column
        current[0, q] += previous[0, q] + s0 + F(a)^(r-1)
        current[1, q] += previous[1, q] + s1
        q = 1    # right column
        current[0, q] += previous[0, q] + current[0, q-1]
        current[1, q] += previous[1, q] + current[1, q-1]
        E.append(current)
    return E

'''
sage: sr = mq.SR(10, 2, 2, 4, allow_zero_inversions=True, star=True)
sage: ki = sr.state_array()
sage: for i in range(10):
....: ki = sr.key_schedule(ki, i+1)
....:
sage: print sr.hex_str_matrix(ki)
 B 2
 4 0
'''
