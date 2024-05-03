Text processing agent
---------------------
***Design goal***: Agent that reads text and responds, by generating text.

***Prototype***: Read text files, count word pairs, and generate
high-ranked word-pair streams. The pair-counting agent is in
`pair-agent.scm` and the generator is in `generator.scm`.

***Motivation***: Word-pairs stand in for generic complex networks of
occurances in the sensory environment that correlate with agent internal
state. The agent sees and responds to the environment. The generation
stream is a stand-in for generic agent motor control: after seeing and
"thinking", the agent "responds" with "actions" out into the external
environment.

## Pair counting agent
Prototype proof of concept. Implemented in `pair-agent.scm`. Works.
Based on demo in `examples/pair-count.scm`, which explains it in detail.
Counts word-pairs, observed by looking at a text file. The Sensory API
(implemented in `(use-modules (opencog sensory))`) is general enough to
allow arbitrary text sources, including chat.

The dataflow pipeline is hand-crafted. The sensory API is supposed to
eventually auto-build these pipelines, but that code is not working yet.

The hand-crafted pipe works fine. Try it.

### Design Notes
Here's the design we want for the pair-counting agent:

1) Some source of text strings. This source blocks if there's
   nothing to be read; else it returns the next string. The SRFI's
   call this a generator. The `OpenLink` provided by `sensory.scm`
   provides exactly this, so we're good.
2) (Optional) Some way to split one source into multiple sources.
   Maybe this:
   https://wiki.opencog.org/w/PromiseLink#Multiplex_Example
    but what happens if the readers don't both read ???
3) A Filter that takes above and increments pair counts.
   Done. Its non-atomic, but so what. Perhaps we can live with
   that, given that sampling is statistical, anyway.
4) Execution control. There are two choices:

   ***Pull***: infinite loop polls on promise. Source blocks if
         no input.
   ***Push***: Nothing happens until source triggers; then a cascade
         of effects downstream.
   - Right now, the general infrastructure supports Pull naturally.
   - There aren't any push demos.
   - Attention control is easier with Pull.

### Storage and Matrix API ???
The batch system uses the matrix API to define pipelines: this includes
* Which parser to use, e.g. `(make-any-link-api)`
* How to increment counts, e.g. `(add-count-api ala)`
* How to store updated counts, e.g. `(add-storage-count alc)`

This is a pipeline framework, it is not in Atomese. Its large,
extensive, lots of bells and whistles; many years of fully debugged
code. Its a good/great API, capable of carrying the load.

It seems to be slow, presumably due to the huge number of scheme/C++
transitions.  To validate this, need to run a pair-count-hacked
experiment, and actually measure.

The `add-storage-count` API fetches counts from storage, if not in
atomspace. This needs to be used instead of the `SetValue` default.
It implements atomic update.

There's also a marginal counter, but its unusued...

### TODO/Open issues
Some unresolved issues.
* Parser wants strings as `Node`s; it would be nice to be able to work
  with `StringValue`.
* Need to call `cog-execute!` in a loop, to loop over whole file. Would
  be nicer to not have to do this. This is a bug; the `OutputStream`
  class does run an inf loop on streams, but that loop fails on things
  that have a `Filter` in the middle.
* End-of-file results in a throw from parser. This is a side effect.
  The throw should happen from the file-reader, directly.
* Update AtomSpace to support an atomic `IncrementLink`. Under the
  covers, this would call `asp->increment_count(h, key, fvp->value()));`
  So it has the form `(IncrementLink atom key incr zero)` where `incr`
  is, for example `(Number 0 0 1)` and `zero` is `(Number 0 0 0)`. Note
  that this resembles a generic fold. The alternative to this is a
  `AtomicSetValueLink` which holds a lock to make sure the update is
  atomic. The risk is that naive users will discover deadlocks. Hmmm.
* There lready is a `FetchValueOf` but it needs to be fixed to take
  default, just like `ValueOf`
* Need a 'count-key etc. comparable to matrix API
