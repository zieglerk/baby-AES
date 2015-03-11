Differential and Linear Attacks on baby-AES
===========================================

This Python-module provides functions for differential and linear
attacks on *baby-AES*, a small-scale variant of the *Advanced
Encryption Standard* (AES), see [CMR2005]_. This code is mainly
educational and accompanied lectures in cryptanalysis at the
University of Bonn in `summer 2013
<https://cosec.bit.uni-bonn.de/students/teaching/13iw/13iw-crypta/>`_
and `summer 2014
<https://cosec.bit.uni-bonn.de/students/teaching/14ss/14ss-taoc/>`_.

The implemented attacks are statistical and recover some words of the
last roundkey. The remaining words can then be found by brute
force. We choose to always attack the first and last word of the last
roundkey. This leads to a smoother exposition, since all the
trails/differentials then end in the first half of the last but one
roundkey.

Submodules
==========

Baby-AES
--------

baby-AES.sage
    global setup for our 3-round baby-AES; also contains all the string methods
    and step-by-step baby-AES and keyschedule for debugging; will be loaded by
    all subsequent modules; defines the 3-round baby-AES with
    bitstring in- and output, see section 6.1 of the lecture notes

examples_for_baby-AES.sage
    runs a step-by-step example of baby-AES for the introductory section 6.1
    Baby-AES of cryptanalysis

    OUTPUT:

    - printout of intermediate states during the first round

examples_for_diff.sage
    print absolute frequences and difference distribution table for section 6.2
    Differential Cryptanalysis


create_challenge.sage <num/full> <key> [dx]
    create <num> (or <all>) plaintext/ciphertext pairs encrypted with
    <key>; optionally pairs with given plaintext difference
    [dx]; full list of all plaintext-ciphertext pairs under that secret key

    INPUT:

    - <num/full> -- number of samples
    - <key> -- index of secret key
    - <dx> -- input mask (optional)

    OUTPUT:

    - all/<num>_sample_pairs--key0/1/2.sobj -- list of
      pairs of plaintext/ciphertext with given plaintext difference
    - all/<num>_samples--key0/1/2--1/2/3rounds.sobj -- list of
      plaintext/ciphertext pairs encrypted under the given key

Differential Cryptanalysis
--------------------------

diff-examples.sage
    build the difference distribution table of the S-Box, see Step 1
    of the lecture notes

find_diff_trail.sage
    examine all and find optimal differential trails; NOTE: the
    shape of the trail is fixed to make the last two words in the last
    round inactive; also, compute the exact propagation ratio for a
    given input/output-differential

attack_with_diff.sage
    perform differential attack along a given differential trail;
    optionally with filtering

    INPUT:

    - InputXor/OutputXor -- differential for selected differential trail
    - all_sample_pairs--<key>.sobj -- pairs of plaintext/ciphertext
      samples for <key>

    OUTPUT:

    - frequencies--key<num>--<filtered>.sobj -- dictionary of
      candidate keys with frequencies

Linear Cryptanalysis
--------------------

find_lin_trail.sage
    examine all linear trails over the first two rounds and identify
    the ones with maximal magnitude of correlation; restrict to trails
    with at most 2 active S-boxes in their final round to make the
    trail applicable for a linear attack

attack_with_lin.sage
    perform linear attack along a given linear trail

    INPUT:

    - InputMask/OutputMask -- first and last mask of the selected
      linear trail
    - all_samples--<key>--3rounds.sobj -- plaintext/ciphertext samples
      for key <key>

    OUTPUT:

    - lin_ca--correlations--<key>--3rounds.sobj -- dictionary of
	  candidate keys with frequencies

Visualize Frequencies
---------------------

dict2hist.sage
    INPUT:

    - candidates.sobj -- dictionary of keys with frequencies

    OUTPUT:

    - hist.eps -- histogram in eps-format

Usage
=====

Load the module in your local Sage installation::

   $ sage -q
   sage: load('baby-AES.sage')

See each module's documentation for further instructions.

Timings
-------

partial roundkey recovery on a single core 3.4 GHz using Sage 6.3

- attack_with_diff: 4 h 42 min 58 s
- attack_with_diff (with filter): 4 h 8 min 32 s
- attack_with_lin: 2 h 26 min 21 s

Todos
=====

- fast inversion of keyschedule to complete the full key recovery

Requirements
============

This code requires the free mathematical software [Sage]_ which is
available for download at http://www.sagemath.org and as cloud service
at https://cloud.sagemath.org. It has been tested under GNU/Linux with
Sage 6.3.


References
==========

.. [CMR2005] C. Cid, S. Murphy & M. Robshaw (2005). Small Scale
	     Variants of the AES. In *12th International Workshop, FSE
	     2005*, Paris, France, February 21-23, 2005, Revised
	     Selected Papers, Henri Gilbert & Helena Handschuh,
	     editors, volume 3557 of Lecture Notes in Computer
	     Science, 145–162. Springer-Verlag. ISBN 978-3-540-26541-2
	     (Print) 978-3-540-31669-5 (Online). ISSN 0302-9743. URL
	     http://dx.doi.org/10.1007/11502760_10. Available at
	     http://www.isg.rhul.ac.uk/~sean/smallAES-fse05.pdf.

.. [Sage] W. A. Stein et al. (2014). Sage Mathematics Software
  (Version 6.4). The Sage Development Team. URL
  http://www.sagemath.org.


Author
======

- Konstantin Ziegler (2013-12-18): initial version

License
=======

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see http://www.gnu.org/licenses/.
