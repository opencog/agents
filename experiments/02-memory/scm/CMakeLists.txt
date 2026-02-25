#
# Memory CMakeLists.txt
#
# Build rules for compiling Atomese memory into RocksDB format.
# During 'make', the .scm files are loaded into an AtomSpace and
# stored to RocksDB. During 'make install', the RocksDB directory
# is copied to the install location.
#

# Define the RocksDB output directory in build tree
SET(MEMORY_RDB_DIR "${CMAKE_BINARY_DIR}/memory.rdb")

# Collect all .scm files in memory directory (excluding build template)
FILE(GLOB MEMORY_SCM_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/*.scm")

# Create the build script from template
SET(BUILD_MEMORY_SCRIPT "${CMAKE_BINARY_DIR}/build-memory.scm")
CONFIGURE_FILE(
    "${CMAKE_CURRENT_SOURCE_DIR}/build-memory.scm.in"
    "${BUILD_MEMORY_SCRIPT}"
    @ONLY)

# Custom command to compile Atomese to RocksDB
# The CURRENT file is a marker that RocksDB uses; we use it to track build status
ADD_CUSTOM_COMMAND(
    OUTPUT "${MEMORY_RDB_DIR}/CURRENT"
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${MEMORY_RDB_DIR}"
    COMMAND guile -l "${BUILD_MEMORY_SCRIPT}"
    DEPENDS ${MEMORY_SCM_FILES}
            "${CMAKE_CURRENT_SOURCE_DIR}/build-memory.scm.in"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    COMMENT "Compiling Atomese memory to RocksDB..."
)

# Custom target that depends on the RocksDB output
ADD_CUSTOM_TARGET(memory-rdb ALL
    DEPENDS "${MEMORY_RDB_DIR}/CURRENT")

# Ensure 'make clean' removes the entire RocksDB directory
SET_DIRECTORY_PROPERTIES(PROPERTIES
    ADDITIONAL_MAKE_CLEAN_FILES "${MEMORY_RDB_DIR}")

# Install the RocksDB directory
# First, remove any existing installation to prevent database corruption
# (mixing old and new RocksDB files will corrupt the database)
INSTALL(CODE "
    set(MEMORY_DEST \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/share/cogserver/memory\")
    if(EXISTS \"\${MEMORY_DEST}\")
        message(STATUS \"Removing old memory database: \${MEMORY_DEST}\")
        file(REMOVE_RECURSE \"\${MEMORY_DEST}\")
    endif()
"
    COMPONENT memory
)

# Now install the new RocksDB directory
# Note: DIRECTORY installs the contents, so memory.rdb/* -> memory/*
INSTALL(DIRECTORY "${MEMORY_RDB_DIR}/"
    DESTINATION share/cogserver/memory
    COMPONENT memory
)
