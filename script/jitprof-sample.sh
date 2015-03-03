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

# $0 is the name of the command
# $1 first parameter: sampler's name
# $2 second parameter: relative path of targe program without .js suffix
# $# total number of parameters
# $@ all the parameters will be listed

# go to jalangi2 directory and apply patch for sampling
cd ../jalangi2/
git apply ../jalangi2analyses/exp/patch/patch_for_nop_analysis_sampling.patch
cd ../jalangi2analyses/

# instrument code
echo "instrumenting ""$2".js"..."
node ../jalangi2/src/js/commands/esnstrument_cli.js --inlineIID "$2".js
# run JITProf with sampling
echo "analyzing with JITProf..."
node ../jalangi2/src/js/commands/direct.js --analysis ../jalangi2/src/js/sample_analyses/ChainedAnalysesNoCheck.js --analysis src/js/analyses/jitprof/utils/Utils.js --analysis src/js/analyses/jitprof/utils/RuntimeDB.js --analysis src/js/analyses/jitprof/TrackHiddenClass.js  --analysis src/js/analyses/jitprof/AccessUndefArrayElem.js --analysis src/js/analyses/jitprof/SwitchArrayType.js --analysis src/js/analyses/jitprof/NonContiguousArray.js --analysis src/js/analyses/jitprof/BinaryOpOnUndef.js --analysis src/js/analyses/jitprof/PolymorphicFunCall.js --analysis src/js/analyses/jitprof/TypedArray.js --analysis src/js/analyses/jitprof/sampler/"$1".js  "$2"_jalangi_.js

# undo changes to jalangi2
cd ../jalangi2/
git stash
cd ../jalangi2analyses/
