#!/bin/bash

#
# Copyright (c) 2015, University of California, Berkeley
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies,
# either expressed or implied, of the FreeBSD Project.
#

# author: Liang Gong

rm -Rf exp/fine_sampling_exp/result/*
mkdir exp/fine_sampling_exp/result
# number of iterations for each experimental configuration
rounds=5


# ----------------------------------------------------------------------------
# collecting original jitprof slowdown
# apply jalangi2 change patch for non-sampling configuration
cd ../jalangi2
git stash  # undo applied patches
git apply ../jalangi2analyses/exp/fine_sampling_exp/patch/patch_for_jitprof_analysis.patch
cd ../jalangi2analyses
for i in `seq 1 $rounds`;
	do
		# collect data for all benchmarks
		./exp/fine_sampling_exp/experiment.sh non
		node ./exp/fine_sampling_exp/stat.js result.txt exp/fine_sampling_exp/result/result-jitprof-"$i".csv
		# collect warning preservation information
		node exp/fine_sampling_exp/warningMatcher.js result.txt > exp/fine_sampling_exp/result/result-jitprof-"$i".json
    done 

# ----------------------------------------------------------------------------
# collecting original jitprof slowdown with 10% random sampling rate
# apply jalangi2 change patch for sampling configuration
cd ../jalangi2
git stash  # undo applied patches
git apply ../jalangi2analyses/exp/fine_sampling_exp/patch/patch_for_jitprof_analysis.patch
cd ../jalangi2analyses

# replace analysis.js with the one using sampling call
cp exp/fine_sampling_exp/patch/analysis.random.sample.js ../jalangi2/src/js/runtime/analysis.js

for i in `seq 1 $rounds`;
	do
		# generate random array
		node exp/fine_sampling_exp/getSampleArray.js 0.1
		cp exp/fine_sampling_exp/patch/sample_0.1.json ../jalangi2/src/js/runtime/sample_0.1.json
		# collect data for all benchmarks
		./exp/fine_sampling_exp/experiment.sh random
		node ./exp/fine_sampling_exp/stat.js result.txt exp/fine_sampling_exp/result/result-jitprof-rand-0.1-"$i".csv
		# collect warning preservation information
		node exp/fine_sampling_exp/warningMatcher.js result.txt > exp/fine_sampling_exp/result/result-jitprof-rand-0.1-"$i".json
    done 

# ----------------------------------------------------------------------------
# collecting original jitprof slowdown with 1% random sampling rate
# apply jalangi2 change patch for sampling configuration
cd ../jalangi2
git stash  # undo applied patches
git apply ../jalangi2analyses/exp/fine_sampling_exp/patch/patch_for_jitprof_analysis.patch
cd ../jalangi2analyses

# replace analysis.js with the one using sampling call
cp exp/fine_sampling_exp/patch/analysis.random.sample.js ../jalangi2/src/js/runtime/analysis.js

for i in `seq 1 $rounds`;
	do
		# generate random array
		node exp/fine_sampling_exp/getSampleArray.js 0.01
		cp exp/fine_sampling_exp/patch/sample_0.1.json ../jalangi2/src/js/runtime/sample_0.1.json
		# collect data for all benchmarks
		./exp/fine_sampling_exp/experiment.sh random
		node ./exp/fine_sampling_exp/stat.js result.txt exp/fine_sampling_exp/result/result-jitprof-rand-0.01-"$i".csv
		# collect warning preservation information
		node exp/fine_sampling_exp/warningMatcher.js result.txt > exp/fine_sampling_exp/result/result-jitprof-rand-0.01-"$i".json
    done 

# ----------------------------------------------------------------------------
# collecting original jitprof slowdown with different random sampling rates
# apply jalangi2 change patch for sampling configuration
cd ../jalangi2
git stash  # undo applied patches
git apply ../jalangi2analyses/exp/fine_sampling_exp/patch/patch_for_jitprof_analysis.patch
cd ../jalangi2analyses

# replace analysis.js with the one using sampling call
cp exp/fine_sampling_exp/patch/analysis.random.sample.js ../jalangi2/src/js/runtime/analysis.js

for sampleRate in 0.5 0.25 0.125 0.0625 0.03125 0.015625 0.0078125 0.00390625 0.001953125 0.0009765625 0.00048828125 0.000244140625 0.0001220703135
do
	for i in `seq 1 $rounds`;
	do
		# generate random array
		node exp/fine_sampling_exp/getSampleArray.js "$sampleRate"
		cp exp/fine_sampling_exp/patch/sample_0.1.json ../jalangi2/src/js/runtime/sample_0.1.json
		# collect data for all benchmarks
		./exp/fine_sampling_exp/experiment.sh random
		node ./exp/fine_sampling_exp/stat.js result.txt exp/fine_sampling_exp/result/result-jitprof-rand-"$sampleRate"-"$i".csv
		# collect warning preservation information
		node exp/fine_sampling_exp/warningMatcher.js result.txt > exp/fine_sampling_exp/result/result-jitprof-rand-"$sampleRate"-"$i".json
    done 
done

# ----------------------------------------------------------------------------
# collecting original jitprof slowdown with decaying sampling rate
# apply jalangi2 change patch for sampling configuration
cd ../jalangi2
git stash  # undo applied patches
git apply ../jalangi2analyses/exp/fine_sampling_exp/patch/patch_for_jitprof_analysis.patch
cd ../jalangi2analyses

# replace analysis.js with the one using sampling call
cp exp/fine_sampling_exp/patch/analysis.random.sample.js ../jalangi2/src/js/runtime/analysis.js

for i in `seq 1 $rounds`;
	do
		# generate random array
		node exp/fine_sampling_exp/getDecayingSampleArray.js
		cp exp/fine_sampling_exp/patch/sample_decay.json ../jalangi2/src/js/runtime/sample_0.1.json
		# collect data for all benchmarks
		./exp/fine_sampling_exp/experiment.sh random
		node ./exp/fine_sampling_exp/stat.js result.txt exp/fine_sampling_exp/result/result-jitprof-decay-"$i".csv
		# collect warning preservation information
		node exp/fine_sampling_exp/warningMatcher.js result.txt > exp/fine_sampling_exp/result/result-jitprof-decay-"$i".json
    done 

# undo applied patches
cd ../jalangi2
git stash
cd ../jalangi2analyses
