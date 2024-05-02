;
; pair-count.scm -- Example demo of assembling a word-pair counter.
;
; Prototype hand-built agent capable of counting things observed
; in the external environment.
;
; Demos counting of word-pairs observed by looking at a text file.
; The Sensory API allows easy generalization to other text sources,
; so working with files is OK for now.
;
; The dataflow pipeline is hand-crafted. (The sensory API is supposed
; to eventually auto-build these pipelines, but that code is not working
; yet.) You'll notice that the pipeline below is ... complicated.
;
; The "rest of the demo", where we do something with the word pairs,
; is in "generate.scm".

(use-modules (opencog) (opencog exec) (opencog persist))
(use-modules (opencog nlp) (opencog nlp lg-parse))
(use-modules (opencog sensory))
(use-modules (srfi srfi-1))

; --------------------------------------------------------------
; Return a text parser that counts edges on a stream. The
; `txt-stream` must be an Atom that can serve as a source of text.
; Typically, `txt-stream` will be
;    (ValueOf (Concept "some atom") (Predicate "some key"))
; and the Value there will be a LinkStream from some file or
; other text source.
;
; These sets up a processing pipeline in Atomese, and returns that
; pipeline. The actual parsing all happens in C++ code, not in scheme
; code. The scheme here is just to glue the pipeline together.
(define (make-parser txt-stream)
	;
	; Pipeline steps, from inside to out:
	; * LGParseBonds tokenizes a sentence, and then parses it.
	; * The PureExecLink makes sure that the parsing is done in a
	;   sub-AtomSpace so that the main AtomSpace is not garbaged up.
	;
	; The result of parsing is a list of pairs. First item in a pair is
	; the list of words in the sentence; the second is a list of the edges.
	; Thus, each pair has the form
	;     (LinkValue
	;         (LinkValue (Word "this") (Word "is") (Word "a") (Word "test"))
	;         (LinkValue (Edge ...) (Edge ...) ...))
	;
	; The outer Filter matches this, so that (Glob "$edge-list") is
	; set to the LinkValue of Edges.
	;
	; The inner Filter loops over the list of edges, and invokes a small
	; pipe to increment the count on each edge.
	;
	; The counter is a non-atomic pipe of (SetValue (Plus 1 (GetValue)))
	;
	(define NUML (Number 4))
	(define DICT (LgDict "any"))

	; Increment the count on one edge.
	(define (incr-cnt edge)
		(SetValue edge (Predicate "count")
			(Plus (Number 0 0 1)
				(FloatValueOf edge (Predicate "count") (FloatValueOf (Number 0 0 0))))))

	; Given a list (an Atomese LinkValue list) of parse results,
	; extract the edges and increment the count on them.
	(define (count-edges parsed-stuff)
		(Filter
			(Rule
				; (Variable "$edge")
				(TypedVariable (Variable "$edge") (Type 'Edge))
				(Variable "$edge")
				(incr-cnt (Variable "$edge")))
			parsed-stuff))

	; Parse text in a private space.
	(define (parseli phrali)
		(PureExecLink (LgParseBonds phrali DICT NUML)))

	; Given an Atom `phrali` holding text to be parsed, get that text,
	; parse it, and increment the counts on the edges.
	(define (filty phrali)
		(Filter
			(Rule
				; Type decl
				(Glob "$x")
				; Match clause - one per parse.
				(LinkSignature
					(Type 'LinkValue) ; the wrapper for the pair
					(Type 'LinkValue) ; the word-list
					(LinkSignature    ; the edge-list
						(Type 'LinkValue)  ; edge-list wrapper
						(Glob "$edge-list")))      ; all of the edges
				; Pipeline to apply to the resulting match.
				(count-edges (Glob "$edge-list"))
			)
			(parseli phrali)))

	; Return the parser.
	(filty txt-stream)
)

; --------------------------------------------------------------
; Demo wrapper showing how to use the above: Parse a string.
; PLAIN-TEXT should be a scheme string.
;
; Verify this works as follows:
;    (obs-txt "this is a test")
;    (cog-report-counts)
; Note the abundance of WordNodes listed in the report.
;    (cog-get-atoms 'WordNode)
; Cleanup after use:
;    (for-each cog-extract-recursive! (cog-get-atoms 'WordNode))
;    (extract-type 'WordNode)
(define (obs-txt PLAIN-TEXT)

	; We don't need to create this over and over; once is enough.
	(define txt-stream (ValueOf (Concept "foo") (Predicate "some place")))
	(define parser (make-parser txt-stream))

	(define phrali (Phrase PLAIN-TEXT))
	(cog-set-value! (Concept "foo") (Predicate "some place") phrali)

	(cog-execute! parser)

	; Remove the phrase-link, return the list of edges.
	(cog-set-value! (Concept "foo") (Predicate "some place") #f)
	(cog-extract-recursive! phrali)
)

; --------------------------------------------------------------
; Demo wrapper: Parse contents of a file.
(define (obs-file FILE-NAME)

	; We don't need to create this over and over; once is enough.
	(define txt-stream (ValueOf (Concept "foo") (Predicate "some place")))
	(define parser (make-parser txt-stream))

	(define phrali (Open (Type 'TextFileStream)
		(Sensory (string-append "file://" FILE-NAME))))

	(cog-execute!
		(SetValue (Concept "foo") (Predicate "some place") phrali))

	; Parse only first line of file:
	; (cog-execute! parser)

	; Loop over all lines.
	(define (looper) (cog-execute! parser) (looper))

	; At end of file, exception will be thrown. Catch it.
	(catch #t looper
		(lambda (key . args) (format #t "The end ~A\n" key)))

	(cog-extract-recursive! phrali)
)

; --------------------------
; Issues.
; Parses arrive as LinkValues. We want to apply a function to each.
; How? Need:
; 4) IncrementLink just like cog-inc-value!
;    or is it enough to do atomic lock?
;    Make SetValue exec under lock. ... easier said than done.
;    risks deadlock.
;
; cog-update-value calls
; Ideally, call asp->increment_count(h, key, fvp->value()));

; Below works but is a non-atomic increment.
(define ed (Edge (Bond "ANY") (List (Word "words") (Word "know"))))
(define (doinc)
	(cog-execute!
		(SetValue ed (Predicate "count")
			(Plus (Number 0 0 1)
				(FloatValueOf ed (Predicate "count") (Number 0 0 0))))))

; Here's a demo of what file-access looks like.
(cog-execute!
   (SetValue (Concept "foo") (Predicate "some place")
      (FileRead "file:///tmp/demo.txt")))

; Wait ...
(define txt-stream-gen
	(ValueOf (Concept "foo") (Predicate "some place")))

; (cog-execute! (LgParseBonds txt-stream-gen DICT NUML))

; (load "count-agent.scm")
; (obs-txt "Some kind of sentence to process, hell yeah!")
; (obs-file "/tmp/demo.txt")
; (cog-report-counts)
; (cog-get-atoms 'WordNode)
