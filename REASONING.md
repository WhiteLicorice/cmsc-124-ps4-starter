<!--no-pdf-->
# Why Each Prediction Reads the Way It Does

Write one entry per case, before you run anything. Name the rule behind each
predicted field. One to three sentences is enough. The grader checks the
structure of this file only. It does not judge how good the reasoning is, and
it sets no word minimum.

For every case you predicted wrongly, add a short correction after you run
it: what you predicted, what the language printed, and which rule you
misread. Corrections belong in the correction commits, not the prediction
commit.

Commit this file together with `predictions.tsv`, before any case runs:

```bash
git add predictions.tsv REASONING.md
```

The example below uses a query that is not one of the 16 cases, so it gives
no answer away. `parent(pat, X)` reads `parent(pat, jim)` because the `parent`
facts are tried top to bottom and only that one has `pat` as its first
argument:

```text
## parent(pat, X)

The goal scans the parent facts in source order. Only parent(pat, jim) has
pat first, so X binds to jim. No second fact matches, so the first ; finds
nothing and the search ends after one answer.
```

## P01

Since `X` is a variable, the program searches the knowledge base for the first valid match of the of the `parent` functor with `tom` as the first value. Prolog finds `liz` first in the knowledge base and is returned by the program. `;` as an `or` operator, checks for additional matches and thus finds `bob` then stops there and returns `false` since no more matches exist.

## P02

`parent(tom, bob)` is a complex term that exists in the knowledge base and would thus return `true`. Since there are no variables involved, then there is no answer produced after a `;` .

## P03

The answer is `false` since there is no functor `parent` in the knowledge base that contains `tom` and `bob` as its arguments.

## P04

Prolog would return `true` since the unification of a atom, constant, or complex term and a variable would always return `true` since the variable would be instantiated into the atom, constant or complex term.

Correction: If the program does not cite the knowledge base, then the grader would return the unifications where the conditions stated inside the input would be satisfied. In this case, the query returns `X=f(b,a,Y=b)` instead of `true`

## P05

The grader would return an `unbound` since an infinite recursion would occur. Since `X` would be instantiated into `f(a, Y)` and `Y` would be instantiated into `f(X, b)`, it would infinitely try to substitute the variables for each depth leading to memory running out in older versions of Prolog or being cut short by modern ones.

Correction: If two complex terms are tried to be unified, Prolog first checks if both have the same functor and arity. Since both `f(X, b)` and `f(a, Y)` satisfies the conditions, Prolog checks the unification of each corresponding argument, in this case by instantiating the variables of one side to the atoms of the other before finally returning the instantiated values of the variables.

## P06

`a` and `b` are different atoms. Trying to unify the two values would produce no value.

Correction: The output is a boolean `false`.

## P07

The `grandparent` is a rule with it being the head and `parent(G, P), parent(P, C)` as its body. In the knowledge base, there are two items that the variable X could take to satisfy the rule. The two items are reflected under `P07` of `predictions.tsv`

## P08

`P08` demonstrates recursion since a functor calls itself inside its body. `liz` and `bob` are the first and second outputs since they are able to satisfy the base case immediately. In the background, Prolog is able to check the other entries of `parent` and all satisfying the `ancestor` rule.

## P09

By reversing the base case and the recursive case, the program would output the deepest value first for a particular branch. `liz` is the deepest descendant of her lineage which is why she is the first output. On the other hand, `sue` is the deepest descendant of `bob`'s lineage which is why she is the value of `X` in the second output.

Correction: `liz` is not the first output since the parent checks occur inside the the recursive case. Since `P = liz` fails there, `parent(tom, p)` checks the next qualifying arguments and finds `bob` and recurses from there. 

## P10

`P10` checks the ancestors of `jim` and finds `pat` first via the base case. From there, Prolog also checks the `parent` of `pat` through through the recursion and then a base case condition and finds `bob`. The logic works it way up since the recurse case can't find a value for `P` and needs to check `ancestor(P, D)` first before checking `parent(A, P)`.

## P11

Write one to three sentences here. Name the rule that fixes each field.

## P12

Write one to three sentences here. Name the rule that fixes each field.

## P13

Write one to three sentences here. Name the rule that fixes each field.

## P14

Write one to three sentences here. Name the rule that fixes each field.

## P15

Write one to three sentences here. Name the rule that fixes each field.

## P16

Write one to three sentences here. Name the rule that fixes each field.

