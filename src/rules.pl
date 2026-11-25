%%%% rules.pl -- Part 2. Write the seven predicates below.
%%%%
%%%% The grader loads the facts and given rules in cases/kb.pl before this
%%%% file, so parent/2, edge/2, elem/2, join/3, and len/2 are yours to call.
%%%% The grader scores R1, R2, and R3 separately. Finish them in order. You
%%%% keep every group you get right.
%%%%
%%%% Each stub below throws, so a check you did not reach fails with a
%%%% message that identifies the predicate. Replace the whole stub, head and
%%%% body, with your own clauses. A stub left above your clauses runs first
%%%% and throws before Prolog tries yours.

%%% R1 -- the family.

% sibling(X, Y): X and Y share a parent and are not the same person.
%
% Order matters. X \= Y succeeds only when X and Y are already bound to
% different things, so put it after the goal that binds them.
sibling(X, Y) :-
    parent(P, X),
    parent(P, Y),
    X \= Y.

% cousin(X, Y): a parent of X and a parent of Y are siblings.
cousin(X, Y) :-
    parent(PX, X),
    parent(PY, Y),
    sibling(PX, PY),
    X \= Y.
% descendant(D, A): A is an ancestor of D.
%
% Two clauses, the mirror image of ancestor/2 in cases/kb.pl. The base
% clause reads one parent fact. The recursive clause reads one parent fact
% and then asks a smaller question.
descendant(D, A) :-
    parent(A, D).
descendant(D, A) :-
    parent(P, D),
    descendant(P, A).

%%% R2 -- lists.

% count_of(X, List, N): X occurs N times in List. N is 0 for the empty
% list, which is your base case.
count_of(X, [X|T], N) :-
    count_of(X, T, NT),
    N is NT + 1.

count_of(X, [H|T], N) :-
    X \= H,
    count_of(X, T, N).

% rev(List, Reversed): Reversed holds the elements of List in the other
% order. Reverse the tail. Then use join/3 to put the head at the end.
rev([], []).

rev(X, [H|T], Reversed) :-
    rev(T, RT),
    join(RT, [H], Reversed)

% last_of(List, X): X is the last element of List. The empty list has no
% last element, so last_of([], X) must fail.
last_of([X], X).

last_of([_|T], Last) :-
    last_of(T, Last),

%%% R3 -- the graph.

% route(From, To, Path): Path is the list of nodes from From to To, in
% order, following edge/2 and never visiting a node twice. A route from a
% node to itself is [From].
%
% reach_r/2 in cases/kb.pl walks the same graph and never ends, because
% the cycle a -> b -> c -> a always offers one more edge. Carry the nodes
% you visited. Refuse to step onto one again. \+ Goal is true when Goal
% cannot be proved. That is how you say "not yet visited."
route(_, _, _) :-
    throw(not_implemented(route/3)).
