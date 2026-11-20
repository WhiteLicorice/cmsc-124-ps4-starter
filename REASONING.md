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

Write one to three sentences here. Name the rule that fixes each field.

## P02

Write one to three sentences here. Name the rule that fixes each field.

## P03

Write one to three sentences here. Name the rule that fixes each field.

## P04

Write one to three sentences here. Name the rule that fixes each field.

## P05

Write one to three sentences here. Name the rule that fixes each field.

## P06

Write one to three sentences here. Name the rule that fixes each field.

## P07

Write one to three sentences here. Name the rule that fixes each field.

## P08

Write one to three sentences here. Name the rule that fixes each field.

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

