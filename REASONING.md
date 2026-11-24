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

Since `X` is a variable, the program searches the knowledge base for the first valid match of the of the parent functor with `tom` as the first value. Prolog finds `liz` first in the knowledge base and is returned by the program. `;` as an `or` operator, checks for additional matches and thus finds `bob` then stops there and returns `false` since no more matches exist.

## P02

`parent(tom, bob)` is a complex term that exists in the knowledge base and would thus return `true`. Since there are no variables involved, then there is no answer produced after a `;` .

## P03

The answer is `false` since there is no complex term `parent` in the knowledge base that contains `tom` and `bob` as its arguments.

## P04

Prolog would return `true` since the unification of a atom, constant, or complex term and a variable would always return `true` since the variable would be instantiated into the atom, constant or complex term.

Correction: If the program does not cite the knowledge base, then the grader would return the unifications where the conditions stated inside the input would be satisfied. In this case, the query returns `X=f(b,a,Y=b)` instead of `true`

## P05

The grader would return an `unbound` since an infinite recursion would occur. Since `X` would be instantiated into `f(a, Y)` and `Y` would be instantiated into `f(X, b)`, it would infinitely try to substitute the variables for each depth leading to memory running out in older versions of Prolog or being cut short by modern ones.

## P06

Write one to three sentences here. Name the rule that fixes each field.

## P07

Write one to three sentences here. Name the rule that fixes each field.

## P08

Write one to three sentences here. Name the rule that fixes each field.

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

