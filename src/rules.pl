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
sibling(_, _) :-
    throw(not_implemented(sibling/2)).

% cousin(X, Y): a parent of X and a parent of Y are siblings.
cousin(_, _) :-
    throw(not_implemented(cousin/2)).

% descendant(D, A): A is an ancestor of D.
%
% Two clauses, the mirror image of ancestor/2 in cases/kb.pl. The base
% clause reads one parent fact. The recursive clause reads one parent fact
% and then asks a smaller question.
descendant(_, _) :-
    throw(not_implemented(descendant/2)).

%%% R2 -- lists.

% count_of(X, List, N): X occurs N times in List. N is 0 for the empty
% list, which is your base case.
count_of(_, _, _) :-
    throw(not_implemented(count_of/3)).

% rev(List, Reversed): Reversed holds the elements of List in the other
% order. Reverse the tail. Then use join/3 to put the head at the end.
rev(_, _) :-
    throw(not_implemented(rev/2)).

% last_of(List, X): X is the last element of List. The empty list has no
% last element, so last_of([], X) must fail.
last_of(_, _) :-
    throw(not_implemented(last_of/2)).

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
