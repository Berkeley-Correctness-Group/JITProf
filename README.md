JITProf v1.1
=====================
### What is JITProf?

JITProf is a tool that tells you which part of your JavaScript code may be slow on a modern JIT-engine. We call the slow code **JIT-unfriendly code**.

**Academic Resources:** [Preprint](http://www.cs.berkeley.edu/~ksen/papers/jitprof.pdf) in [ESEC/FSE'15](http://esec-fse15.dei.polimi.it/) | [Presentation Slides](http://mp.binaervarianz.de/fse2015_slides.pdf) | [Technical Report](http://www.eecs.berkeley.edu/Pubs/TechRpts/2014/EECS-2014-144.pdf) | [Bibtex](http://mp.binaervarianz.de/fse2015.html)


#### What is JIT-unfriendly code?

JIT-unfriendly code is a piece of JavaScript that is hard for the JIT-engine to do profitable optimization.

**Example:** Suppose you want to create an array containing 10k numbers with number i at index i:

```javascript
var array = [];
for(var i=10000-1;i>=0;i--) {
	array[i] = i; // JIT-unfriendly code
}
```

The first half of iterations create a non-contiguous array.
In order to save memory, JIT-engine will use a hash-table-like representation to store the array
in memory instead of a contiguous memory space (like in C/C++). Consequently, accessing ```array``` is quite slow.

A more efficient and JIT-friendly code should initialize the array elements in asending order:

```javascript
var array = [];
for(var i=0;i<10000;i++) {
	array[i] = i;
}
```

This time, the JIT-engine will always use contiguous memory space for array and array accessing is much faster.
This simple change leads to 10X-20X speedup on Firefox and Chrome.

Note that there are different JIT-unfriendly code patterns, those patterns relate to memory model, polymorphic operations, hidden classes and inline caching. More details are in our [Paper](http://jacksongl.github.io/files/jitprof.pdf) and [technical report](docs/TR.md).

#### How does JITProf work?

JITProf monitors the execution of a JavaScript program and analyses its runtime behavior to pinpoint the JIT-unfriendly code location.

For the previous example, JITProf will pinpoint to ```array[i] = i;``` and tells you the code is accessing a non-contiguous array
frequently. Note that this is only one of those JIT-unfriendly code patterns detected by JITProf. 
For more details, please [read this document](docs/TR.md).

#### Visualizing JIT-unfriendly Code

There is another project focusing on visualizing the JIT-unfriendly code. For more details, see [here](https://github.com/JacksonGL/jitprof-visualization).

#### Overall how much speedup after removing JIT-unfriendly code?

The speedup ranges from 1% ~ 20% on SunSpider and Google Octane benchmark.


Install JITProf
---------------

To run JITProf with Jalangi2 on real-world websites, you need to install
	
 * **jalangi2** See the [Jalangi2 Repository](https://github.com/Samsung/jalangi2)
 (Put Jalangi2 repository and this repository under the same directory.)

 * **mitmproxy** For more details, please read [this document](docs/mitmproxy_install.md).

Use JITProf to find JIT-unfriendly code
---------------------------------------

JITProf can be used on both node.js applications and websites.

All following instructions assume that the current working directory is the root direcotry of JITProf and that the main [jalangi2](https://github.com/Samsung/jalangi2) directory is a sibling directory of JITProf. This project currently supports Mac OS.

#### Find JIT-unfriendly code on websites

```
./script/jitprof-web.sh [sampler's name]
```

Existing samplers: ```non```, ```random```, ```decay```


Now you can explore the web with any browser you like.
In the browser window, use ```Alt```-```Shift```-```T``` key combination to dump
the JITProf wanrings in the web console.

**Note:** After using JITProf, type the following command to disable web proxy configuration. 
```
./script/jitprof-web.sh
```

#### Find JIT-unfriendly code running on node.js

```
./script/jitprof.sh [js program relative path without .js suffix]
```

Example:

```
./script/jitprof.sh tests/jitprof/JITAwareTest
```

#### Find JIT-unfriendly code (reduce overhead by sampling)

**Warning:** the following script will stash and apply a patch to the jalangi2 repository in the sibling directory of jitprof. Please make sure all changes in the Jalangi2 directory are properly saved.

Run JITProf with random sampler (10% sampling rate):

```
./script/jitprof-sample.sh [sampler name] [js program relative path without .js suffix]
```

Existing samplers: ```non```, ```random```, ```decay```

Example:

```
./script/jitprof-sample.sh random tests/jitprof/JITAwareTest
```


### Measure runtime overhead (with sampling)

Using hybrid sampling (i.e., sampling instrumentation on function level and sampling the analysis of instructions),
we can reduce the overhead of JITProf by one (sometime two) order(s) of magnitude.

For more details and to replicate the experiment, [please go to this page](exp/hybrid_sampling_exp).


### Micro-benchmark and experiments measuring speedup on Benchmarks

Micro-benchmarks and improved benchmark programs are decoupled from the implementation of JITProf.
Those experimental code and dataset are available in [JITProf v1.0](https://github.com/Berkeley-Correctness-Group/Jalangi-Berkeley/tree/master/src/js/analyses/jitaware).

License and Citation
--------------------

JITProf is distributed under the [Apache License](http://www.apache.org/licenses/LICENSE-2.0.html).

Please cite JITProf in your publications if it helps your research:

	@INPROCEEDINGS{fse2015,
	  author = {Liang Gong and Michael Pradel and Koushik Sen},
	  title = {{JITProf}: Pinpointing {JIT}-Unfriendly {JavaScript} Code},
	  booktitle = {European Software Engineering Conference and Symposium on the Foundations of Software Engineering (ESEC/FSE)},
	  year = {2015}
	}
