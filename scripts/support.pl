%%%% support.pl -- the grader's notation, the answer enumerator, and the
%%%% budget that turns a search that never ends into the word unbounded.
%%%%
%%%% The grader re-derives every published expectation through these
%%%% predicates before it scores a single check. So a change here that
%%%% disagrees with tests/expected.tsv stops the run. The grader never
%%%% scores against a stale table.

:- ensure_loaded('../cases/kb.pl').
:- ensure_loaded('../cases/cases.pl').

ps4_fields(["first", "second", "count"]).

%% ps4_budget(-Inferences)
%
% How much work one query may do before the enumerator stops and
% reports unbounded. Every finite case in the corpus finishes in well under
% a thousand inferences. A search that is still running after this many is
% one that will not end, or one that will fill memory first. Both read
% unbounded.
ps4_budget(200000).

%% ps4_query(+Id, -Goal, -Names)
%
% The goal behind a case id, and the variable names as written in the case
% text, as a list of Name=Variable pairs. Id may be an atom or a string.
% The predicate fails for an unknown id.
ps4_query(Id, Goal, Names) :-
    text_to_string(Id, IdText),
    ps4_case(IdText, Text),
    term_string(Goal, Text, [variable_names(Names)]).

%% ps4_answer_text(+Names, -Text)
%
% One answer in the grader's notation. Names is the Name=Value list after
% the goal succeeded. A query with no variables answers true. Otherwise
% each pair prints as Name=Value, joined with commas and nothing else, in
% the order the names appear in the query. A variable the answer left
% unbound prints as _. No answer ever holds a space.
ps4_answer_text(Names, Text) :-
    include(ps4_visible_name, Names, Visible),
    (   Visible == []
    ->  Text = "true"
    ;   copy_term(Visible, Copy),
        term_variables(Copy, Free),
        maplist(=('$VAR'('_')), Free),
        maplist(ps4_binding_text, Copy, Parts),
        atomic_list_concat(Parts, ',', Atom),
        atom_string(Atom, Text)
    ).

ps4_visible_name(Name=_) :-
    \+ sub_atom(Name, 0, 1, _, '_').

ps4_binding_text(Name=Value, Part) :-
    with_output_to(string(ValueText),
                   write_term(Value, [quoted(true), numbervars(true)])),
    format(string(Part), "~w=~s", [Name, ValueText]).

%% ps4_describe(+Id, -Fields)
%
% The three published fields for Id, as strings, derived by running the
% query. Fields is [First, Second, Count].
%
%   first   the first answer, or false when there is none
%   second  the second answer, or none when there is no second one
%   count   how many answers backtracking finds before the search ends
%
% When the query throws an error, all three read error. When the search
% reaches the budget, count reads unbounded, and so does any answer the
% search did not reach before then.
ps4_describe(Id, [First, Second, Count]) :-
    ps4_query(Id, Goal, Names),
    ps4_budget(Budget),
    flag(ps4_answers, _, 0),
    nb_setval(ps4_recorded, []),
    catch(call_with_inference_limit(ps4_enumerate(Goal, Names), Budget, Result),
          Caught,
          true),
    (   nonvar(Caught)
    ->  (   Caught = error(resource_error(_), _)
        ->  Status = unbounded
        ;   Status = error
        )
    ;   Result == inference_limit_exceeded
    ->  Status = unbounded
    ;   Status = done
    ),
    flag(ps4_answers, Found, Found),
    nb_getval(ps4_recorded, Reversed),
    reverse(Reversed, Recorded),
    ps4_fields_for(Status, Found, Recorded, First, Second, Count).

ps4_enumerate(Goal, Names) :-
    (   call(Goal),
        ps4_record(Names),
        fail
    ;   true
    ).

% Keep the first two answers as text. Count the rest without keeping them.
% nb_setval copies its value, so the list survives the backtracking that
% follows.
ps4_record(Names) :-
    flag(ps4_answers, N, N + 1),
    (   N < 2
    ->  ps4_answer_text(Names, Text),
        nb_getval(ps4_recorded, Sofar),
        nb_setval(ps4_recorded, [Text|Sofar])
    ;   true
    ).

ps4_fields_for(error, _, _, "error", "error", "error").
ps4_fields_for(unbounded, _, Recorded, First, Second, "unbounded") :-
    ps4_nth_or(Recorded, 1, "unbounded", First),
    ps4_nth_or(Recorded, 2, "unbounded", Second).
ps4_fields_for(done, Found, Recorded, First, Second, Count) :-
    ps4_nth_or(Recorded, 1, "false", First),
    ps4_nth_or(Recorded, 2, "none", Second),
    format(string(Count), "~d", [Found]).

ps4_nth_or(List, N, _, Item) :-
    nth1(N, List, Item),
    !.
ps4_nth_or(_, _, Default, Default).
