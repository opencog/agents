Memory, Assembly, Understanding
===============================
This file is a copy of
[DesignNotes-L](https://github.com/opencog/sensory/blob/master/DesignNotes-L.md)
from the [sensory project](https://github.com/opencog/sensory/),
modified and edited to suit this project.

The goal is to find a simple design that could provide a verbal (text)
interface to complex structural systems, as well as a rudimentary form
of memory. It is based on using an LLM to generate vector embeddings of
text snippets; these vector embeddings are then be associated with
matching algorithms written in Atomese, and their corresponding
interface definitions (also written in Atomese).

The LLM will be ollama, and the Atomese wrapper for it will be
`OllamaNode` as implemented in the sensory project.

The perspective is that of "semantic routing": the LLM is treated as a
natural language API into non-verbal systems; the "thinking" happens
non-verbally, while the text LLM provides a way of manipulating,
controlling and working with the non-verbal elements. The idea is to
build on the concept of RAG (retrieval-augmented generation), semantic
search or semantic routing, by building quads of
```
   (text, vector-embedding-of-text, Atomese-algo, Atomese-IDL).
```

The current intent is that `Atomese-algo` will be some executable
Atomese code snippet, ready-to-run, and that `Atomese-IDL` will be a
sheaf-theoretic, Link-Grammar inspired "jigsaw interface" to the code
snippet.

The overall design is not yet clear; so some of these may end up being
triples, not quads, while in other cases, there may be yet more
structural information encoded.

A "memory" architecture
-----------------------
The core architecture builds on the conventional notion of a
conversational context, or of a memory subsystem.  Here, some large
collection of text paragraphs (e.g. my diary, or perhaps these design
notes) are split up into paragraph (or half-page) sized chunks. These
are run through ollama to get embedding vectors. The pairing of
`(text, vect)` is stored in a vector database; input queries use cosine
similarity to find the most-similar vectors, and thus the associated
text.

A list of design choices:
* At this time, using a simple ollama mode, such as `nomic-embed-text`
  is presumed to be sufficient.
* The vector DB will be implemented in pure Atomese. This is both a
  terrible and a great design choice. It is terrible, because the
  performance will surely be a disaster. It is great, because it will
  force an exposition of "Atomese-as-pseudocode" which can be migrated
  to different implementations, while maintaining the same, or similar
  API's.
* That is, part of this experiment is to also explore the homotopic
  transformation of Atomese.

That is, a pure Atomese description is to be created of what a vector DB
should do. In essence, the Atomese can be thought of as pseudo-code,
except that it is a bit more precise, since Atomese is directly
executable. How well the API of that Atomese can be described is a part
of the experiment.

FWIW, the pure-Atomese version needs to also implement the search algo.
* IVF -- inverted file index: Assign the vectors to k-means clusters,
  then do dot-products against the clusters.
* HNSW -- "Hierarchical Navigable Small World" -- build a graph of
  nearest neighbors, and then hill-climb (i.e. "greedy") to find
  closest
* ColBERT -- vectorize tokens, sum max tokens (???)
* My old "membership club" idea from the learn project.

Jigsaw API's
------------
See the section of the same title in
[DesignNotes-L](https://github.com/opencog/sensory/blob/master/DesignNotes-L.md).
That section exposes the general theoretical setting that motivates this
specific design. There's no point in repeating it here.

Storyboard
----------
How might this work? At the simplest level, it looks like "skills":
there's an English-language paragraph that says "To find all files with
filename X, run the following query." and then there is the actual
Atomese, stored as the third part of that triple.

The first stumbling block is how to plug in the value for X into the
Atomese. The standard solution is "prompt-based tool calling", where I
have an extra paragraph explaining to ollama how to extract filenames
from user text. This solution is fragile: as complexity grows, the LLM
is increasingly confused about what is going on, where the parameters
are.

Few-shot prompting, giving examples, is more effective.

Three Design Tasks
------------------
The following comes up:
* Can I generate sheaf sections from Atomese, i.e. create the IDL
  section for a dot-product, given the Atomese expression for the
  dot-product? (or rather, can I trick Claude into doing this?)
* I need to (initially, at least) pair the Atomese expression, e.g.
  for a dot product, with a verbal description. This pairing is already
  available as a demo.scm file somewhere, but it is informal. A more
  direct, formalized pairing seems desirable ... but how?
* I need a way of composing jigsaws, mediating in English.  I can
  verify formal compositionality by running them through LG or perhaps
  some simpler formal system...

Clauding
--------
I wrote the below for Claude:

I have a demo file, called dot-product.scm  that is written to be an
example tutorial for human readers. It shows how to compute the dot
product of two vectors, in pure Atomese. It is annotated in such a way
as to explain exactly what is going on. But it is also entirely
stand-alone -- it includes boilerplate to set things up, and print
statements that print to stdout -- it assumes that a human will be
cutting and pasting from that file to a guile REPL prompt.  I need this
converted to a lexical entry, which will be stored in the AtomSpace.
This lexical entry will consist of one or more blobs of text (a vector
of blobs of text!) that explain the Atomese for a dot-product.
Associated with this blob is the actual code for the dot product. Next,
there needs to be a precise jigsaw definition of the inputs and outputs,
and finally a blob of text that describes the jigsaw.

So this is a four-vector: a verbal description of the code, the code
itself, the IDL of the code, and a verbal description of the IDL. The
precise IDL exists because I have tools that can explicitly verify the
syntactic correctness of the attachment of any two connectors.

I will be asking a sophisticated LLM, such as you, Claude,  to help
create this four-vector. However, I would like to have a simpler system,
such as ollama, work with the actual assembly of the jigsaws into more
complex subsystems.  For this last part, this four-vector can be
extended with additional floating-point vectors that are embeddings of
the text.  This is the general idea. The overall design remains a bit
vague, as do the precise usage patterns.

And what did Claude say in response? "This is a genuinely novel
architecture". Fuck me. Every time I try something novel with Claude,
I get a ball of spaghetti code, and I am trying to figure out how to
avoid that, here.

Basically, Claude echoed back what I said above, then asked a bunch of
shallow, inane questions that reveal it does not understand the big
picture, but is quite eager to get lost in the details. That is how
spaghetti code is born: the urge to write code, before understanding the
problem. Hmm.
