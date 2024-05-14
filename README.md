Atomese Agents
==============
Experiments and prototyping for interactive learning agents.

### Status
Version 0.0.2 -- Extremely early prototyping stage.

### Overview
The [Opencog Learn](https://github.com/opencog/learn) project showed
that the basic conscept of structure learning works and is scalable
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
Atomese. This seems like the "right thing to do", so that, for example,
AS-MOSES can be used to mutate and optimize important subsystems: this
would be impossible if the processing was done in a conventional
programming language. But these details are unclear, and so all of
this is a big experiment. Don't know how it will turn out.

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

For examples in this project, see the [examples](./examples) directory
here.

--------------
