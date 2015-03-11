'''
lin_ca gets as input samples and an Input/OutputMask.  It does not care about the rounds involved -- the samples "know" about that. (at least in the file name).

We run with linear trail a1 | a2 | a3 as input and determine Input/OutputMask based on number of rounds

- 1 round aes -> 0 round trail -> mask a3 | a3
- 2 round aes -> 1 round trail -> mask a2 | a3
- 3 round aes -> 2 round trail -> mask a1 | a3
'''

load('baby-AES.sage')

# input and output mask for linear trail over two rounds with correlation -1/8
InputMask = ['0010', '0000', '0000', '1000']
# InputMask =  ['1001', '0000', '0000', '0000']    # insert this if you use the trail for just a single round
OutputMask = ['0111', '1101', '0000', '0000']

invS = mq.SBox(14, 13, 4, 12, 3, 2, 0, 6, 15, 8, 7, 1, 11, 9, 5, 10)

def sr_indices(a):
    '''for a list a of indices, replace all 1's by 3's and all 3's by 1's'''
    b = a[:]
    for i,val in enumerate(b):
        if val == 1:
            b[i] = 3
        elif val == 3:
            b[i] = 1
    return b

def lin_ca(T, InputMask, OutputMask):
    '''
    works for aes with r number of rounds and requires a "good" InputMask/OutputMask for the first r-1 rounds, i.e. without last-round modification.  You can always get them from truncating a 2-round linear trail a1|a2|a3 to a1|a2 or a2|a3 (for 1 round) or a1|a1 a2|a2 or a3|a3 (for 0 round) -- but mind the number of active words in the OutputMask.

    sage: InputMask = ['0000','0010','0101','0000']
    sage: OutputMask = ['0010','0011','0000','0000']
    sage: T = [[bitstring2state(InputMask), bitstring2state(OutputMask)]]
    sage: lin_ca(T, InputMask, OutputMask)
    '''
    active_in_last = [i for i,x in enumerate(OutputMask) if x <> '0000']
    active_in_ciphertext = sr_indices(active_in_last)
    active_in_ciphertext.sort()
    active_in_last = sr_indices(active_in_ciphertext)
    candidates = {partkey: 0 for partkey in product(F,repeat=len(active_in_ciphertext))}
    for x, y in T:
	xraw = state2bitstring(x)
        yraw = state2bitstring(y)
	InputSum = sum(scalarproduct(InputMask[i], xraw[i]) for i in range(4))%2
        for partkey in candidates:
            OutputSum = 0
            for i, keyword in enumerate(partkey):
                u3word = invS(b2F(yraw[active_in_ciphertext[i]]) + keyword)
                OutputSum += scalarproduct(OutputMask[active_in_last[i]], F2b(u3word))
            OutputSum = OutputSum%2
            if (OutputSum + InputSum)%2 == 0:
                candidates[partkey] += 1
 	    else:
 		candidates[partkey] -= 1
    return candidates

T = load('output--lin_ca/all_samples--key1--3rounds')
candidates = lin_ca(T, InputMask, OutputMask)
save(candidates, 'output--lin_ca/lin_ca--correlations--key1--3rounds--rerun')
