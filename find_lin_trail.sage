'''
We can only afford linear trails with 1 or 2 active words as input to the last round.  We choose them to be the first and the first two words, respectively.  This leaves the following two options for linear trails

XXXX    X00X
XX00 or X000
X000    XX00

with 6 and 3 active S-Boxes, respectively.  We try and find good trails in both of them, i.e. magnitude 2^-6 and 2^-3, respectively.  There are 960 of the former and 120 of the latter kind.

OUR CHOICE: the latter trails since 2^-3 is better than 2^-6
'''

load('baby-AES.sage')

lin_trails=[
[['0010', '0000', '0000', '1000'],
 ['1001', '0000', '0000', '0000'],
 ['0111', '1101', '0000', '0000']],    # 2-1-2 with 2^-3
[['0001', '0000', '0000', '1001'],
 ['0101', '0000', '0000', '0000'],
 ['1101', '1011', '0000', '0000']],    # 2-1-2 with 2^-3
[['0010', '0010', '1000', '0110'],
 ['1101', '0000', '0000', '1001'],
 ['0101', '0000', '0000', '0000']],    # 4-2-1 with 2^-6
[['0001', '0001', '1001', '1101'],
 ['1111', '0000', '0000', '0101'],
 ['0111', '0000', '0000', '0000']],    # 4-2-1 with 2^-6
]

M = S.linear_approximation_matrix()

def rho_SB(a, b):
    r'''
    return correlation of state selection mask a || b on SubBytes

    EXAMPLES::

        sage: a0 = ['0000','0000','0000','0000']
        sage: b0 = a0[:]
        sage: rho_SB(a0,b0)
        1

    ::

        sage: a1 = ['0100','0100','0001','0001']
        sage: b1 = ['1001','1001','1000','1000']
        sage: rho_SB(a1,b1)
        1/16

    ::

        sage: a2 = ['0010','0010','1000','1000']
        sage: b2 = ['0011','0011','0010','0010']
        sage: rho_SB(a2,b2)
        1/16

    '''
    pSubBytes = [ M[int(a[i],base=2),int(b[i],base=2)]/M[0,0] for i in srange(4)]
    return prod(pSubBytes)

def rho_SRMC(InputMask, OutputMask, num = 1024):
    '''
    testing InputMask, OutputMask on SRMC -- apparently, simply b = SR(MC(a)) fails.  We expect a counter of 1024 for the "correct" one.

    sage: b1 = ['0000','0101','0110','0000']
    sage: c1 = ['0000', '0000', '0000', '0011']

    sage: b2 = ['0000','0000','0000','0001']
    sage: c2 = ['0010','0011','0000','0000']
    -30

    sage: b2 = ['0000','0000','0000','0001']
    sage: c2 = ['1000', '1001', '0000', '0000']
    1024
    '''
    counter = 0
    for _ in range(num):
        X = aes.random_state_array()
        xraw = state2bitstring(X)
        Y = X
#        Y = aes.sub_bytes(Y)
        Y = aes.shift_rows(Y)
        Y = aes.mix_columns(Y)
        yraw = state2bitstring(Y)
	InputSum = sum(scalarproduct(InputMask[i], xraw[i]) for i in range(4))%2
	OutputSum = sum(scalarproduct(OutputMask[i], yraw[i]) for i in range(4))%2
        if (OutputSum + InputSum)%2 == 0:
            counter += 1
        else:
            counter -= 1
    return counter

def mc(b):
    '''Return mask such that <b | MC(x)> = <mc(b) | x>.'''
    a = []
    for col in range(2):
        for row in range(2):
            index = 2*col+row
            neighbor = 2*col+1-row
            word = ''
            for pos in range(3,-1,-1):
                if pos == 3:
                    bit = (int(b[index][0])+int(b[index][2])+int(b[index][3]) + int(b[neighbor][2]) + int(b[neighbor][3]))%2    # b13+b11+b10+b21+b20
                if pos == 0 or pos == 1 or pos == 2:
                    bit = (int(b[index][3-pos]) + int(b[index][2-pos]) + int(b[neighbor][2-pos]))%2    # b13+b12+b23
                word = word + str(bit)
            a.append(word)
    return [a[0],a[1],a[2],a[3]]

def inv_mc(a):
    '''Given a = mc(b), recover b.

    sage: mix_mask(['0000','0000','0000','0001'])
    ['0010', '0011', '0000', '0000']

    TODO make this faster.
    '''
    for B in product(F, repeat=4):
        b = state2bitstring(aes.state_array(list(B)))
        if mc(b) == a:
            return b

def inv_SRMC(b):
    '''
    sage: inv_SRMC(['1000', '1001', '0000', '0000'])
    ['0000', '0000', '0000', '0001']
    '''
    a = mc(b)
    return [a[0], a[3], a[2], a[1]]

def MC(a):
    return inv_mc(a)

def SRMC(a):
    '''
    sage: SRMC(['0000','0000','0000','0001'])
    ['1000', '1001', '0000', '0000']
    '''
    b = [a[0], a[3], a[2], a[1]]    # SR(a)
    return MC(b)

def rho_2(a1,a2,a3):
    r'''
    return lower bound on absolute value of correlation for 2-round linear trail a1 || a2 || a3

    EXAMPLES::

        sage: a1 = ['0010','0010','1000','1000']
        sage: a2 = ['0001','0000','0000','0001']
        sage: a3 = ['1000','1000','0000','0000']
        sage: rho_2(a1,a2,a3)
        1/1024

    '''
    b1 = inv_SRMC(a2)
    abs_corr1 = abs(rho_SB(a1,b1))
    b2 = inv_SRMC(a3)
    abs_corr2 = abs(rho_SB(a2,b2))
    return abs_corr1*abs_corr2

def all_trail_correlation(a1, a3):
    '''find the exact correlation of a1 || a3 assuming independent roundkeys by summing (with signs!) over all trails a1 || * || a3'''
    corr = 0
    for A2 in all_states:
        a2 = state2bitstring(aes.state_array(list(A2)))
        corr += rho_2(a1,a2,a3)
    return corr

def test_trail(InputMask, OutputMask, num=1024):
    '''try num samples for two round and check correlation for InputMask/OutptMask
    '''
    counter = 0
    for _ in range(num):
        X = aes.random_state_array()
        xraw = state2bitstring(X)
        Y = X
        Y = aes.sub_bytes(Y)
        Y = aes.shift_rows(Y)
        Y = aes.mix_columns(Y)
#        Y = aes.mix_columns(aes.shift_rows(aes.sub_bytes(Y)))
#        Y = aes.mix_columns(aes.shift_rows(aes.sub_bytes(Y)))
        yraw = state2bitstring(Y)
	InputSum = sum(scalarproduct(InputMask[i], xraw[i]) for i in range(4))%2
	OutputSum = sum(scalarproduct(OutputMask[i], yraw[i]) for i in range(4))%2
        if (OutputSum + InputSum)%2 == 0:
            counter += 1
        else:
            counter -= 1
    return counter

def find_trail(active=2):
    '''find linear trail a1 || a2 || a3 over two rounds with ``active`` active words in a3'''
    '''ignore the zero trail and filter for large (estimated) magnitude of correlation'''
    counter = 0
    max_abs_corr = 0
    max_trail = []
    for A1half in product(F, repeat=2):
        counter += 1
        print 'loop number ', counter
        print 'relative loop ', counter/2^8
        A1 = (A1half[0], F(0), F(0), A1half[1])
        a1 = state2bitstring(aes.state_array(list(A1)))
        for A2quarter in F:
            A2 = (A2quarter, F(0), F(0), F(0))
            a2 = state2bitstring(aes.state_array(list(A2)))
            b1 = inv_SRMC(a2)
            abs_corr1 = abs(rho_SB(a1,b1))
            if abs_corr1 == 0 or abs_corr1 < max_abs_corr or abs_corr1 == 1:
                continue
            for A3half in product(F, repeat=2):
                A3 = (A3half[0], A3half[1], F(0), F(0))
                a3 = state2bitstring(aes.state_array(list(A3)))
                b2 = inv_SRMC(a3)
                abs_corr2 = abs(rho_SB(a2,b2))
                if abs_corr2 == 0 or abs_corr2 < max_abs_corr or abs_corr2 == 1:
                    continue
#                weight = 4 - a3.count('0000')
#                if weight == 0 or weight == 4:
#                    continue
                abs_corr = abs_corr1*abs_corr2
#                assert abs_corr == abs(rho_2(a1,a2,a3))
                print 'with a1,a2,a3', [a1,a2,a3]
                if max_abs_corr < abs_corr < 1:
                    print 'found something better with corr', abs_corr
                    max_abs_corr = abs_corr
                    max_trail = []
                if abs_corr == max_abs_corr:
                    print 'update list for corr', abs_corr
                    print 'with a1,a2,a3', [a1,a2,a3]
                    max_trail.append([a1,a2,a3])
    return max_trail, max_abs_corr

# print 'estimated correlation', rho_2(a1, a2, a3)
# print 'exact correlation', exact_correlation(a1, a3)

'''
update list for corr 1/8
with a1,a2,a3 [['0000', '0010', '0101', '0000'], ['0000', '0000', '0000', '0011'], ['0010', '0011', '0000', '0000']]
update list for corr 1/8
with a1,a2,a3 [['0000', '0010', '0101', '0000'], ['0000', '0000', '0000', '0011'], ['0111', '1101', '0000', '0000']]
update list for corr 1/8
with a1,a2,a3 [['0000', '0010', '0111', '0000'], ['0000', '0000', '0000', '0011'], ['0010', '0011', '0000', '0000']]
update list for corr 1/8
with a1,a2,a3 [['0000', '0010', '0111', '0000'], ['0000', '0000', '0000', '0011'], ['0111', '1101', '0000', '0000']]
update list for corr 1/8
with a1,a2,a3 [['0000', '0010', '1110', '0000'], ['0000', '0000', '0000', '0001'], ['0011', '1011', '0000', '0000']]
update list for corr 1/8
with a1,a2,a3 [['0000', '0010', '1110', '0000'], ['0000', '0000', '0000', '0001'], ['1101', '0010', '0000', '0000']]
update list for corr 1/8
with a1,a2,a3 [['0000', '0100', '0100', '0000'], ['0000', '0000', '0000', '1101'], ['1110', '1001', '0000', '0000']]
update list for corr 1/8
with a1,a2,a3 [['0000', '0100', '0100', '0000'], ['0000', '0000', '0000', '1101'], ['1101', '0010', '0000', '0000']]
update list for corr 1/8
with a1,a2,a3 [['0000', '0100', '0110', '0000'], ['0000', '0000', '0000', '0111'], ['1100', '1010', '0000', '0000']]
update list for corr 1/8
with a1,a2,a3 [['0000', '0100', '0110', '0000'], ['0000', '0000', '0000', '0111'], ['1010', '1111', '0000', '0000']]
update list for corr 1/8
with a1,a2,a3 [['0000', '0100', '1011', '0000'], ['0000', '0000', '0000', '1101'], ['1110', '1001', '0000', '0000']]
update list for corr 1/8
with a1,a2,a3 [['0000', '0100', '1011', '0000'], ['0000', '0000', '0000', '1101'], ['1101', '0010', '0000', '0000']]
'''
