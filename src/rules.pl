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

% Base case: an empty list reversed is still empty
rev([], []).
% Recursive case: split the list into head H and tail T.
rev([H|T], R) :-
    % First reverse the tail. RT is the reversed tail.
    rev(T, RT),
    % Then stick the head H onto the end of RT.
    %join(RT, [H], R) means: R is RT followed by [H].
    join(RT, [H], R).

% last_of(List, X): X is the last element of List. The empty list has no
% last element, so last_of([], X) must fail.

% Base case: a list with exactly one element. That element is the last one.
last_of([X], X).
% Recursive case: throw away the head and look for the last of the tail.
% [] matches neither clause, so last_of([], X) fails, as required.
last_of([_|T], X) :-
    last_of(T, X).

%%% R3 -- the graph.

% route(From, To, Path): Path is the list of nodes from From to To, in
% order, following edge/2 and never visiting a node twice. A route from a
% node to itself is [From].
%
% This is the public predicate. It starts the walk with [From] as the only
% visited node, then fixes the order of the answer.
route(From, To, Path) :-
    % route_/4 does the real walking. RevPath comes back backwards
    % (newest node first), because we add node to the front as we go.
    route_(From, To, [From], RevPath),
    % Flip it so the path reads From -> ... -> To.
    rev(RevPath, Path).

% route_(Current, Target, Visited, Result): helper that carries the list of
% nodes already visited (newest first).

% Base case: we are already at the target (same name in both spots).
% Stop, and hand back the visited list as the result.
route_(To, To, Visited, Visited).
% Recursive case: take one more step.
route_(From, To, Visited, Path) :-
    % Pick a node Next that has an edge from the current node.
    edge(From, Next),
    % \+ means "cannot be proved". This line says Next must not already be
    % in Visited. This is what stops the a -> b -> c -> a loop.
    \+ elem(Next, Visited),
    % Move to Next, and add it to the front of the visited list.
    route_(Next, To, [Next|Visited], Path).