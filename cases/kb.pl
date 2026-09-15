%%%% kb.pl -- the knowledge base every Part 1 query runs against.
%%%%
%%%% Nothing here uses a cut or negation. The tracer behind ./trace walks
%%%% clauses one at a time and reports every port, and a cut would let a
%%%% clause skip ports the tracer cannot see. Part 2 may use \+ in route/3,
%%%% which is graded on answers and never traced.
%%%%
%%%% Facts are listed in the order Prolog tries them. That order is part of
%%%% what you predict.

%%% A family. parent(P, C) means P is a parent of C.

parent(tom, liz).
parent(tom, bob).
parent(bob, ann).
parent(bob, pat).
parent(pat, jim).
parent(ann, sue).

female(liz).
female(ann).
female(pat).
female(sue).
male(tom).
male(bob).
male(jim).

%%% Given rules over the family.

grandparent(G, C) :-
    parent(G, P),
    parent(P, C).

% The base clause comes first.
ancestor(A, D) :-
    parent(A, D).
ancestor(A, D) :-
    parent(A, P),
    ancestor(P, D).

% The same two clauses, recursive one first. Same answers, different order.
ancestor_r(A, D) :-
    parent(A, P),
    ancestor_r(P, D).
ancestor_r(A, D) :-
    parent(A, D).

%%% A directed graph with one cycle: a -> b -> c -> a, and c -> d.

edge(a, b).
edge(b, c).
edge(c, a).
edge(c, d).

% Left recursion. The recursive call comes before any edge is looked at.
reach(X, Y) :-
    reach(X, Z),
    edge(Z, Y).
reach(X, Y) :-
    edge(X, Y).

% Right recursion. An edge is taken before the recursive call.
reach_r(X, Y) :-
    edge(X, Y).
reach_r(X, Y) :-
    edge(X, Z),
    reach_r(Z, Y).

%%% Lists, defined here rather than taken from the library so that ./trace
%%% can show their clauses.

elem(X, [X|_]).
elem(X, [_|T]) :-
    elem(X, T).

join([], L, L).
join([H|T], L, [H|R]) :-
    join(T, L, R).

len([], 0).
len([_|T], N) :-
    len(T, M),
    N is M + 1.
