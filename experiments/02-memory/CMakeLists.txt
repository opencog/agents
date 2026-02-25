#
# Memory Experiment CMake file.
#
# This compiles Atomese memory components into RocksDB format
# and installs them to share/atomese/memory.
#
CMAKE_MINIMUM_REQUIRED(VERSION 3.12)

PROJECT(memory-experiment VERSION 0.1.0)

# Find required packages - these must be installed for the build to work
# AtomSpace sets up CMAKE_MODULE_PATH for us
FIND_PACKAGE(AtomSpace REQUIRED)
FIND_PACKAGE(AtomSpaceRocks REQUIRED)
FIND_PACKAGE(Sensory REQUIRED)

# Include the Summary module for build summary output
INCLUDE(Summary)

# Add the scm subdirectory for RocksDB compilation
ADD_SUBDIRECTORY(scm)

# ===================================================================
# Build summary - print at the end so it's the last thing shown
SUMMARY_ADD("AtomSpace" "AtomSpace library" ATOMSPACE_FOUND)
SUMMARY_ADD("AtomSpaceRocks" "RocksDB persistence" ATOMSPACE_ROCKS_FOUND)
SUMMARY_ADD("Sensory" "Sensory (OllamaNode)" SENSORY_FOUND)
SUMMARY_ADD("Memory" "Atomese memory components" TRUE)
SUMMARY_SHOW()
