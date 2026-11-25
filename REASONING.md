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

The goal scans the parent facts in source order and takes the first whose
first argument is tom. `parent(tom, liz)` matches, so X binds to liz.` parent(tom,bob)` also matches so the X also binds to bob. No other fact matches, so the count is 2.


## P02

The goal scans the parent facts in source order for one with tom first and bob second. `parent(tom, bob)` exists, so the first answer is true. It has no variables and nothing else matches, so the second is none and the count is 1.

## P03

The goal scans the parent facts in source order for one with tom as the second argument. No fact has tom as a child, so the first answer is false, the second is none, and the count is 0.

## P04

Unification makes two terms identical. X = f(Y, a) unifies X with the term f(Y, a), leaving Y unbound, and Y = b then fills Y in, so the first answer is X=f(b,a),Y=b. Each = succeeds once, so the second is none and the count is 1.

## P05

Unification makes two terms identical by binding variables, when that's possible. f(X, b) unifies with f(a, Y) by binding X to a and Y to b, so the first answer is X=a,Y=b. There is only one way to unify them, so the second is none and the count is 1.

## P06

Unification makes two terms identical by binding variables, when that's possible. a doesn't unify with b, because two different atoms are different and no binding can change that. a = b fails, so the first answer is false, the second is none, and the count is 0.

## P07

The body of grandparent runs left to right, so `parent(tom, P)` binds P to liz first, because that fact is written first. `parent(liz, X)` fails, so the search backtracks into the first goal and rebinds P to bob. Then `parent(bob, X)` gives X=ann first and X=pat second, and nothing is left untried, so the count is 2.

## P08

ancestor tries its base clause first, so `parent(tom, X)` gives X=liz first and X=bob second. Backtracking then enters the recursive clause. `ancestor(liz, X)` is a dead end, while `ancestor(bob, X)` gives ann and pat from its base clause, then sue and jim from its recursive clause. The count is 6 with 2 base answers plus 4 recursive answers.

## P09

`ancestor_r(tom, X)` shares the process of `ancestor(tom, X)` (also **recursive**) but returns the bottom-most descendants which are `sue` and `jim`, and count is still `6`.

^^^^^^ [RULE MISSED]: The order of the traceback was switched. Originally, `jim` then `sue` but should be `sue` then `jim`.

## P10

`ancestor(X, jim)` looks for `jim`'s ancestors **recursively** which are `pat` and `bob` directly, and count is `3` because `tom` is the top-most ancestor.

## P11

`reach(a, d)` checks via **recursion** **left-to-right** but since target is `a` and recursively enters the first parameter first, the result is `unbounded`.

## P12

`reach_r(a, d)` checks if `a` can reach `d` via **recursion** (acts like modus ponens) and it can, therefore the only answer is `true`, and count is `unbounded`.

^^^^^^ [RULE MISSED]: The order of the traceback was switched. Originally, `jim` then `sue` but should be `sue` then `jim`.

## P13

`len([a, b, c], N)` records the list's length using **recursion** on variable `N` until the base case. Therefore, the only answer is `N=3` and count is `1`.

## P14

`join(X, Y, [1, 2])` uses **list decomposition** to partition `[1, 2]` into all valid pairings of `X` and `Y`. The first answer is `X=[],Y=[1, 2]`, the second is `X=[1],Y=[2]`, and count is `3` because `X=[1,2],Y=[]` is also valid.

## P15

`X > 2, elem(X, [1-3])` is an invalid statement because arithmetic comparison on unbound variable `X` uses **left-to-right evaluation order**. This triggers an all three fields to be `error`.

## P16

`elem(X, [1-3]), X > 2` first binds `X` to list elements via **unification** before testing `X > 2` and by **left-to-right evaluation order**, it is now valid. Only `X=3` satisfies the condition, making it the only answer so count `1`.
