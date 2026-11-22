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

The goal scans the parent facts in source order and binds X with Liz from the first matching fact. Backtracking continues the scan and binds X to bob for the second answer. No further tom parent facts remain, so the search fails after 2 answers. 

## P02

This is a query with no variables aka a ground query, so there is nothiong to bind to a variable. So the first becomes true, and the backtracking finds no other facts so it fails there. It succeeds only once. 

## P03

There are no facts for the parents of tom, so first and second come out as none, and it succeeds 0 times. 

## P04

The first goal unifies X with the compound term f(Y, a) while Y remains unbound. The second goal then unifies Y with b, which updates X to f(b, a). This single unified state succeeds once, so backtracking finds no second answer and the count is 1.

## P05

f(X, b) = f(a, Y) binds together the variables and the atoms together, and so X binds to a and Y binds to b. This one operation counts as one success on the count. 

## P06

a and b are distinct constants, so the unification fails immediately, so first and second goals are none and count is 0. 

## P07

For ann and pat, the condition that tom is the parent of bob was true, so they get binded to X, with a total count of 2. 

P08

because the ancestor puts first the base clause parent(A, D) before its recursive clause, checking the direct parent relationships in source order first. After the direct matches are exhausted, backtracking enters the recursive clause to do multi-step descendent branches through the finite family tree, and evaluates all valid answers with a total count of 6.

## P09

Because ancestor_r places its recursive clause before its base clause. the language recurses into child branches before trying direct parent matches, reversing the answer order relative to ancestor. Since the tree is fintie and acyclic, backtracking still visits every valid descendant, matching the total count of ancestor in P08 
## P10

First is pat because the base clause runs first and matches parent(pat,jim). Backtracking into the recursive clause scans parent/2 from the top of kb.pl, finding parent(tom, bob) with ancestor(bob, jim) succeeding via pat before reaching parent(bob, pat). The count is 3 because Prolog finds X=pat, X=tom, and X=bob, then fails on further backtracking.

## P11

reach/2 is left-recursive, so querying reach(a, d) immediately calls reach(a, Z1), then reach(a, Z2), infinitely recursing without ever reading an edge/2 fact or producing a first answer before hitting the grader's budget.

## P12

reach_r/2 tests reachability over edge/2 facts and its right-recursive clause, returning true whena valid path exists. Because edge/2 has a cycle (a -> b -> c -> a) and reach_r/2 tracks no visited set, backtracking loops around the cycle endlessly and exhausts the serach budget. 

## P13

[a,b,c] is non-empty, so it skips len([], 0) and unifies with [_|T], binding T = [b, c]. It recurses down to len([], 0), then unwinds bottom-up evaluating N is M + 1, binding N=3. Because the clauses len([], 0) and len([_|T], N) are mutually exclusive at every step, there are no untried choice points left, so second is none and count is 1. 

## P14

The base clause join([], L, L) matches immediately when X is empty, binding Y to the full list [1, 2]. Backtracking into the recusrive clause koin([H|T], L, [H|R]) peels off elements one by one, giving intermediate partitions like X=[1], Y=[2]. Once all 3 valid ways to partition a two-element list are exhausted, the search terminates with a count of 3. 

## P15

Due to X > 2 running before X is bounded to anything, comparing X with > throws an instatiation error. 

## P16

Here, elem(X, [1, 2, 3]) comes first before X > 3, so it successfuly binds X to elements of the list sequentially. 3 passes X > 2, making it the first and only satisfying binding. Backtracking exhausts the remaining choices and finishes with a total count of 3 evaluated attempts.

