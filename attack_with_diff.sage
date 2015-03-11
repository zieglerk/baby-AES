r"""
Perform an attack using differential cryptanalysis.

[InputXOR, OutputXOR] [samples] :: recover words of last roundkey

INPUT:

- ``param1`` -- (default: foo) type of param1.
- ``param2`` -- type of param2.

OUTPUT:

- description of output.

EXAMPLES:

Show me the init::

    sage: 2+2
    4

TODO:

Produce filtered and unfiltered output in a single run.

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

# differential for first two rounds with propagation ratio 1/64:
InputXor = bitstring2state(['0110','0000','0000','1000'])    # du1
OutputXor = bitstring2state(['1010','1100','0000','0000'])    # du3
ratio = 1/64
# "active" words of last roundkey
active = [0,3]
inactive = [1,2]

invS = mq.SBox(14, 13, 4, 12, 3, 2, 0, 6, 15, 8, 7, 1, 11, 9, 5, 10)

def diff_ca(T, OutputXor, with_filter=False):
    candidates = {partkey: 0 for partkey in product(F,repeat=2)}
    for x, xstar, y, ystar in T:
        if with_filter and y[1,0] == ystar[1,0] and y[0,1] == ystar[0,1]:
            print 'filter active'
            continue
        for partkey in candidates:
            k31, k34 = partkey[0], partkey[1]
            u31 = invS(b2F(F2b(y[0,0])) + k31)
            u31star = invS(b2F(F2b(ystar[0,0])) + k31)
            u32 = invS(b2F(F2b(y[1,1])) + k34)
            u32star = invS(b2F(F2b(ystar[1,1])) + k34)
            if u31+u31star == OutputXor[0,0] and u32+u32star == OutputXor[1,0]:
                candidates[partkey] += 1
    return candidates

T = load('output--diff_ca/all_sample_pairs--key3')
# candidates = diff_ca(T, OutputXor)
# save(candidates, 'output--diff_ca/frequencies--key3--unfiltered')
candidates = diff_ca(T, OutputXor, with_filter=True)
save(candidates, 'output--diff_ca/frequencies--key3--filtered')
