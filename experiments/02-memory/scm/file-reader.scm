;
; file-reader.scm -- Pure Atomese file-reading pipeline
;
; Declarative pipeline for reading a text file line-by-line. All
; definitions are pure Atomese — no top-level Trigger or cog-execute!
; calls — so they survive a RocksDB store/restore cycle.
;
; The pipeline has three stages:
;   1. File binding  — PipeLink mapping a name to a TextFileNode
;   2. File open     — "file-open" pipeline wires the stream
;   3. Text stream   — "text stream" delivers lines one at a time
;   4. Line reader   — passthrough Filter (placeholder for processing)
;
; Runtime usage (after loading from RocksDB):
;   (Trigger (Name "file-open"))                        ; open & wire
;   (Trigger (Name "text stream"))                      ; read one line
;   (Trigger (Drain (DefinedSchema "line-reader")))     ; drain all
;
(use-modules (opencog) (opencog sensory))

; ---------------------------------------------------------------
; Stage 1 — File binding.
;
; PipeLink is a UniqueLink: creating a new PipeLink with the same
; NameNode silently replaces the old one, so the file path can be
; changed at runtime without touching the rest of the pipeline.
;
(PipeLink (NameNode "file node") (TextFile "file:///tmp/demo.txt"))

; ---------------------------------------------------------------
; Stage 2 — File-open pipeline.
;
; When triggered, this opens the file for StringValue streaming and
; installs the resulting stream at (Anchor "file-pipe") under
; (Predicate "text source"). The DontExec prevents the stream from
; being consumed during installation.
;
(PipeLink
	(Name "file-open")
	(TrueLink
		(SetValue (NameNode "file node") (Predicate "*-open-*")
			(Type 'StringValue))
		(SetValue (Anchor "file-pipe") (Predicate "text source")
			(DontExec
				(ValueOf (NameNode "file node") (Predicate "*-stream-*"))))))

; ---------------------------------------------------------------
; Stage 3 — Named text stream.
;
; Downstream stages consume lines via (Trigger (Name "text stream")).
; Each trigger returns one line from the file as a StringValue.
;
(Pipe
	(Name "text stream")
	(ValueOf (Anchor "file-pipe") (Predicate "text source")))

; ---------------------------------------------------------------
; Stage 4 — Line reader (passthrough placeholder).
;
; A Filter with a trivial Rule that accepts every StringValue and
; returns it unchanged. Replace the rewrite body with real processing
; (e.g. LgParseBonds, regex extraction) in a future step.
;
(DefineLink
	(DefinedSchema "line-reader")
	(Filter
		(Rule
			(TypedVariable (Variable "$line") (Type 'StringValue))
			(Variable "$line")
			(Variable "$line"))
		(Name "text stream")))

; ---------------------------------------------------------------
