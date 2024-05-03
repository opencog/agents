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
				(FloatValueOf edge (Predicate "count")
					(FloatValueOf (Number 0 0 0))))))

	; Given a list (an Atomese LinkValue list) of parse results,
	; extract the edges and increment the count on them.
	(define (edge-counter EDGE-LIST)
		(Filter
			(Rule
				(TypedVariable (Variable "$edge") (Type 'Edge))
				(Variable "$edge")
				(incr-cnt (Variable "$edge")))
			EDGE-LIST))

	; Given PASRC holding a stream of parses, filter out the edges,
	; and then applu function FUNKY to each edge.
	(define (edge-filter PASRC FUNKY)
		(Filter
			(Rule
				(LinkSignature
					(Type 'LinkValue)
					(Variable "$words")
					(Variable "$edge-list"))
				; Apply the function FUNKY to the edge-list
				(FUNKY (Variable "$edge-list")))
			PASRC))

	; Parse text in a private space.
	(define (priv-parse TXT-SRC)
		(PureExecLink (LgParseBonds TXT-SRC DICT NUML)))

	; I dunno. Is private parsing needed?
	(define (regular-parse TXT-SRC) (LgParseBonds TXT-SRC DICT NUML))

	; Return the parser.
	(edge-filter edge-counter (regular-parse txt-stream))
)

; --------------------------------------------------------------
; Demo wrapper: Parse contents of a file.
(define (obs-file FILE-NAME)

	; We don't need to create this over and over; once is enough.
	(define txt-stream
		(ValueOf (Anchor "parse pipe") (Predicate "text src")))
	(define parser (make-parser txt-stream))

	(define phrali (Open (Type 'TextFileStream)
		(Sensory (string-append "file://" FILE-NAME))))

	(cog-execute!
		(SetValue (Anchor "parse pipe") (Predicate "text src") phrali))

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
