Generating output
=================
Design notes for generating output text. Two ideas: use LG and use dorky
pairs.

## LG generation
Generate text with Link Grammar. This is the correct long-term solution,
but requires some fair amount of work on the LG side and on the
`lg-atomese` modules, and here. So for proof-of-concept, just skip this
for now.
```
link-generator -c 4 -k 4 -l en
link-generator -l en -s 0
This is * test
echo 'This \* a te\* of \*.a sentence generation' | time link-generator -l en -s 0 --verbosity=2
echo 'This is a \*' | time link-generator -l en -s 0 --verbosity=2
```
Early versions would take prior string and just add one more star.
Or maybe two stars. Keep it short.

General issues:
* Allow link-parser app to special case wild-cards for generation.
* Loading of entire dict is unfeasible, so...
  Load only possible links?

Ideas:
* Parse given word seq containing blanks, use unknown word for
  blanks, then lookup all words with matching disjuncts. This
  requires:
* Allow dict lookup of words according to desired disjuncts.

OK, screw that. There are multiple design issues raised by above.

## Simple chaining
For quick bringup, lets just do simple chaining. Ideas in summary form:

1) Starting with a word A, use incoming set to randomly select some
subset of all possible edges. This will be called the "focus set" or the
"attentional focus". Because it is small, it can be exhaustively
iterated and sorted into high-to-low MI order. This provides a weighted
distribution, from which a rescaled uniform-random choice can be made.

2) Random sample N out of full incoming set.

Lets stream-process this: Query returns list of edges
```
	(Query (Variable "next") ; vardecl
      (EdgeLink (Predicate "ANY")
			(List (Word "start") (Variable "next"))))
```
This returns a list (a short list? where do we plug in N to cap the size?)
The list is actually a `QueueValue`.

3) Out of this queue Value, select one, with the proper weighting.
   Treating this as a collection of priors requires a sum over all elts
   in the queue, to obtain a total norm, and then making a second pass
   to choose one for this weighted distribution. This requires a
   "non-local" RAM-walking sum.

3a) Create a pipeline elt that takes list, adds the weights, then
    selects N random items from that weighted list.

3b) A local way of doing this is to pick a min-MI cutoff, and selecting
    the first elt that is above the cutoff.

3c) A quasi-local way is to take the average of the first three elts,
    the first K elts, and then accept the first that is above this average.
    So the first K are always discarded, until the moving average is arrived
    at.

This needs:
4) Atomese to fish out/Filter the MI from the correct location
   and or compute it on the fly.

   Atomese to compute a moving average.

What is the minimal way to do this?
Can it be done so that MOSES can be applied to tune it?

Ugh.
