m = F.polynomial()    # minimal polynomial
print 'the minimal polynomial of F is ', m

# 2. A running example
# ====================

# M = aes.state_array()        # all 0
# M = aes.state_array() + 1    # diagonal 1 by coercion
# M = aes.random_state_array()

print 'As an example, we process the 16-bit message'
u = ['0001', '0000', '1010', '1011']
# u = ['1111', '1111', '1111', '1111']
print 'u =', u
U = bitstring2state(u)    # CAVE: columnwise!
print '  =\n', U

# 3. SubBytes
# ===========

# S-Box operates on words, SubBytes operates on states
S = aes.sbox()
print 't1 is S(1)-S(0), that is', F.fetch_int(S(1))-F.fetch_int(S(0))
print 't0 is S(0), that is ', F.fetch_int(S(0))

# Figure 1: S-Box as look-up table of bitstrings
print '% 5s % 9s'%('m', 'S-Box(m)')
for i in srange(16):
    h = i.str(base=16)
    word = h2b(h)
    print '% 5s % 9s'%(word, F2b(S(b2F(word))))

print 'For u as in (6.1), this yields'
print 'u =', state2bitstring(U)
V = aes.sub_bytes(U)
print 'v = SubBytes(u) =', state2bitstring(V)

# 4. ShiftRows & MixColumns
# =========================

E = aes.state_array() + 1
print 'MixColumns is left matrix  multiplication by\n', aes.mix_columns(E)

print 'For v as in (6.7), these two steps lead to'
print 'v =', state2bitstring(V)
VW = aes.shift_rows(V)
print 'ShiftRows(v) =', state2bitstring(VW)
W = aes.mix_columns(VW)
print 'w = MixColumns(ShiftRows(v)) =', state2bitstring(W)

# 5. AddRoundKey
# ==============

print 'w =', state2bitstring(W)
U2 = aes.add_round_key(W, U)
print 'AddRoundKey_{u}(w) =', state2bitstring(U2)








'''

# message
M = aes.random_state_array()
print M
print aes.hex_str(M)    # defaults to aes.hex_str_matrix(M) -- alternatively aes.hex_str_vector(M) !!! col-before-row !!!
# check
aes.is_state_array(M)    # checks dimensions and base field

# key
K = aes.random_state_array()
print aes.hex_str_matrix(K)
# key scheduling
# for the ith subkey ki specify previous subkey k(i-1) and round i
K == aes.key_schedule(K, 0)    # true
for i in range(10):
    K = aes.key_schedule(K,i+1)

def key_inv(K,i):
    given key K in round i, return key in previous round
    while True:
        test = aes.random_state_array()
        if aes.key_schedule(test, i) == K:
            print 'found a victim'
            return test



M = aes.sub_bytes(M)    # CAVE sub_byte (without s) performs on words (see above) -- TODO how is that related to s-box
M = aes.shift_rows(M)
M = aes.mix_columns(M)
C = aes.add_round_key(M, K)    # == M + K


print aes.hex_str_matrix(C)

'''
