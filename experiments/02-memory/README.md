Memory, Embeddings, Atomese
===========================
A sketch of the design inspiration can be found in 
[DesignNotes-L](DesignNotes-L.md)

Directory layout
----------------
* `scm` -- Atomese. Run `start.scm` to get started.
* `notebook` -- Collection of documentation, written by Claude,
  describing what this system is, how it works, what to do, what it
  means, what was done, and how to use it. This will presumably be
  quite the mess of text files. It will presumably be partly inadequate,
  out-dated, incomplete, mis-guided and confused. Part of the
  experiment is to see how far we can go here.

Build, Install, Run
-------------------
Do this:
```
mkdir build; cd build; cmake ..; make -j
sudo make install
../scm/start.scm
```


Specific steps
--------------
* Use the file-crawler demo mentioned in learn/stream
* Use the OllamaNode unit test to compute the vector embeddings.
* Use the dot-product from one of the example files.

