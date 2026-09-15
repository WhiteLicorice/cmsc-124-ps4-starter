%%%% lint_predictions.pl -- what ./lint runs.
%%%%
%%%% It loads the form checks from validate_predictions.pl. It never opens
%%%% tests/expected.tsv and never runs a case.

:- initialization(main, main).
:- ensure_loaded('validate_predictions.pl').

main(_) :-
    ps4_validate_predictions('predictions.tsv', Problems, Todos),
    (   Problems \== []
    ->  format("== form ==~n"),
        forall(member(P, Problems), format("  ~s~n", [P]))
    ;   true
    ),
    (   Todos \== []
    ->  ( Problems \== [] -> nl ; true ),
        format("== unfinished ==~n"),
        forall(member(T, Todos), format("  ~s~n", [T]))
    ;   true
    ),
    (   Problems == [], Todos == []
    ->  format("predictions.tsv is well formed and complete.~n"),
        format("./lint checked the table's form only. It says nothing about whether an answer is right.~n"),
        halt(0)
    ;   nl,
        (   Problems \== []
        ->  format("Those are formatting faults, not wrong answers. Fix them first.~n")
        ;   true
        ),
        (   Todos \== []
        ->  format("Replace every TODO before you commit the table.~n")
        ;   true
        ),
        halt(1)
    ).
