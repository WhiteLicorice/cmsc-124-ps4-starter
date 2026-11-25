# The Search and the Stack

P13 trace from SWI-Prolog 9.0.4:

```text
== trace P13 ==
Call: len([a,b,c],N)
  Call: len([b,c],_)
    Call: len([c],_)
      Call: len([],_)
      Exit: len([],0)
      Call: _ is 0+1
      Exit: 1 is 0+1
    Exit: len([c],1)
    Call: _ is 1+1
    Exit: 2 is 1+1
  Exit: len([b,c],2)
  Call: N is 2+1
  Exit: 3 is 2+1
Exit: len([a,b,c],3)
answer 1: N=3
Redo: len([a,b,c],3)
  Redo: 3 is 2+1
  Fail: N is 2+1
  Redo: len([b,c],2)
    Redo: 2 is 1+1
    Fail: _ is 1+1
    Redo: len([c],1)
      Redo: 1 is 0+1
      Fail: _ is 0+1
      Redo: len([],0)
      Fail: len([],_)
    Fail: len([c],_)
  Fail: len([b,c],_)
Fail: len([a,b,c],N)
== 1 answer ==
```

## Explanation

I think of every `Call` line as pushing a new frame onto the stack, the same
way a function call does in Activity 15. In the P13 trace the indentation
shows it: `len([a,b,c],N)` calls `len([b,c],_)`, which calls `len([c],_)`,
which calls `len([],_)`, so four frames are stacked before anything comes
back. The `is` goals also get their own short frame. `Exit` is where a goal
returns its answer to the caller, like `len([],0)` handing back 0 so
`_ is 0+1` can compute 1. In a language like C that would be the pop. In
Prolog the real pop is `Fail`, because a goal only fails when it has no
clauses left, so nothing can come back to it. You can see the frames getting
popped from the inside out at the bottom of the trace: `len([],_)`, then
`len([c],_)`, then `len([b,c],_)`, and last `len([a,b,c],N)`.

The part that surprised me is that an `Exit` does not throw the frame away.
When I asked for a second answer, the trace prints `Redo: len([a,b,c],3)` and
walks back down into frames that had already exited. In Activity 15, once a
function returns, its activation record is gone, along with its locals and
its place in the code. Prolog keeps a choice point instead, which remembers
which clause the goal used and what it bound, so `Redo` can go back and try
the next clause. For `len([],0)` that next clause is `len([_|T],N)`, which
can't match `[]`, so it fails. The `is` goals have no other way to succeed
either, so each one fails right after its `Redo`. That's why `N=3` is the
only answer and the search ends.

The difference is whether a step uses something up before it recurses. The
first clause of `reach/2` is `reach(X,Z), edge(Z,Y)`, so `reach(a,d)`
immediately calls `reach(a,Z)` with the same `X` and no edge read yet. That
goal is no smaller, so it keeps pushing frames and never reaches the base
clause, which is why P11 never answers. Swapping the clauses lets `edge(X,Y)`
run first, so it can find `d`, but it would still loop if you ask for more
answers because of the cycle. `ancestor/2` is different because every
recursive step reads a `parent(A,P)` fact before calling `ancestor(P,D)`. The
family tree is finite and has no cycles, so the recursion has to stop, and
swapping the clauses only changes which answers come first, like P08 compared
to P09. My R1 `descendant/2` works like `ancestor/2`: its recursive clause
reads `parent(P,D)` first and then calls `descendant(P,A)`, so each step
climbs one generation up and it always terminates.
