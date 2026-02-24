Atomese Agents
==============
Experiments and prototyping for interactive learning agents.

### Status
Version 0.0.2 -- Extremely early prototyping stage.

### Overview
The [Opencog Learn](https://github.com/opencog/learn) project showed
that the basic concept of structure learning works and is scalable
and can deal with observing and learning real-world structures. Great!

But it was built as a batch system, training on large blobs of data,
moving from one training stage to the next. This turns out to be
unmanagable: its complicated, its fragile. It's hard to track status
and to run experiments. Hard to redo batch steps when bugs get fixed
and system architecture changes.

Most importantly, the above is a roadblock to scaling: the core idea is
that the learning can be done recursively. But if the recursive steps
teeter precariously on earlier batch runs ... ugh. It became too hard
to develop the recursive step.

Rather than refactoring the code in that git repo, it seems better to
start with a clean slate, here. The general ideas get recycled. The
framework changes dramatically.

One current goal is to rewrite important parts of the pipeline in pure
[Atomese](https://wiki.opencog.org/w/Atomese). Atomese is a structure
description language; it is a language for describing graphs, symbolic
and logical expressions, interface defintiions, algorithms and
psuedo-code, vectors, tensors, sheaves, and higher-order methematical
objects from model theory, category theory, proof theory and so on.

"Pure" Atomese is Atomese that has no additional requirements beyond
the AtomSpace. In particular, it does NOT use scheme or python (or C++
or javascript or npm or Java or rust ...) to express algorithms: the
algorithms themselves are written in Atomese.

The 


The hope is that a pure Atomese structure will make the recursive jump
easy. Without the recursive jump, well, its just Symbolic AI from
earlier decades.

A general overview can be found in the AGI 2022 paper:
[Purely Symbolic Induction of Structure](https://github.com/opencog/learn/tree/master/learn-lang-diary/agi-2022/grammar-induction.pdf).

Background reading: the various PDF and LyX files located at:
* [AtomSpace Sheaves & Graphs](https://github.com/opencog/atomspace/tree/master/opencog/sheaf)
* [OpenCog Learn Project](https://github.com/opencog/learn) and
  especially the "diary" subdirectory there.

Additional general details and concepts are described in scattershot
locations, in diary entries, or nowhere at all.

### Action-Perception
The demos here are built on top of the perception-action framework
developed in the [Sensory project](https://github.com/opencog/sensory).
The code here adds some non-trivial processing steps on top of the
basic sensori-motor API provided there. Be sure to go through the
examples there.

Turns out that action-perception is far more complicated than one might
think. Thus, to address the issues discovered there, the
[OpenCog (Sensori-)Motor project](https://github.com/opencog/motor)
has been started. Progress on this project, Agents, is stalled, until
the deeper issues explored there are resolved.

### Pure Atomese
One of the design goals is to emply "pure Atomese" for all agents.

### The Experiments
See the [experiments](./experiments) directory for more.

--------------
