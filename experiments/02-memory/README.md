Memory, Embeddings, Atomese
===========================
A sketch of the design inspiration can be found in 
[DesignNotes-L](DesignNotes-L.md)

Specific steps:
* Steal the CMakefile and the config generator from atomspace-viz/analytics
  These two compile scm files into pure Atomese, stored in RocksDB.
* Use the file-crawler demo mentioned in learn/stream
* Use the OllamaNode unit test to compute the vector embeddings.
* Use the dot-product from one of the example files.

