Build System Setup
==================
Date: 25 February 2026

The build system was created by copying and adapting the CMakeLists.txt
and build script template from atomspace-viz/analytics. These two files
compile .scm files into pure Atomese stored in RocksDB.

Files created:
* `CMakeLists.txt` -- Top-level cmake file in 02-memory/. Checks for
  AtomSpace, AtomSpaceRocks, and Sensory prerequisites, then descends
  into the scm/ subdirectory.
* `scm/CMakeLists.txt` -- Globs all .scm files, runs them through guile
  to populate a RocksDB, and installs it to share/atomese/memory.
* `scm/build-memory.scm.in` -- Template configured by cmake. Loads the
  .scm files into an AtomSpace, opens a RocksStorageNode, and stores
  everything.

To build and install:
```
mkdir build; cd build; cmake ..; make -j
sudo make install
```
