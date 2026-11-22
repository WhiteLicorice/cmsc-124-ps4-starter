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

The goal scans the parent facts in source order, so the first one with tom first binds X to liz. The first `;` backtracks to that point, undoes X=liz, and takes the next match, X=bob. No fact remains after that, so search ends and the count is 2.

## P02

The query has no variables, so it only unifies with the identical fact `parent(tom, bob)`. No bindings to print, so the first answer is true. No other fact matches, so `;` finds nothing (second is none) and the count is 1.

## P03

Since the first argument is a variable, Prolog scans the facts top to bottom and takes each one whose second argument is tom. The fact does not exist, thus the answer is false. Then, first is false, second is none, and count is 0.

## P04

The goals run left to right, so `X = f(Y, a)` unifies X with the term `f(Y, a)`, leaving Y unbound inside it. `Y = b` then binds Y to b, so X’s term reads `f(b, a)` and the first answer is `X=f(b,a),Y=b`, with bindings in order of first appearance. Unification has one way to succeed, so `;` finds nothing (second is none) and the count is 1.

## P05

The `=` is unification, not assignment, so `f(X, b)` and `f(a, Y)` unify if their arguments match pairwise. X pairs with a, so X binds to a, while b pairs with Y, so Y binds to b. The first answer is `X=a,Y=b`, with bindings in order of first appearance. Unification gives a single answer, so `;` finds nothing (second is none) and the count is 1.

## P06

a and b are different atoms, so no binding can make them identical. The query fails at once, so the first answer is false, there is no second answer (second is none), and the count is 0.

## P07

The rule tries `parent(tom, P)` left to right and finds P=liz first, but liz has no children, so `parent(liz, X)` fails and the search backtracks to P=bob. `parent(bob, X)` then gives X=ann first, and the first `;` backtracks into it for X=pat. After that, no more parent facts for bob or tom remain, so first is X=ann, second is X=pat, and the count is 2.

## P08

ancestor tries its base clause first, so `parent(tom, X)` answers before any recursion: first is X=liz, and the first `;` gives X=bob. When those facts run out, the recursive clause goes through liz (who has no children), then bob, whose own children come first (ann, pat), then his deeper descendants (sue through ann, jim through pat). That is six answers in total, so the count is 6.

## P09

Write one to three sentences here. Name the rule that fixes each field.

## P10

Write one to three sentences here. Name the rule that fixes each field.

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

