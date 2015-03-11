r"""
Write down the set D(dx), the table of differences x/x^*/y/y^*/dy, and the difference distribution table.

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

# remember: S = aes.sbox()

def I(difference):
    '''return the list of pairs with specified (input) bitstring difference'''
    a = [ [F2b(word),F2b(word+b2F(difference))] for word in F]
    a.sort()
    return a

dx = '1000'
print 'For example I(', dx, ') =', I(dx)

print '% 5s % 5s % 5s % 5s %5s'%('x','x^*','y','y^*','dy')
for pair in I(dx):
    x = pair[0]
    x1 = pair[1]
    y = F2b(aes.sub_byte(b2F(x)))
    y1 = F2b(aes.sub_byte(b2F(x1)))
    dy = F2b(b2F(y)+b2F(y1))
    print '% 5s % 5s % 5s % 5s %5s'%(x,x1,y,y1,dy)

print 'absolute frequency for differentials with dx =',dx,':', S.difference_distribution_matrix()[int(dx,base=2),:]
print 'difference distribution table for the S-Box of baby-AES\n', S.difference_distribution_matrix()

# optional exercise: try your own S-Box

S1 = mq.SBox(14, 13, 4, 12, 3, 2, 0, 6, 15, 8, 7, 1, 11, 9, 5, 10)    # this is inverse S-Box
print 'testing S-Box', S1
print 'check whether S is a permutation:', S1.is_permutation()
print 'S1(5) =', S1(5)
print 'S1([0,1,0,1]) =', S1([0,1,0,1])
print 'S1 has maximal absolute frequency', S1.maximal_difference_probability_absolute()
print 'S1 has maximal propagation ratio', S1.maximal_difference_probability()
