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

## Your explanation (300–450 words)

Write this section in your own words. Use the trace above as evidence and
connect it to the rules you wrote in `src/rules.pl`. Be sure to explain:

- Which `Call`, `Exit`, and `Fail` lines correspond to stack frames being
  pushed and popped.
- What the `Redo` ports resume that a returned Activity 15 frame has already
  discarded.
- Why recursive `reach/2` can recurse without consuming an edge, while each
  recursive `ancestor/2` step consumes a parent fact. Relate that difference
  to clause order, and briefly connect it to your R1 `descendant/2` rule.
