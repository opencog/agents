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
and logical expressions, interface definitions, algorithms and
psuedo-code, vectors, tensors, sheaves, and higher-order methematical
objects from model theory, category theory, proof theory and so on.

"Pure" Atomese is Atomese that has no additional requirements beyond
the AtomSpace. In particular, it does NOT use scheme or python (or C++
or javascript or npm or Java or rust ...) to express algorithms: the
algorithms themselves are written in Atomese.

The reasons for choosing Atomese over some conventional programming
language are manifold. For example, Atomese resembles pseudo-code,
except its actually runnable. But since its pseudo-code, it can have
multiple concrete implementations: it is mutable, in that it is
re-writable to target any particular compute fabric (CPU's, GPU's...)
Since Atomese is also an interface definition language (IDL), agents
can grab, analyze and recombine the IDL descriptions to formulate and
create new kinds of subsystems, and agents. Since Atomese is a graph,
it comes with a graph query system, which allows graph algos to be
deployed "on itself" -- i.e. it can self-introspect. It is
self-describing.  This self-describability property was invented to make
it easy to create dynamic, changing, mutable entities. These are the
kinds of reasons that motivate the choice of Atomese, as opposed to
some other programming or database or theorem-proving or inference or
symbolic reasoning subsystem.


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
One of the design goals is to employ "pure Atomese" for all agents.
At present, this means that not only are all of the algorithms written
in Atomese, but that these are then saved in a
[`RocksStorageNode`](https://wiki.opencog.org/w/RocksStorageNode),
from which they can be loaded again. There is no dependency on scheme
or python, except as bootstrapping systems.

(Atomese can also move through a network, by combining the
[`CogServerNode`](https://wiki.opencog.org/w/CogServerNode) with the
[`CogStorageNode`](https://wiki.opencog.org/w/CogStorageNode). That is,
[`StorageNodes`](https://wiki.opencog.org/w/StorageNode) are not just
for disk storage, but for inhabiting the network cloud.)

The vision, as hinted above, is:
* Atomese is mutable, and can be rewritten using graph rewrite rules.
* Atomese allows the operation of graph rewrite engines.
* The rewrite rules can themselves be expressed in Atomese, so it is a
  self-rewriting system.
* Atomese allows the expression of axioms and inference rules in their
  abstract form, and thus provides a natural way of expressing arbitrary
  symbolic, mathematical systems.
* The self-expressivenes and rewritablility should allow for mutability
  and cross-breeding between different algorithms.
* The interface description language (IDL) for an algorithm is itself
  written in Atomese: thus, algorithms become "jigsaw pieces" that can
  be snapped together or assembled using any generative algorithm
  whatsoever.
* Generative algorithms include rewrit systems, odometers, stochastic
  random walkers, Boltzmann machines, Markov logic machines, etc. and
  all of these different algorithms themselves can be written in Atomese.
* This, in a sense, Atomese also becomes a psuedo-code language: the
  Atomese expression is meant to encode "what to do" and not any one
  specific, concrete implementation.

All of the above are meant to conspire to allow agents to be dynamic and
changing (compute) entities. This project is an exploration of the above
conceptions.

### The Experiments
See the [experiments](./experiments) directory for more.

--------------
