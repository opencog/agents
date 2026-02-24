Experiments
===========
This directory contains some loosely related experiments that attempt
to implement various ideas. These are small, personal single-author
software experiments. They all pursue a common goal, using similar
techniques. They are called "experimental" because the author (me,
Linas) does not wish to commit to any specific software framework or
architecture.

That is, these are experiments in creating software frameworks and
architectures; these are path-finders, and may perhaps someday lead to
a robust, usable system.

The Experiments, in chronological order:

### Text processing agent (Dec 2024)
The [01-pair-agent](01-pair-agent) directory contains a prototype for
an agent that could process text files and perform word-pair-counting
on the text therein. It was intended to be a dynamic replacement for
the static batch text-processing pipeline in the
[learn project](https://github.com/opencog/learn).

***Status:*** Created in Dec 2024; abandoned. The file-system crawler
code was moved to (implemented in) the
[motor project](https://github.com/opencog/motor).

***Critique:*** It's not entirely "pure Atomese"; the Atomese remains
glued together with scheme functions.

### Memory (Feb 2026)
The [02-memory](02-memory) directory contains (will contain) an
experiment that tries to combine an LLM API with the basic idea of
Retrieval-augumented generation (RAG) of vector systems, with a
sheaf-theoretic IDL (interface descrition langauge) of the pure
Atomese algos.

----
