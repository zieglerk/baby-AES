Differential and Linear Attacks on baby-AES
===========================================

This Python-module provides functions to perform differential and linear attacks
on baby-AES, a scaled-down version of the *Advanced Encryption Standard*.

Design decisions
================

- AIM :: it makes sense to fix the active words in the input to the last round
  on which we want to concentrate
- CHOICE :: we opt for the 1st (and optionally 2nd) word, such that the
  recovered words of the last roundkey are 1st (and optionally 4th)

submodules
==========

baby-AES.sage
    global setup for our 3-round baby-AES; also contains all the string methods
    and step-by-step baby-AES and keyschedule for debugging; will be loaded by
    all subsequent modules

examples_for_baby-AES.sage
    runs a step-by-step example of baby-AES for the introductory section 6.1
    Baby-AES of cryptanalysis
    - INPUT :: NONE
    - OUTPUT :: printed to screen

examples_for_diff.sage
    print absolute frequences and difference distribution table for section 6.2
    Differential Cryptanalysis
    - INPUT :: NONE
    - OUTPUT :: printed to screen




create_challenge.sage
    - INPUT :: (index of) secret key
    - OUTPUT :: full list of all plaintext-ciphertext pairs under
      that secret key

find_diff_trail.sage
    - INPUT :: ???magnitude of correlation???
    - OUTPUT :: list of trails with the given magnitude of correlation; BONUS:
      warning when trail with even higher magnitude of correlation is available
    NOTE: the shape of the trail is fixed to make the last two words in the
    last round inactive.

attack_with_diff.sage
    - INPUT :: (index of) trail, (index of) sample set
    - OUTPUT :: dictionary of frequency distributions

find_lin_trail.sage

attack_with_lin.sage

dict2hist.sage


data
====

timings on cosec-og-02:
- diff (w/o filter): 4 h 42 min 58 s
- diff (w/ filter): 4 h 8 min 32 s
- lin: 2 h 26 min 21 s

Usage
=====

Load the module in your local Sage installation::

   $ sage -q
   sage: load('baby-AES.sage')

See each module's documentation for further instructions.

baby-AES
--------

baby-AES.sage
    defines 3-round baby-AES with bitstring in- and output, see section 6.1

create_challenge.sage num/full key [dx]
    create num (or all) plaintext/ciphertext pairs encrypted with key
    OUT: 
    - all/<num>_sample_pairs--key0/1/2.sobj
    - all/<num>_samples--key0/1/2--1/2/3rounds.sobj

differential cryptanalysis
--------------------------

diff-examples.sage
    around Step 1: Build the difference distribution table of the S-Box

find_diff_trail.sage
    examining and finding differential trails

attack_with_diff.sage
    [InputXOR, OutputXOR] [samples] :: recover words of last roundkey

linear cryptanalysis
--------------------

find_lin_trail.sage
    examining and finding linear trails

attack_with_lin.sage
    [InputMask, OutputMask] [samples]

Visualization
-------------

dict2hist.sage
    IN: candidates.sobj
    OUT: hist.eps

Output
======

secret_keys.sobj
diff_trails.sobj (with prop ratio)
lin_trais.sobj (with correlation)


Requirements
============

This code requires the free mathematical software [Sage]_ which is
available for download at http://www.sagemath.org and as cloud service
at https://cloud.sagemath.org. It has been tested under GNU/Linux with
Sage 6.4.


References
==========

.. [CidEtAl] 

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

