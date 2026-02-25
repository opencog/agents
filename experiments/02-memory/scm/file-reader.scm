;
; file-reader.scm -- Pure Atomese directory-scanning file-reader pipeline
;
; Declarative pipeline for discovering files in project directories and
; logging each discovered filename to /tmp/agent.log. All definitions are
; pure Atomese — no top-level Trigger or cog-execute! calls — so they
; survive a RocksDB store/restore cycle.
;
; The pipeline has these stages:
;   1. Directory bindings  — PipeLinks for two FileSysNodes
;   2. Log file binding    — TextFileNode in append mode
;   3. dir-open pipeline   — opens directories and log file
;   4. Directory list cmds — PureExec for write-then-read sequencing
;   5. Logging filters     — iterate filenames, write to log
;   6. file-scan pipeline  — lists dirs, caches results, drains logs
;   7. Named file streams  — downstream handles
;   8. file-reader filter  — passthrough placeholder
;
; Runtime usage (after loading from RocksDB):
;   (Trigger (Name "dir-open"))              ; open dirs + log file
;   (Trigger (Name "file-scan"))             ; ls both dirs, log filenames
;   (Trigger (Name "scm file stream"))       ; access scm file list
;   (Trigger (Name "notebook file stream"))  ; access notebook file list
;

(use-modules (opencog) (opencog sensory))

; ---------------------------------------------------------------
; Stage 1 — Directory bindings.
;
; PipeLink is a UniqueLink, so each NameNode can only have one binding.
; The actual FileSysNode PipeLinks are created in build-memory.scm.in
; with CMake-configured project paths. The rest of this pipeline
; references only the NameNodes, which are resolved at runtime.

; ---------------------------------------------------------------
; Stage 2 — Log file binding.
;
(PipeLink (NameNode "agent log") (TextFile "file:///tmp/agent.log"))

; ---------------------------------------------------------------
; Stage 3 — dir-open pipeline.
;
; When triggered, opens both directory FileSysNodes and the log file
; for StringValue streaming.
;
(PipeLink
	(Name "dir-open")
	(TrueLink
		(SetValue (NameNode "scm dir") (Predicate "*-open-*")
			(Type 'StringValue))
		(SetValue (NameNode "notebook dir") (Predicate "*-open-*")
			(Type 'StringValue))
		(SetValue (NameNode "agent log") (Predicate "*-open-*")
			(Type 'StringValue))))

; ---------------------------------------------------------------
; Stage 4 — Directory list commands.
;
; PureExec sequences: first write the "ls" command, then read the
; result. Same pattern as the filesys.scm example.
;
(DefineLink
	(DefinedSchema "list-scm-files")
	(PureExec
		(SetValue (NameNode "scm dir") (Predicate "*-write-*")
			(Item "ls"))
		(ValueOf (NameNode "scm dir") (Predicate "*-read-*"))))

(DefineLink
	(DefinedSchema "list-notebook-files")
	(PureExec
		(SetValue (NameNode "notebook dir") (Predicate "*-write-*")
			(Item "ls"))
		(ValueOf (NameNode "notebook dir") (Predicate "*-read-*"))))

; ---------------------------------------------------------------
; Stage 5 — Logging filters.
;
; Iterate each filename from an ls result. The type guard
; (Type 'StringValue) naturally skips the command-echo ItemNode at
; position 0 of the ls result. Each filename plus a newline is
; written to the log file.
;
(DefineLink
	(DefinedSchema "log-scm-files")
	(Filter
		(Rule
			(TypedVariable (Variable "$fname") (Type 'StringValue))
			(Variable "$fname")
			(TrueLink
				(SetValue (NameNode "agent log") (Predicate "*-write-*")
					(Variable "$fname"))
				(SetValue (NameNode "agent log") (Predicate "*-write-*")
					(Item "\n"))))
		(ValueOf (Anchor "file-pipe") (Predicate "scm files"))))

(DefineLink
	(DefinedSchema "log-notebook-files")
	(Filter
		(Rule
			(TypedVariable (Variable "$fname") (Type 'StringValue))
			(Variable "$fname")
			(TrueLink
				(SetValue (NameNode "agent log") (Predicate "*-write-*")
					(Variable "$fname"))
				(SetValue (NameNode "agent log") (Predicate "*-write-*")
					(Item "\n"))))
		(ValueOf (Anchor "file-pipe") (Predicate "notebook files"))))

; ---------------------------------------------------------------
; Stage 6 — file-scan pipeline.
;
; Lists both directories, caches the results at (Anchor "file-pipe"),
; then drains the logging filters to write every filename to the log.
;
(PipeLink
	(Name "file-scan")
	(TrueLink
		; List and cache
		(SetValue (Anchor "file-pipe") (Predicate "scm files")
			(DefinedSchema "list-scm-files"))
		(SetValue (Anchor "file-pipe") (Predicate "notebook files")
			(DefinedSchema "list-notebook-files"))
		; Log every filename to /tmp/agent.log
		(Drain (DefinedSchema "log-scm-files"))
		(Drain (DefinedSchema "log-notebook-files"))))

; ---------------------------------------------------------------
; Stage 7 — Named file streams.
;
; Downstream stages consume file lists via these named triggers.
;
(Pipe (Name "scm file stream")
	(ValueOf (Anchor "file-pipe") (Predicate "scm files")))
(Pipe (Name "notebook file stream")
	(ValueOf (Anchor "file-pipe") (Predicate "notebook files")))

; ---------------------------------------------------------------
; Stage 8 — File reader (passthrough placeholder).
;
; A Filter with a trivial Rule that accepts every StringValue and
; returns it unchanged. Replace the rewrite body with real per-file
; processing in a future step.
;
(DefineLink
	(DefinedSchema "file-reader")
	(Filter
		(Rule
			(TypedVariable (Variable "$fname") (Type 'StringValue))
			(Variable "$fname")
			(Variable "$fname"))
		(Name "scm file stream")))

; ---------------------------------------------------------------
