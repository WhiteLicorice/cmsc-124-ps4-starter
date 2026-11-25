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
    parent(P, X),       % P is a parent of X
    parent(P, Y),       % P is a parent of Y
    X \= Y.             % X and Y are not the same person

% cousin(X, Y): a parent of X and a parent of Y are siblings.

cousin(X, Y) :-
    parent(P1, X),      % P1 is a parent of X  
    parent(P2, Y),      % P2 is a parent of Y
    sibling(P1, P2).    % P1 and P2 are siblings    

% descendant(D, A): A is an ancestor of D.
%
% Two clauses, the mirror image of ancestor/2 in cases/kb.pl. The base
% clause reads one parent fact. The recursive clause reads one parent fact
% and then asks a smaller question.

% D- descendant
% A- ancestor
% P - parent of D

% base case: A is a direct parent of D
descendant(D, A) :-
    parent(A, D).

% recursive case: A is an ancestor of D with parent P
descendant(D, A) :-
    parent(P, D),       % P is a parent of D
    descendant(P,A).    % ask the same question for P and A

%%% R2 -- lists.

% count_of(X, List, N): X occurs N times in List. N is 0 for the empty
% list, which is your base case.
% H - head
% T - tail
% M - count in tail
% N - total count

% base case: empty list, no occurrences of X
count_of(_, [], 0).

% head is X: count occurrences in tail and add 1
count_of(X, [X|T], N) :-
    count_of(X, T, M),      % count X in tail T, result in M
    N is M + 1.             % add 1 for the head occurrence

% head not in X: count occurrences in tail
count_of(X, [H|T], N) :-
    X \= H,                 % head H is not equal to X
    count_of(X, T, N).

% rev(List, Reversed): Reversed holds the elements of List in the other
% order. Reverse the tail. Then use join/3 to put the head at the end.
% H - head
% T - tail
% R - result

% base case
rev([], []).


rev([H|T], R) :-
    rev(T, RT),         % reverse tail T to get RT
    join(RT, [H], R).   % attach [H] to the end


% last_of(List, X): X is the last element of List. The empty list has no
% last element, so last_of([], X) must fail.
% T - tail

% base case: single element list
last_of([X], X).

% recursive case: drop the head and find the last of the tail
last_of([_|T], X) :-
    T \=[],             % tail is not empty
    last_of(T, X).      % last in list is last in tail


%%% R3 -- the graph.

% route(From, To, Path): Path is the list of nodes from From to To, in
% order, following edge/2 and never visiting a node twice. A route from a
% node to itself is [From].

route(From, To, Path) :-
    travel(From, To, [From], RevPath),
    rev(RevPath ,Path).

% base case
travel(To, To, Visited, Visited).

% recursive case
travel(From, To, Visited, Path) :-
    edge(From, Next),
    \+ elem(Next, Visited),
    travel(Next, To, [Next|Visited], Path).


% reach_r/2 in cases/kb.pl walks the same graph and never ends, because
% the cycle a -> b -> c -> a always offers one more edge. Carry the nodes
% you visited. Refuse to step onto one again. \+ Goal is true when Goal
% cannot be proved. That is how you say "not yet visited."