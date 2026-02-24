;
; count-agent.scm -- Agent that performs word-pair counting.
;
; Prototype hand-built agent capable of counting things observed in
; the external environment. Based on the `pair-count.scm` demo in the
; examples directory.
;
; The dataflow pipeline is hand-crafted. (The sensory API is supposed
; to eventually auto-build these pipelines, but that code is not working
; yet.)
;
; The hand-crafted pipe not only works, but works faster than the old
; code, and so has been mad "official" and is now a part of the `learn`
; module. See
; https://github.com/opencog/learn/tree/master/sc,/pipe-parse/pipe-count.scm
;
; The "rest of the demo", where we do something with the word pairs,
; is in "generate.scm".

(use-modules (opencog) (opencog exec) (opencog persist))
(use-modules (opencog nlp) (opencog nlp lg-parse))
(use-modules (opencog learn))
(use-modules (opencog sensory))
(use-modules (srfi srfi-1))

; --------------------------------------------------------------
(define (setup-parser STORAGE)
"
  Create parser attached to storage.
"
	; (make-disjunct-parser ...
	(make-random-pair-parser
		(ValueOf (Anchor "parse pipe") (Predicate "text src"))
		STORAGE)
)

; Demo wrapper: Parse contents of a file.
(define (obs-file FILE-NAME PARSER)

	(define sensor (Sensory (string-append "file://" FILE-NAME)))

	(cog-execute!
		(SetValue
			(Anchor "parse pipe") (Predicate "text src")
			(Open (Type 'TextFileStream) sensor)))

	; Parse only first line of file:
	; (cog-execute! PARSER)

	; Due to a design/implementation failure(??) the above only does
	; one line at a time, although it is sem-intended to stream
	; continuously. But whatever. For now, we loop manually.

	; Loop over all lines.
	(define (looper) (cog-execute! PARSER) (looper))

	; At end of file, exception will be thrown. Catch it. Print it.
	(catch #t looper
		(lambda (key . args) (format #t "The end ~A\n" key)))

	; Cleanup up litter that we don't want in the atomspace.
	(cog-extract-recursive! sensor)
)

; --------------------------
; Run the above demo:
;
#|
(use-modules (opencog persist-rocks))
(define storage-node (MonoStorageNode "monospace:///tmp/foo.rdb"))
(cog-open storage-node)
(define parser (setup-parser storage-node))
(obs-file "/tmp/demo.txt" parser)
;
; Look at results. Poke around, look at counts.
(cog-report-counts)
(cog-get-atoms 'Word)
(cog-execute! (ValueOf (Word "is") (Predicate "*-TruthValueKey-*")))
(cog-get-atoms 'Edge)
(cog-execute! (ValueOf
    (car (cog-get-atoms 'Edge))
    (Predicate "*-TruthValueKey-*")))

; Erase all words, so we can try again.
(extract-type 'WordNode)

(cog-close storage-node)

; Start all over again.
(use-modules (opencog persist-rocks))
(define storage-node (MonoStorageNode "monospace:///tmp/foo.rdb"))
(cog-open storage-node)
(load-atomspace)
(cog-report-counts)

|#

; --------------------------
