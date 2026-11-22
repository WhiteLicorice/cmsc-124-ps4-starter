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

The parent facts get scanned in file order, and the first two with tom as parent are liz and bob. Nothing else starts with tom, so two answers.

## P02

No variables here, so an answer is just true. Exactly one fact matches parent(tom, bob), so there's no second answer and the count is 1.

## P03

This asks who tom's parent is, and tom only ever shows up in the first slot. No fact has tom second, so it fails right away: false, none, 0.

## P04

The first goal binds X to f(Y,a) with Y still open. Then Y = b fills in Y, which means X reads f(b,a) too. No goal has a choice left, so one answer.

## P05

Unification goes argument by argument: X takes a, b matches b, Y takes b. Nothing to backtrack into, so one answer.

## P06

Two different atoms can't be unified, so it fails immediately. false, none, 0.

## P07

P binds to tom's first child, liz, but liz has no children so parent(liz,X) fails. Backtracking rebinds P to bob, whose children are ann then pat in fact order. That makes two answers.

## P08

The base clause is first, so tom's direct children come out first: liz, bob. Then the recursive clause goes into liz (nothing) and bob (ann, pat, then sue and jim below them). Six people in total.

## P09

The recursive clause is tried first, so the search goes down tom, bob, ann before it reads any direct fact, and sue comes out first, then jim. The direct children liz and bob come last. Same six people as P08, only the order changes.

## P10

The base clause finds pat, jim's parent. The recursive clause then walks the parent facts in order: tom works through bob and pat, and bob works through pat. That gives pat, tom, bob.

## P11

The first clause starts with reach(a,Z), which calls itself with the same arguments before it reads any edge. It never fails and never answers, so every field is unbounded.

## P12

Each clause reads an edge before recursing, so a to b to c and edge(c,d) gives true. After ; it goes around the a, b, c cycle and finds true again, forever. So the count is unbounded.

## P13

Each level matches only one clause, [] or [_|T], so there's no choice. The base case gives 0 and each return adds 1 with is, so N=3 and one answer.

## P14

Run backward, join's base clause comes first, so X=[] and Y=[1,2]. Each recursive step moves one more element into X, giving X=[1] and then X=[1,2]. Three ways to split a two-element list.

## P15

X > 2 runs first, while X is still unbound. That throws an instantiation error before elem ever binds X, so all three fields are error.

## P16

Same goals as P15 but elem comes first and binds X. 1 and 2 fail X > 2, so it backtracks to 3, which passes. No elements are left, so one answer.
