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

`ancestor_r` runs it recursive rule first where `X=liz` and fails, and attempts the base rule, which also fails since both attempts to find a fact `parent(liz, C)`, which does not exist. It backtracks to the very first `;` which the recursive rule traces as `bob` -> `ann` -> `sue` and returning `X=sue` with the base case; second backtracks since `sue` has no children and `ann` has no more left, traces `bob` -> `pat` -> `jim` and returning `X=jim` similarly. Retroactively counting the endpoints: `sue`, `ann`, `jim`, `pat`, `liz`, and `bob` which is six answers in total, so the count is 6.

## P10

`ancestor` finds the only matching `parent(X, jim)` for the base case, which is `X=pat`; it then runs the second rule (recursive), with `X=tom` which traces `tom` -> `liz` at first, backtracks to `tom` -> `bob` -> `ann` -> `sue`, and backtracks one last time to have finally `bob` -> `pat` -> `jim`. Total count is 3: the base case match, recursive rule match, and returning none.

## P11

The first rule `reach(X, Y)` always calls its recursive rule `reach(X, Z)`, to which ends in an infinite recursion loop attempting to bind `(X, Z)`, never reaching the base case. Hence, both runs aree unbounded and count cannot be determined.

## P12

The first rule `reach(X, Y)` defines the base case, which is checked first before entering the recursive rule loop when the base case fails. Since `edge(a, d)` does not exist, it runs the recursive rule for `b`, fails the base case `reach_r(c, d)` for `edge(b, d)` and runs the recursion again with `c`, which finally evaluates the base case in `reach_r(c, d)` of `edge(c, d)` to true; running it a second time simply enters another cycle after running the recursive rule for `reach_r(c, a)` and repeats the same steps to `reach_r(c, d)` again; `a` -> `b` -> `c` -> `a` -> `b` -> `c` -> `d`. Its count is unbounded since it cannot count how many answers it finds if it never reaches a false conclusion (cycles when backtracking).

## P13

`len/2` is a predicate with two rules: (1) a base case `len([], 0)` that unifies the 'length' argument to 0 on an empty list; and (2) a recursive-descent rule that splits the list, binding its tail to `T`, recursively calls `len(T, M)` to unify `M` with the tail's 'length', and evaluates `M + 1` to bind `N` as the query's final result. There are no other facts that return a different answer, hence count is 1 and backtracking return no other solutions (none). 

## P14

`join/3` is a predicate with two rules: (1) a base case `join([], L, L)` that matches with an empty list and unifying the remaining two variables; and a recursive rule `join([H|T], Y, [H|R])` that unifies the heads of the first and last list arguments with a unified head `H` and independent tails `T` and `R` respectively, then recurses by querying `join(T, Y, R)`. The first run matches with the base case, unifying `X` -> `[]` and `Y` -> `[1,2]`. Backtracking matches it with the second rule, unifying `H = 1` and `R = [2]`, which unifies `X = [1]` and `T = []` queries into and matches the first rule that unifies `Y = [2]`. Backtracking again matches with the second rule instead, which binds the `H1` (unfies to `X`) -> `[1, 2]` and both `T1` and `R1` -> `[]`, queries into another `join` that matches the base case unifying `Y` -> `[]`; a total of 3 different answers before it fails as no fact matches when attempting to backtrack again. 

## P15

The query will throw an error since `X` is undeclared/uninstantiated prior to executing `X > 2`. Backtracking also throws an error with the same reasoning, hence count cannot be determined falls as an error.

## P16

`elem/2` is a predicate with two rules: (1) a base rule that unifies the first element with the head of the second element; and (2) a recursive rule that queries another `elem/2` without the head of the second list. The top-level query unifies `X` -> `1` (list's head), evaluates whether `X > 2` which is false, backtracks and queries into the second rule, unifies `X` -> `2`, which evaluates into false again; does another backtrack and query again that unifies `X` -> `3`, and finally evaluates into true. Cannot backtrack any further since the fact `elem(X, [])` does not exist, hence count remains as `1`.

