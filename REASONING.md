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

calling `parent(tom, X)` scans parents facts where tom is first and finds where `X` can match the second fact and those values are binded and reported back. It works from top down so `liz` is reported first. We can say that Prolog instantiates `X` to `liz` and to `bob`, or that it binds `X` to them.

## P02

The parent knowledge base is searched and it finds a match, so it says `true`.

## P03

The parent knowledge base is searched and it looks for a parent fact that can match `X` where `tom `is second. After looking through all the parent facts and not finding anything that matches, it returns `false`.

## P04

When the query is run it creates the bindings and then the bindings are reported after the query is complete. In this case `X` is bound to `f(Y, a)` and when `Y` = `b` is ran it binds `Y` to `b` so when the binding is reported `Y` becomes `b` and `X` reports `f(b, a)`.

## P05

The `=` operator attempts to unify the fact `f(X, b)` with fact `f(a, Y)`. variable `X` binds to the matching atom `a`, and atom `b` binds to the matching variable `Y`

## P06

The `=` operator attempts to unify the atom `a` with the atom `b` and returns `false` because only identical atoms can be binded

## P07

`grandparent(tom, X)` unifies `G=tom` and `C=X.` Then it starts with `parent(tom, P)` and gets `P=liz;P=bob` and then starts by unifying `P=liz` then queries `parent(liz, X)`,nothing returns. So then it goes back to the `;` to bind `P=bob` then queries `parent(bob, X)` where it eventually gets to return `X=ann;X=pat` and ~~takes 6 counts to return false because Prolog always starts from the top down of the facts when doing a query~~.

## Correction  

It returns `X=ann;X=pat` after it gets `false` on the second count when reaching `parent(pat, jim)`. My mind was on the ancestor call when I wrote the intial reasoning

## P08

Prolog reads from top down so the first two reports will be `X=liz` and `X=bob` who can bind to the base case of having `tom` as a direct parent. It returns false after going through the whole facts list for `parent`

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

