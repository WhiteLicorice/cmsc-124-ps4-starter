%%%% trace_case.pl -- what ./trace runs. It prints every port of one case's
%%%% search, in order, until the search ends or the line budget runs out.
%%%%
%%%% This is the four-port box model that swipl's own debugger uses, with
%%%% the keystrokes removed. Each goal has four doors. Call is the first
%%%% time the goal is tried. Exit is the goal succeeding with the bindings
%%%% shown. Redo is the search coming back to try the goal's next clause
%%%% after something later failed. Fail is the goal running out of clauses.
%%%% Indentation is the depth of the goal below the query.
%%%%
%%%% You never edit this file. Part 3 asks you to paste one of its outputs
%%%% and explain it.

:- initialization(main, main).
:- ensure_loaded('support.pl').

% How many port lines to print before giving up on a search that has not
% ended. Every finite case in the corpus prints far fewer than this.
ps4_line_budget(400).

main([Id]) :-
    !,
    (   ps4_query(Id, Goal, Names)
    ->  ps4_trace(Id, Goal, Names)
    ;   format(user_error, "unknown case: ~w~n", [Id]),
        halt(65)
    ).
main(_) :-
    format(user_error, "usage: ./trace CASE_ID~n", []),
    halt(64).

ps4_trace(Id, Goal, Names) :-
    format("== trace ~w ==~n", [Id]),
    flag(ps4_lines, _, 0),
    flag(ps4_found, _, 0),
    catch(ps4_trace_all(Goal, Names), Stop, ps4_trace_stopped(Stop, Names)),
    flag(ps4_found, Found, Found),
    (   Found =:= 1
    ->  format("== 1 answer ==~n")
    ;   format("== ~d answers ==~n", [Found])
    ).

ps4_trace_all(Goal, Names) :-
    (   ps4_solve(Goal, 0, Names),
        flag(ps4_found, N, N + 1),
        N1 is N + 1,
        ps4_answer_text(Names, Text),
        format("answer ~d: ~s~n", [N1, Text]),
        fail
    ;   true
    ).

ps4_trace_stopped(ps4_line_budget(Lines), _) :-
    !,
    format("stopped after ~d lines. The search had not ended.~n", [Lines]),
    format("Read the goal that repeats.~n").
ps4_trace_stopped(Error, _) :-
    format("error: the search stopped with an error.~n"),
    print_message(error, Error).

%%% The solver. true and a conjunction have no ports of their own. Every
%%% other goal passes through Call, then Exit or Fail, and through Redo
%%% each time the search comes back for another clause.

ps4_solve(true, _, _) :-
    !.
ps4_solve((A, B), Depth, Names) :-
    !,
    ps4_solve(A, Depth, Names),
    ps4_solve(B, Depth, Names).
ps4_solve(Goal, Depth, Names) :-
    (   ps4_port("Call", Depth, Goal, Names)
    ;   ps4_port("Fail", Depth, Goal, Names),
        fail
    ),
    Deeper is Depth + 1,
    ps4_step(Goal, Deeper, Names),
    (   ps4_port("Exit", Depth, Goal, Names)
    ;   ps4_port("Redo", Depth, Goal, Names),
        fail
    ).

% A goal defined by clauses in the knowledge base is resolved one clause
% at a time, so its body's goals get ports of their own. Anything else,
% such as =, >, and is, is a built-in and runs as one step.
ps4_step(Goal, Depth, Names) :-
    ps4_has_clauses(Goal),
    !,
    clause(Goal, Body),
    ps4_solve(Body, Depth, Names).
ps4_step(Goal, _, _) :-
    call(Goal).

ps4_has_clauses(Goal) :-
    \+ predicate_property(Goal, built_in),
    predicate_property(Goal, number_of_clauses(_)).

ps4_port(Port, Depth, Goal, Names) :-
    ps4_line_budget(Budget),
    flag(ps4_lines, Lines, Lines + 1),
    (   Lines >= Budget
    ->  throw(ps4_line_budget(Budget))
    ;   true
    ),
    ps4_goal_text(Goal, Names, Text),
    ps4_indent_limit(Limit),
    (   Depth =< Limit
    ->  Indent is Depth * 2,
        format("~*c~s: ~s~n", [Indent, 0' , Port, Text])
    ;   Indent is Limit * 2,
        format("~*c[~d] ~s: ~s~n", [Indent, 0' , Depth, Port, Text])
    ).

% Indentation stops growing past this depth and a [depth] marker takes
% over, so a search that keeps going deeper stays on the screen.
ps4_indent_limit(16).

% Print the goal with the query's variable names where they apply and _
% for every other unbound variable. The copy keeps the real goal unbound.
ps4_goal_text(Goal, Names, Text) :-
    copy_term(Goal-Names, Copy-CopyNames),
    maplist(ps4_name_variable, CopyNames),
    term_variables(Copy, Free),
    maplist(=('$VAR'('_')), Free),
    with_output_to(string(Text),
                   write_term(Copy, [quoted(true), numbervars(true)])).

ps4_name_variable(Name=Variable) :-
    (   var(Variable)
    ->  Variable = '$VAR'(Name)
    ;   true
    ).
