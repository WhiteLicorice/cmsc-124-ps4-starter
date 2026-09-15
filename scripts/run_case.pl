%%%% run_case.pl -- what ./run runs. It prints one case's three fields.

:- initialization(main, main).
:- ensure_loaded('support.pl').

main([Id]) :-
    !,
    (   ps4_describe(Id, Fields)
    ->  format("case: ~w~n", [Id]),
        ps4_fields(Names),
        forall(nth1(N, Names, Name),
               ( nth1(N, Fields, Value),
                 format("~s: ~s~n", [Name, Value]) ))
    ;   format(user_error, "unknown case: ~w~n", [Id]),
        halt(65)
    ).
main(_) :-
    format(user_error, "usage: ./run CASE_ID~n", []),
    halt(64).
