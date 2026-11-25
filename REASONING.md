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

Correction: `;` is not an `or` operator in this use case which is after the query prompt. This is why Prolog returns `bob`, since when used in this context `;` backtracks to find another match.

## P02

`parent(tom, bob)` is a complex term that exists in the knowledge base and would thus return `true`. Since there are no variables involved, then there is no answer produced after a `;` .

## P03

The answer is `false` since there is no functor `parent` in the knowledge base that contains `tom` and `bob` as its arguments.

Correction: the predictions here are correct, but for the wrong reasons; `tom` is the 2nd argument here, while X is the first. So we are trying to find `tom`'s parent, but in the knowledge base `tom` is the root. In the unification rules we are comparing 2 different atoms, `tom` as the 2nd argument againsts each facts 2nd argument produces no such fact, as such querying returns `false` since it cant match anything. we have `none` and `0` since nothing is returned.

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

Correction: `x=bob` to `X=bob`, 2nd field was  a lowercase x instead of uppercase, which makes it so `x` does not read as variable since it's not uppercase `X`.

## P09

By reversing the base case and the recursive case, the program would output the deepest value first for a particular branch. `liz` is the deepest descendant of her lineage which is why she is the first output. On the other hand, `sue` is the deepest descendant of `bob`'s lineage which is why she is the value of `X` in the second output.

Correction: `liz` is not the first output since the parent checks occur inside the the recursive case. Since `P = liz` fails there, `parent(tom, p)` checks the next qualifying arguments and finds `bob` and recurses from there. 

## P10

`P10` checks the ancestors of `jim` and finds `pat` first via the base case. From there, Prolog also checks the `parent` of `pat` through through the recursion and then a base case condition and finds `bob`. The logic works it way up since the recurse case can't find a value for `P` and needs to check `ancestor(P, D)` first before checking `parent(A, P)`.

Correction: In the recursion case, since `P` is not yet instantiated but `X` is present, then Prolog would would check the first instance of `parent(X, _)`, which is `parent(tom, liz)` and start from there.

Correction: The recursion works its way top to bottom not bottom to top. `tom`'s facts come first and thus bind first, `bob` binds in another branch. The recursive clause picks candidates from `parent(X, P)` in source order. `count` is 3 since `bob` is reached later on.

## P11

The particular case would recurse infinitely since Prolog checks the recursive call first and thus would not terminate. `reach(a, d)` would call on `reach(a, b)` which would first call on `reach(a, b)` triggering an infinite recursive loop.

Correction: Fix prediction answers for unbounded case, all three fields must contain `unbounded`.

## P12

Prolog checks first if there is an existing direct edge between `a` and `d`, then goes to the recursion case since it finds none. The direct edge checking continues until it sees `edge(c, d)` where it returns `true`. The next result would start the entire process from `reach_r(a, d)` and would return true since `edge(c, d)` exists but its count would be unbound since the entire process can infinitely recurse.

## P13

`P13` is an example of a recursive count. Prolog recurses in `len(T, M)` until it reaches an empty list where it would set the value of `M` to `0`. Then as it goes upwards the recursion calls, it would increment by `1` due to `N is M + 1`.

## P14

`join` in this particular case takes the head of `[1, 2]` and returns it to `X` while `Y` would contain the value of the tail `[2]`. The variable `X` would match its value of `H` to the `H` in `[H|R]` making it equal to `1` and its tail would be `[]`. Lastly, the base case copies the tail of `[H|R]` to `L` and then to `Y`.

Correction: The functor transfers the values of the list towards the variable `X`. Since `X` is not instantiated, then it would assume the value of an empty list when `join` is first called, thus returning `X=[],Y=[1,2]`. However, by the second run, `X` already contains an empty list and thus the transfer through `H` can be done.

Correction: `X` binding is undone on backtracking, and is not shared throughout the entire query. It traces all valid branches with its own `X` bindings and does not see what other branches bind `X` to. first comes from the `join([],L,L)` since it is tried first, `3` count since there's 3 answers that come from different branches of valid joins (3rd answer not shown here), second has the 2nd value returned.

## P15

This case would return an error since comparison requires that both sides must be instantiated into integers first before comparison.

## P16

The condition `X > 2` filters the allowed value of `X` from the list to only be greater than `2`. In this case, `3` is the only allowable value.

