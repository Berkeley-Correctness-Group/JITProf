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

# back up the preivous results
rm result.bak.txt;
mv result.txt result.bak.txt;

# procedure that collects results and timing on one bechmark
# f: arg1 -> arg2
# arg1: name of benchmark
# arg2: location of benchmark
runexp() {
    echo "$1"
    echo '[**name**]'"$1" >> result.txt

    echo '[****]loc: '`wc -l $2".js"` >> result.txt

    echo "instrumenting program:" "$2".js
    # first instrument the code
    # node ../jalangi2/src/js/commands/esnstrument_cli.js "$2".js
	node ../jalangi2/src/js/commands/esnstrument_cli.js ../jalangi2/tests/octane/splay.js

	echo "start running..."
	# run analysis on the benchmark code
	# get jitprof slowdown
	# node ../jalangi2/src/js/commands/jalangi.js --inlineIID --inlineSource --analysis ../jalangi2/src/js/sample_analyses/ChainedAnalyses.js --analysis src/js/analyses/jitprof/utils/Utils.js --analysis src/js/analyses/jitprof/utils/RuntimeDB.js --analysis src/js/analyses/jitprof/TrackHiddenClass --analysis src/js/analyses/jitprof/AccessUndefArrayElem --analysis src/js/analyses/jitprof/SwitchArrayType --analysis src/js/analyses/jitprof/NonContiguousArray --analysis src/js/analyses/jitprof/BinaryOpOnUndef --analysis src/js/analyses/jitprof/PolymorphicFunCall --analysis src/js/analyses/jitprof/TypedArray ../jalangi2/tests/octane/deltablue.js
	# ( node ../jalangi2/src/js/commands/jalangi.js --inlineIID --inlineSource --analysis ../jalangi2/src/js/sample_analyses/ChainedAnalyses.js --analysis src/js/analyses/jitprof/utils/Utils.js --analysis src/js/analyses/jitprof/utils/RuntimeDB.js --analysis src/js/analyses/jitprof/TrackHiddenClass.js --analysis src/js/analyses/jitprof/AccessUndefArrayElem.js --analysis src/js/analyses/jitprof/SwitchArrayType.js --analysis src/js/analyses/jitprof/NonContiguousArray.js --analysis src/js/analyses/jitprof/BinaryOpOnUndef.js --analysis src/js/analyses/jitprof/PolymorphicFunCall.js --analysis src/js/analyses/jitprof/TypedArray.js $2 ) >> result.txt

	# get nop-analysis (template) slowdown
	# node ../jalangi2/src/js/commands/jalangi.js --inlineIID --inlineSource --analysis ../jalangi2/src/js/runtime/analysisCallbackTemplate.js 
	# ( node ../jalangi2/src/js/commands/jalangi.js --inlineIID --inlineSource --analysis ../jalangi2/src/js/runtime/analysisCallbackTemplate.js $2 ) >> result.txt
	( node ../jalangi2/src/js/commands/direct.js --analysis ../jalangi2/src/js/runtime/analysisCallbackTemplate.js "$2"_jalangi_.js ) >> result.txt

	# get jalangi2 slowdown (without any analysis)
	# node ../jalangi2/src/js/commands/jalangi.js --inlineIID --inlineSource
	# ( node ../jalangi2/src/js/commands/jalangi.js --inlineIID --inlineSource $2 ) >> result.txt

	# run the benchmark code without instrumentation and analysis
	node src/js/timeNode.js "$2".js >> result.txt
	# ( { time node "$2" | tee >(grep -Ei ".*" >> result.txt); } 2>&1 ) | { grep -Ei "^(real|user|sys)" >> result.txt; }
}

: <<'END'
END

# Google Octane
runexp "Octane-Splay" "../jalangi2/tests/octane/splay"
runexp "Octane-Richards" "../jalangi2/tests/octane/richards"
runexp "Octane-DeltaBlue" "../jalangi2/tests/octane/deltablue"
runexp "Octane-Crypto" "../jalangi2/tests/octane/crypto"
runexp "Octane-Box2d" "../jalangi2/tests/octane/box2d"
runexp "Octane-Code-Load" "../jalangi2/tests/octane/code-load"
runexp "Octane-Gbemu" "../jalangi2/tests/octane/gbemu"
runexp "Octane-Earley-Boyer" "../jalangi2/tests/octane/earley-boyer"
# runexp "Octane-Mandreel" "../jalangi2/tests/octane/mandreel"
runexp "Octane-Navier-Stokes" "../jalangi2/tests/octane/navier-stokes"
runexp "Octane-Pdfjs" "../jalangi2/tests/octane/pdfjs"
runexp "Octane-Raytrace" "../jalangi2/tests/octane/raytrace"
runexp "Octane-Regexp" "../jalangi2/tests/octane/regexp"
runexp "Octane-Typescript" "../jalangi2/tests/octane/typescript"

# SunSpider
runexp "SunSpider-3d-Cube" "../jalangi2/tests/sunspider1/3d-cube"
runexp "SunSpider-3d-Morph" "../jalangi2/tests/sunspider1/3d-morph"
runexp "SunSpider-3d-Raytrace" "../jalangi2/tests/sunspider1/3d-raytrace"
runexp "SunSpider-Access-Binary-Trees" "../jalangi2/tests/sunspider1/access-binary-trees"
runexp "SunSpider-Access-Fannkuch" "../jalangi2/tests/sunspider1/access-fannkuch"
runexp "SunSpider-Access-Nbody" "../jalangi2/tests/sunspider1/access-nbody"
runexp "SunSpider-Access-Nsieve" "../jalangi2/tests/sunspider1/access-nsieve"
runexp "SunSpider-Bitops-3bit-Bits-in-Byte" "../jalangi2/tests/sunspider1/bitops-3bit-bits-in-byte"
runexp "SunSpider-Bitops-Bits-in-Byte" "../jalangi2/tests/sunspider1/bitops-bits-in-byte"
runexp "SunSpider-Bitops-Bitwise-And" "../jalangi2/tests/sunspider1/bitops-bitwise-and"
runexp "SunSpider-Bitops-Nsieve-Bits" "../jalangi2/tests/sunspider1/bitops-nsieve-bits"
runexp "SunSpider-Controlflow-Recursive" "../jalangi2/tests/sunspider1/controlflow-recursive"
runexp "SunSpider-Crypto-AES" "../jalangi2/tests/sunspider1/crypto-aes"
runexp "SunSpider-Crypto-MD5" "../jalangi2/tests/sunspider1/crypto-md5"
runexp "SunSpider-Crypto-SHA1" "../jalangi2/tests/sunspider1/crypto-sha1"
runexp "SunSpider-Date-Format-Tofte" "../jalangi2/tests/sunspider1/date-format-tofte"
runexp "SunSpider-Date-Format-Xparb" "../jalangi2/tests/sunspider1/date-format-xparb"
runexp "SunSpider-Math-Cordic" "../jalangi2/tests/sunspider1/math-cordic"
runexp "SunSpider-Math-Partial-Sums" "../jalangi2/tests/sunspider1/math-partial-sums"
runexp "SunSpider-Math-Spectral-Norm" "../jalangi2/tests/sunspider1/math-spectral-norm"
runexp "SunSpider-Regexp-DNA" "../jalangi2/tests/sunspider1/regexp-dna"
runexp "SunSpider-String-Base64" "../jalangi2/tests/sunspider1/string-base64"
runexp "SunSpider-String-Fasta" "../jalangi2/tests/sunspider1/string-fasta"
runexp "SunSpider-String-Tagcloud" "../jalangi2/tests/sunspider1/string-tagcloud"
runexp "SunSpider-String-Unpack-Code" "../jalangi2/tests/sunspider1/string-unpack-code"
runexp "SunSpider-String-Validate-Input" "../jalangi2/tests/sunspider1/string-validate-input"

echo '[*]exp-done' >> result.txt