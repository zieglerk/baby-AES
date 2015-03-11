'''usage
sage: samples(secret_keys[3])
sage: all_sample_pairs(secret_keys[3], InputXor)
'''

load('baby-AES.sage')

# select a secret key; give short "nothing-up-my-sleeve" argument

secret_keys = [
['0011','0001','0101','0001'],    # 3141 from pi
['1101','1100','1110','1111'],    # parity of pi digits
['1011','1010','1110','0101'],    # BAE5
['0010','0100','0011','1111']     # binary expansion of pi after point
]

InputXor = bitstring2state(['0110','0000','0000','1000'])

save(secret_keys, 'secret_keys')

def samples(key, cipher=aes, num='all'):
    '''Return all 2^16 plaintext/ciphertext pairs for a given secret key ``key``.'''
    T = []
    KEY = bitstring2state(key)
    rounds = str(cipher)[4]
    if num == 'all':
        for xraw in product(F,repeat=4):
            X = aes.state_array(list(xraw))    # refer to global aes, since aes_rand has no state_array
            Y = cipher(X, KEY)
            T.append([X, Y])
        save(T, 'output--lin_ca/all_samples--key'+str(secret_keys.index(key))+'--'+str(rounds)+'rounds')
    else:
        while len(T) < num:
            X = aes.random_state_array()
            Y = cipher(X, KEY)
            T.append([X, Y])
        save(T, 'output--lin_ca/'+str(num)+'samples--key'+str(secret_keys.index(key))+'--'+str(rounds)+'rounds')

def all_sample_pairs(key, InputXor, cipher=aes):
    '''for a given InputXor and secret key return an iterator over the 2^16 matching samples'''
    T = []
    Key = bitstring2state(key)
    rounds = str(cipher)[4]
    for xraw in product(F,repeat=4):
        x = cipher.state_array(list(xraw))
        xstar = x + InputXor
        y = cipher(x, Key)
        ystar = cipher(xstar, Key)
        T.append([x,xstar,y,ystar])
    save(T, 'output--diff_ca/all_sample_pairs--key'+str(secret_keys.index(key))+'--'+str(rounds)+'rounds')
    return T

def last_roundkey(key, cipher=aes):
    rounds = str(cipher)[4]
    KEY = bitstring2state(key)
    for r in range(1, int(rounds)+1):
        KEY = cipher.key_schedule(KEY, r)
    return state2bitstring(KEY)

'''
def rand_sample_pairs(num, key, InputXor):
    T = []
    Key = bitstring2state(key)
    while len(T) < num:
        x = aes.random_state_array()
        xstar = x + InputXor
        y = aes(x, Key)
        ystar = aes(xstar, Key)
        T.append([x,xstar,y,ystar])
    return T
'''


'''
max = 0
for key in candidates:
    if candidates[key] > max:
        max = candidates[key]
        winner = key
print "recovered partial roundkey", winner, "with a fraction of", max/len(T), " through a trail with ratio", ratio
'''
