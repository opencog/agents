#! /usr/bin/env guile
-s
!#
;
; start.scm -- startup script
;
; Opens the installed RocksDB memory, loads all Atomese definitions
; back into the AtomSpace, then runs the directory-scanning pipeline.
;
(use-modules (opencog) (opencog sensory))
(use-modules (opencog persist) (opencog persist-rocks))

; ---------------------------------------------------------------
; Open the RocksDB and load all stored atoms.
;
(define rsn (RocksStorageNode
	"rocks:///usr/local/share/atomese/memory"))
(cog-open rsn)
(load-atomspace)
(cog-close rsn)

; ---------------------------------------------------------------
; Run the file-scanning pipeline.
;
; First open the directory handles and the log file, then scan
; both directories.  Results are cached at (Anchor "file-pipe")
; and logged to /tmp/agent.log.
;
(Trigger (Name "dir-open"))
(Trigger (Name "file-scan"))
