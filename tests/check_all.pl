%%%% check_all.pl -- the complete public automated checker. No hidden tests
%%%% assess code behavior. The rubric separately assesses the analysis,
%%%% commit history, and workflow runs.

:- initialization(main, main).
:- ensure_loaded('../scripts/support.pl').
:- ensure_loaded('../scripts/validate_predictions.pl').

main(_) :-
    ps4_report_form_faults,
    ps4_read_table('tests/expected.tsv', Expected),
    ps4_read_table('predictions.tsv', Predictions),
    ps4_check_table_shape('tests/expected.tsv', Expected),
    ps4_check_table_shape('predictions.tsv', Predictions),
    ps4_check_corpus_ids(Expected),
    ps4_check_no_drift(Expected),
    flag(ps4_passed, _, 0),
    flag(ps4_total, _, 0),
    ps4_score_predictions(Expected, Predictions),
    ps4_score_rules,
    ps4_score_analysis,
    flag(ps4_passed, Passed, Passed),
    flag(ps4_total, Total, Total),
    format("~n== result ==~n"),
    format("~d/~d checks passed~n", [Passed, Total]),
    (   Passed =:= Total
    ->  halt(0)
    ;   halt(1)
    ).

%% ps4_abort(+Format, +Arguments)
%
% Stop before the grader scores any check. A run that ends without a
% == result == line never scored anything.
ps4_abort(Format, Arguments) :-
    format(user_error, Format, Arguments),
    nl(user_error),
    halt(1).

%%% A form fault in predictions.tsv survives the parse and then fails its
%%% comparison. That failure reads like a wrong prediction. Report the
%%% faults before scoring so nobody hunts for a search rule they already
%%% understood. The list holds malformations only. A cell that still reads
%%% TODO already shows as a failed check. On a fresh starter every cell
%%% reads TODO.

ps4_report_form_faults :-
    ps4_validate_predictions('predictions.tsv', Problems, _),
    (   Problems == []
    ->  true
    ;   format("== predictions.tsv form ==~n"),
        forall(member(P, Problems), format("  ~s~n", [P])),
        format("~nThose are formatting faults, not wrong answers."),
        format(" Run ./lint to see this list on its own.~n~n")
    ).

ps4_read_table(Path, Rows) :-
    ps4_read_lines(Path, Lines),
    (   Lines == missing
    ->  ps4_abort("~w is missing.", [Path])
    ;   Lines == []
    ->  ps4_abort("~w is empty.", [Path])
    ;   maplist(ps4_split_tab, Lines, Rows)
    ).

ps4_check_table_shape(Path, [Header|Rows]) :-
    ps4_columns(Columns),
    (   Header == Columns
    ->  true
    ;   atomic_list_concat(Columns, '<TAB>', Shown),
        ps4_abort("~w has the wrong columns. The header must be exactly ~w.", [Path, Shown])
    ),
    ps4_ids(Ids),
    maplist([Row, Id]>>(Row = [Id|_]), Rows, FoundIds),
    (   FoundIds == Ids
    ->  true
    ;   ps4_abort("~w must hold P01 through P16 in order.", [Path])
    ),
    length(Columns, Width),
    forall(member(Row, Rows),
           (   length(Row, Found),
               (   Found =:= Width
               ->  true
               ;   Row = [Id|_],
                   ps4_abort("~w, row ~s: found ~d fields, expected ~d. Run ./lint.",
                             [Path, Id, Found, Width])
               )
           )).

ps4_check_corpus_ids([_|Rows]) :-
    maplist([Row, Id]>>(Row = [Id|_]), Rows, TableIds),
    findall(Id, ps4_case(Id, _), CorpusIds),
    (   TableIds == CorpusIds
    ->  true
    ;   ps4_abort("the expected table and the case corpus disagree on case ids.", [])
    ).

%%% Re-derive every published expectation before scoring anything against
%%% it. A stale tests/expected.tsv would otherwise grade a correct
%%% prediction as wrong, and the pair would never learn why.

ps4_check_no_drift([_|Rows]) :-
    ps4_fields(Fields),
    forall(member([Id|Published], Rows),
           (   ps4_describe(Id, Observed),
               forall(( nth1(N, Fields, Field),
                        nth1(N, Published, Want),
                        nth1(N, Observed, Got) ),
                      (   Got == Want
                      ->  true
                      ;   ps4_abort("published expectation drifted for ~s.~s: expected ~s, swipl produced ~s",
                                    [Id, Field, Want, Got])
                      ))
           )).

%%% Scoring.

%% ps4_check(+Label, +Goal)
%
% Score one check. Goal runs under double negation so that a binding it
% makes stays inside it. Every R check lives in one clause body, so the
% checks share a variable such as N. Without the double negation, the first
% check that bound it would decide the rest.
ps4_check(Label, Goal) :-
    flag(ps4_total, T, T + 1),
    (   catch(\+ \+ Goal, Error, ( nb_setval(ps4_error, Error), fail ))
    ->  flag(ps4_passed, P, P + 1),
        format("PASS ~w~n", [Label])
    ;   format("FAIL ~w~n", [Label]),
        (   nb_current(ps4_error, Error),
            Error \== none
        ->  ps4_error_text(Error, Text),
            format("    ~s~n", [Text])
        ;   true
        )
    ),
    nb_setval(ps4_error, none).

%% ps4_error_text(+Error, -Text)
%
% The message for a thrown term. The grader's own terms get their own
% wording. Anything else gets the text swipl prints at the prompt, without
% the ERROR: prefix.
ps4_error_text(not_implemented(Predicate), Text) :-
    !,
    format(string(Text), "~w is not implemented in src/rules.pl", [Predicate]).
ps4_error_text(ps4_unbounded(Goal), Text) :-
    !,
    ps4_budget(Budget),
    copy_term(Goal, Copy),
    term_variables(Copy, Free),
    maplist(=('$VAR'('_')), Free),
    format(string(Text), "the search for ~W did not end within ~d inferences",
           [Copy, [quoted(true), numbervars(true)], Budget]).
ps4_error_text(Error, Text) :-
    (   string(Error)
    ->  Text = Error
    ;   catch(ps4_error_text_via_messages(Error, Text), _, fail)
    ->  true
    ;   format(string(Text), "~w", [Error])
    ).

% translate_message//1 is what print_message/2 uses.
ps4_error_text_via_messages(Error, Text) :-
    '$messages':translate_message(Error, Lines, []),
    with_output_to(string(Raw), print_message_lines(current_output, '', Lines)),
    split_string(Raw, "", "\n\r ", [Text]),
    Text \== "".

%% ps4_bounded(+Goal)
%
% Run Goal under the corpus budget. A search that does not end within it
% counts as a failure with a message, rather than as a hang.
ps4_bounded(Goal) :-
    ps4_budget(Budget),
    call_with_inference_limit(Goal, Budget, Result),
    (   Result == inference_limit_exceeded
    ->  throw(ps4_unbounded(Goal))
    ;   true
    ).

%%% Part 1 -- the prediction table.

ps4_score_predictions([_|ExpectedRows], [_|PredictionRows]) :-
    format("== predictions ==~n"),
    ps4_fields(Fields),
    forall(( nth1(R, ExpectedRows, [Id|Wanted]),
             nth1(R, PredictionRows, [_|Given]) ),
           forall(( nth1(N, Fields, Field),
                    nth1(N, Wanted, Want),
                    nth1(N, Given, Got) ),
                  (   format(atom(Label), "~s.~s", [Id, Field]),
                      ps4_check(Label, Got == Want)
                  ))).

%%% Part 2 -- the rules.

:- dynamic ps4_load_fault/1.
:- dynamic ps4_loading/0.

% Errors printed while consulting src/rules.pl, such as a syntax error, do
% not stop the load. Record them so the load gets a check of its own.
% Without it a file that stops mid-clause leaves every clause above the
% fault defined and scores as if it were whole.
user:message_hook(Term, error, _) :-
    ps4_loading,
    assertz(ps4_load_fault(Term)),
    fail.

ps4_load_rules :-
    assertz(ps4_loading),
    catch(load_files('src/rules.pl', []),
          Error,
          assertz(ps4_load_fault(Error))),
    retractall(ps4_loading).

ps4_score_rules :-
    format("~n== implementation ==~n"),
    ps4_load_rules,
    ps4_check(rules_load,
              (   ps4_load_fault(Fault)
              ->  ps4_error_text(Fault, Why),
                  format(string(Text), "src/rules.pl did not load cleanly. ~s", [Why]),
                  throw(Text)
              ;   true
              )),

    % R1 -- the family.
    ps4_check('R1.sibling_pairs',
              (   findall(X-Y, sibling(X, Y), Pairs),
                  msort(Pairs, Sorted),
                  Sorted == [ann-pat, bob-liz, liz-bob, pat-ann]
              )),
    % The goal-order trap. X \= Y before X and Y are bound fails at once,
    % and this query then answers nothing.
    ps4_check('R1.sibling_of_ann',
              (   findall(X, sibling(ann, X), Siblings),
                  Siblings == [pat]
              )),
    ps4_check('R1.sibling_not_self',
              \+ sibling(ann, ann)),
    ps4_check('R1.cousin_pairs',
              (   findall(X-Y, cousin(X, Y), Pairs),
                  msort(Pairs, Sorted),
                  Sorted == [jim-sue, sue-jim]
              )),
    ps4_check('R1.descendants_of_tom',
              (   findall(X, descendant(X, tom), Descendants),
                  msort(Descendants, Sorted),
                  Sorted == [ann, bob, jim, liz, pat, sue]
              )),
    ps4_check('R1.ancestors_of_sue',
              (   findall(X, descendant(sue, X), Ancestors),
                  msort(Ancestors, Sorted),
                  Sorted == [ann, bob, tom]
              )),

    % R2 -- lists.
    ps4_check('R2.count_of_present',
              (   once(count_of(a, [a, b, a], N)),
                  N == 2
              )),
    ps4_check('R2.count_of_absent',
              (   once(count_of(z, [a, b], N)),
                  N == 0
              )),
    ps4_check('R2.count_of_empty',
              (   once(count_of(a, [], N)),
                  N == 0
              )),
    ps4_check('R2.rev_forward',
              (   once(rev([1, 2, 3], R)),
                  R == [3, 2, 1]
              )),
    % Naive reverse run backward finds its first answer and then searches
    % forever for a second. The check asks for the first one only.
    ps4_check('R2.rev_backward_first',
              (   ps4_bounded(once(rev(X, [1, 2]))),
                  X == [2, 1]
              )),
    ps4_check('R2.last_of',
              (   once(last_of([1, 2, 3], L)),
                  L == 3,
                  \+ last_of([], _)
              )),

    % R3 -- the graph. Every check runs under the budget, because a route
    % without a visited list circles the cycle without end.
    ps4_check('R3.route_a_to_d',
              (   ps4_bounded(once(route(a, d, P))),
                  P == [a, b, c, d]
              )),
    ps4_check('R3.route_around_the_cycle',
              (   ps4_bounded(once(route(c, b, P))),
                  P == [c, a, b]
              )),
    ps4_check('R3.routes_from_a_end',
              (   ps4_bounded(findall(X-P, route(a, X, P), Routes)),
                  msort(Routes, Sorted),
                  Sorted == [a-[a], b-[a, b], c-[a, b, c], d-[a, b, c, d]]
              )),
    ps4_check('R3.route_no_way_back',
              ps4_bounded(\+ route(d, a, _))).

%%% Part 3 -- the analysis.

ps4_score_analysis :-
    format("~n== analysis ==~n"),
    ps4_check(reasoning_written,
              ps4_reasoning_ok),
    ps4_check(analysis_written,
              (   exists_file('ANALYSIS.md'),
                  read_file_to_string('ANALYSIS.md', Text, []),
                  \+ sub_string(Text, _, _, _, "Replace this paragraph"),
                  ps4_prose_word_count(Text, Words),
                  Words >= 300,
                  Words =< 450
              )).

%% ps4_prose_word_count(+Text, -Words)
%
% Count space-separated tokens. Skip the lines a pasted ./trace produces,
% so the trace costs you no words.
ps4_prose_word_count(Text, Words) :-
    split_string(Text, "\n", "\r", Lines),
    exclude(ps4_trace_line, Lines, Prose),
    atomic_list_concat(Prose, ' ', Joined),
    split_string(Joined, " \t", " \t", Tokens),
    exclude(==(""), Tokens, Kept),
    length(Kept, Words).

%% ps4_trace_line(+Line)
%
% True when Line comes from a pasted ./trace block. The tracer prints port,
% answer, and status lines, and its own "error:" line. SWI prints "ERROR:"
% lines. Skip all of them, so a pasted trace costs no words.
ps4_trace_line(Line) :-
    split_string(Line, "", " \t", [Trimmed]),
    ps4_strip_depth_marker(Trimmed, Rest),
    member(Prefix, ["Call:", "Exit:", "Redo:", "Fail:", "answer ", "==", "stopped after", "Read the goal", "error:", "ERROR:"]),
    string_concat(Prefix, _, Rest),
    !.

ps4_strip_depth_marker(Line, Rest) :-
    (   string_concat("[", Tail, Line),
        sub_string(Tail, Before, _, After, "] "),
        sub_string(Tail, 0, Before, _, Digits),
        ps4_whole_number(Digits)
    ->  sub_string(Tail, _, After, 0, Rest)
    ;   Rest = Line
    ).

%%% Part 3 -- the prediction reasoning.

%% ps4_reasoning_ok
%
% The structure check for REASONING.md. It asks for one heading per case,
% in order, with a non-blank line under each, and none of the template's
% placeholder line left. It judges structure only. It sets no word minimum.
ps4_reasoning_ok :-
    (   exists_file('REASONING.md')
    ->  read_file_to_string('REASONING.md', Text, []),
        split_string(Text, "\n", "\r", Lines),
        ps4_reasoning_check(Lines)
    ;   throw("REASONING.md is missing. Add it before the prediction commit.")
    ).

ps4_reasoning_check(Lines) :-
    ps4_expected_headings(Headings),
    ps4_heading_rows(Lines, 1, Headings, Rows),
    ps4_rows_ok(Headings, Rows),
    ps4_sections_check(Lines, Rows).

%% ps4_placeholder(+Line)
%
% The template's placeholder line. The check tests this exact literal, so a
% student who leaves the template line in place fails like an empty section.
ps4_placeholder(Line) :-
    sub_string(Line, _, _, _, "Write one to three sentences here. Name the rule that fixes each field.").

ps4_expected_headings(Headings) :-
    findall(H, ( between(1, 16, N), format(string(H), "## P~|~`0t~d~2+", [N]) ), Headings).

% row(Heading, LineNumber) for every line that is exactly one of the case
% headings, in file order. A line that names no case heading is skipped.
ps4_heading_rows([], _, _, []).
ps4_heading_rows([Line|Rest], LineNo, Headings, Rows) :-
    (   ps4_heading_is(Line, Headings, Heading)
    ->  Rows = [row(Heading, LineNo)|More]
    ;   Rows = More
    ),
    Next is LineNo + 1,
    ps4_heading_rows(Rest, Next, Headings, More).

ps4_heading_is(Line, Headings, Heading) :-
    split_string(Line, "", " \t", [Trimmed]),
    member(Heading, Headings),
    Trimmed == Heading.

% The headings found must be the expected ones, in order. A missing heading
% stops and names the case. A heading out of order stops and names both.
ps4_rows_ok([], []).
ps4_rows_ok([Heading|Headings], [row(Found, _)|Rows]) :-
    Found == Heading,
    ps4_rows_ok(Headings, Rows).
ps4_rows_ok([Heading|_], []) :-
    format(string(Text), "REASONING.md is missing the heading \"~s\". Add it and write the reasoning under it.",
           [Heading]),
    throw(Text).
ps4_rows_ok([Heading|_], [row(Found, _)|_]) :-
    Found \== Heading,
    format(string(Text), "REASONING.md has the heading \"~s\" where \"~s\" must come next. Keep the case headings in order.",
           [Found, Heading]),
    throw(Text).

% Every section needs a non-blank line under its heading, and no section may
% still hold the template's placeholder line.
ps4_sections_check(_, []).
ps4_sections_check(Lines, [row(Heading, LineNo)|Rest]) :-
    ps4_section(Lines, LineNo, Rest, Section),
    (   member(Line, Section),
        ps4_placeholder(Line)
    ->  format(string(Text), "The placeholder is still under \"~s\" in REASONING.md. Replace it with the reasoning.",
               [Heading]),
        throw(Text)
    ;   member(Line, Section),
        ps4_nonblank(Line)
    ->  true
    ;   format(string(Text), "The section under \"~s\" in REASONING.md is empty. Write the reasoning there.", [Heading]),
        throw(Text)
    ),
    ps4_sections_check(Lines, Rest).

ps4_section(Lines, LineNo, Rest, Section) :-
    (   Rest == []
    ->  ps4_lines_after(Lines, LineNo, Section)
    ;   Rest = [row(_, Next)|_],
        Take is Next - LineNo - 1,
        ps4_take_after(Lines, LineNo, Take, Section)
    ).

ps4_lines_after(Lines, 0, Lines) :-
    !.
ps4_lines_after([_|Rest], N, Tail) :-
    N > 0,
    Next is N - 1,
    ps4_lines_after(Rest, Next, Tail).
ps4_lines_after([], _, []).

ps4_take_after(Lines, LineNo, Take, Section) :-
    ps4_lines_after(Lines, LineNo, After),
    length(After, Len),
    (   Len > Take
    ->  length(Section, Take),
        append(Section, _, After)
    ;   Section = After
    ).

ps4_nonblank(Line) :-
    split_string(Line, "", " \t", [Trimmed]),
    Trimmed \== "".
