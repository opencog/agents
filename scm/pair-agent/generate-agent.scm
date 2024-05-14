;
; generate-agent.scm
;
; Scaffolding for bringup.
;
; Load everything.
; guile -l run-common/cogserver-mst.scm
;
(use-modules (opencog) (opencog exec))
(use-modules (opencog persist) (opencog persist-rocks))
(use-modules (opencog nlp))
(use-modules (opencog learn))
(use-modules (opencog sensory))
(use-modules (srfi srfi-1))

; How many edges?
(cog-incoming-size (Bond "ANY"))

; Find next word after WORD
(define (make-next-word-qry WORD)
	(Meet (Variable "next") ; vardecl
		(EdgeLink (Bond "ANY")
			(List WORD (Variable "next")))))

; check it out
(cog-incoming-size (Word "start"))
(cog-incoming-size-by-type (Word "start") 'List)

(define next-list
	(cog-execute! (make-next-word-qry (Word "start"))))

(length (cog-value->list next-list))

; The MI sits on the edges, so repeat the above, with edges.
(define (make-next-edge-qry WORD)
	(Query (Variable "next") ; vardecl
		(EdgeLink (Bond "ANY") (List WORD (Variable "next"))) ; pattern
		(EdgeLink (Bond "ANY") (List WORD (Variable "next"))) ; output
	))

; Look at it.
(define next-edges
	(cog-execute! (make-next-edge-qry (Word "start"))))

(length (cog-value->list next-edges))
(cog-keys (car (cog-value->list next-edges)))

(cog-value (car (cog-value->list next-edges)) (Predicate "*-Mutual Info Key-*"))




