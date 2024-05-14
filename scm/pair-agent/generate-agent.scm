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



