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

The goal scans the parent facts in file order and takes each one whose first
argument is tom. There are two matches, liz then bob. So first is X=liz, second
is X=bob, and no fact is left, so the count is 2 successes.

## P02

The query has no variables, so it answers true if some fact matches exactly.
parent(tom, bob) appears once, so first is true. No other fact matches, so
second is none and the count is 1 success.

## P03

The goal scans the parent facts in file order for one whose second argument is
tom. None has tom there, so first is false, second is none, and the count is 0.

## P04

Both goals are =, so no fact is read. X is matched with f(Y,a), then Y with b,
which fills the slot inside X, so first is X=f(b,a),Y=b. = leaves no choice to
go back to, so second is none and the count is 1 success.

## P05

Both sides are f with two slots, so they match slot by slot: X takes a and Y
takes b. So first is X=a,Y=b. = has only one way to succeed, so second is none
and the count is 1 success.

## P06

a and b are two different atoms, and no binding can make them identical, so
the match fails. So first is false, second is none, and the count is 0.

## P07

grandparent runs parent(tom, P) then parent(P, X). P takes liz first, but liz
has no children, so that goal fails and the search goes back to goal 1. P then
takes bob, giving ann and pat in file order. So first is X=ann, second is
X=pat, and the count is 2 successes.

## P08

ancestor tries its base clause first, so tom's children liz and bob come out
first, then the recursive clause goes below each child in file order (bob gives
ann, pat, sue, jim). So first is X=liz, second is X=bob, and the count is 6.

## P09

ancestor_r tries its recursive clause first, so the search goes down to the
deepest person before anything comes out: sue under ann, then jim under pat.
Each person's direct children come out after the branches below them, and the
set is the same six people as P08, so the count is 6.

## P10

ancestor tries its base clause first, so parent(pat, jim) gives X=pat. The
recursive clause then goes through the parent lines in file order, giving tom
(through bob) and then bob (through pat). So first is X=pat, second is X=tom,
and the count is 3.

## P11

The first clause of reach is the recursive one, and its first goal is reach(a,Z),
the same call before any edge is read. It repeats forever and never finds an
answer, so first, second and count are all unbounded.

## P12

reach_r reads an edge before it recurses, so the search reaches d through a, b,
c and finds true at once. On ; it goes back into c, takes edge(c,a), and the
cycle repeats with no visited list, so second is true and the count is unbounded.

## P13

len drops one item per call until [] gives 0, then each is adds 1 on the way
back, so first is N=3. Only one clause fits each list shape, so second is none
and the count is 1.

## P14

join tries its base clause first, so X=[] and Y takes the whole list. Each
round of the recursive clause moves one item from the front of the third list
into X, giving X=[1] and then X=[1,2]. The list runs out after three splits, so
the count is 3.

## P15

Goals run left to right, so X > 2 runs before elem has given X a number. An
unbound X makes > throw an instantiation error, so first, second and count are
all error.

## P16

Goals run left to right, so elem runs first and gives X the values 1, 2, 3 in
turn. X > 2 is checked on each one. 1 and 2 fail and backtrack, and only 3
passes. So first is X=3, there is no second answer, and count is 1.