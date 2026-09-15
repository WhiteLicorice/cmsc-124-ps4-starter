%%%% validate_predictions.pl -- form checks for predictions.tsv.
%%%%
%%%% This file never reads tests/expected.tsv and never runs a case, so
%%%% running it tells you nothing about whether an answer is right. That is
%%%% what makes it safe to run before the prediction commit.
%%%%
%%%% It reads raw lines rather than parsed fields, because the parse hides
%%%% the faults it looks for. A padded cell survives the parse and then
%%%% fails its comparison, which reads like a wrong prediction rather than
%%%% a stray space. One trailing space per line fails all 16 count checks
%%%% that way.

ps4_columns(["id", "first", "second", "count"]).

ps4_ids(Ids) :-
    findall(Id, ( between(1, 16, N), format(string(Id), "P~|~`0t~d~2+", [N]) ), Ids).

%% ps4_read_lines(+Path, -Lines)
%
% Every line of Path as a string, or the atom missing when the file is not
% there. A trailing carriage return is stripped, because a CRLF file grades
% correctly and is not a fault. So are blank lines at the end.
ps4_read_lines(Path, Lines) :-
    (   exists_file(Path)
    ->  read_file_to_string(Path, Text, []),
        split_string(Text, "\n", "\r", Raw),
        ps4_drop_trailing_blanks(Raw, Lines)
    ;   Lines = missing
    ).

ps4_drop_trailing_blanks(Raw, Lines) :-
    reverse(Raw, Reversed),
    ps4_drop_leading_blanks(Reversed, Kept),
    reverse(Kept, Lines).

ps4_drop_leading_blanks([""|Rest], Kept) :-
    !,
    ps4_drop_leading_blanks(Rest, Kept).
ps4_drop_leading_blanks(Kept, Kept).

ps4_split_tab(Line, Fields) :-
    split_string(Line, "\t", "", Fields).

ps4_trim(Cell, Trimmed) :-
    split_string(Cell, "", " \t", [Trimmed]).

ps4_blank(Cell) :-
    ps4_trim(Cell, "").

ps4_padded(Cell) :-
    ps4_trim(Cell, Trimmed),
    Trimmed \== Cell.

ps4_whole_number(Cell) :-
    string_length(Cell, Length),
    Length > 0,
    string_codes(Cell, Codes),
    forall(member(Code, Codes), code_type(Code, digit)).

%% ps4_validate_predictions(+Path, -Problems, -Todos)
%
% Problems holds malformations. Todos holds rows with cells still reading
% TODO. Both are lists of strings, in file order.
ps4_validate_predictions(Path, Problems, Todos) :-
    ps4_read_lines(Path, Lines),
    ps4_columns(Columns),
    ps4_ids(Ids),
    (   Lines == missing
    ->  format(string(P), "~w is missing.", [Path]),
        Problems = [P],
        Todos = []
    ;   Lines == []
    ->  format(string(P), "~w is empty.", [Path]),
        Problems = [P],
        Todos = []
    ;   Lines = [Header|Rows],
        ps4_header_problems(Header, Columns, HeaderProblems),
        length(Lines, LineCount),
        length(Ids, IdCount),
        Wanted is IdCount + 1,
        (   LineCount =:= Wanted
        ->  CountProblems = []
        ;   format(string(CP), "the file holds ~d lines. It needs ~d, one header and one row for each of P01 to P16.",
                   [LineCount, Wanted]),
            CountProblems = [CP]
        ),
        ps4_row_problems(Rows, 2, 1, Columns, Ids, RowProblems, Todos),
        append([HeaderProblems, CountProblems, RowProblems], Problems)
    ).

ps4_header_problems(Header, Columns, Problems) :-
    ps4_split_tab(Header, Fields),
    (   Fields == Columns
    ->  Problems = []
    ;   atomic_list_concat(Columns, '<TAB>', Shown),
        format(string(P), "line 1: the header row must be exactly ~w.", [Shown]),
        Problems = [P]
    ).

ps4_row_problems([], _, _, _, _, [], []).
ps4_row_problems([Line|Rest], LineNumber, RowNumber, Columns, Ids, Problems, Todos) :-
    ps4_one_row(Line, LineNumber, RowNumber, Columns, Ids, RowProblems, RowTodos),
    NextLine is LineNumber + 1,
    NextRow is RowNumber + 1,
    ps4_row_problems(Rest, NextLine, NextRow, Columns, Ids, MoreProblems, MoreTodos),
    append(RowProblems, MoreProblems, Problems),
    append(RowTodos, MoreTodos, Todos).

ps4_one_row(Line, LineNumber, RowNumber, Columns, Ids, Problems, Todos) :-
    ps4_split_tab(Line, Fields),
    length(Fields, Found),
    length(Columns, Expected),
    format(string(Label), "line ~d", [LineNumber]),
    (   Found =\= Expected
    ->  format(string(P), "~s: found ~d fields, expected ~d. Separate the columns with one tab each and use no tab anywhere else. An editor set to insert spaces instead of tabs lands here.",
               [Label, Found, Expected]),
        Problems = [P],
        Todos = []
    ;   ps4_cell_problems(Fields, Columns, Label, CellProblems),
        Fields = [RawId|RawCells],
        ps4_trim(RawId, FoundId),
        (   nth1(RowNumber, Ids, WantedId),
            FoundId \== WantedId
        ->  format(string(IdP), "~s: the id reads \"~s\". Row ~d must be ~s, and all 16 ids stay in order.",
                   [Label, FoundId, RowNumber, WantedId]),
            IdProblems = [IdP]
        ;   IdProblems = []
        ),
        maplist(ps4_trim, RawCells, Cells),
        (   member("TODO", Cells)
        ->  aggregate_all(count, member("TODO", Cells), TodoCount),
            format(string(T), "~s: ~d of 3 cells still read TODO", [FoundId, TodoCount]),
            Todos = [T],
            VocabProblems = []
        ;   Todos = [],
            ps4_vocabulary_problems(Cells, Label, VocabProblems)
        ),
        append([CellProblems, IdProblems, VocabProblems], Problems)
    ).

ps4_cell_problems([], [], _, []).
ps4_cell_problems([Cell|Cells], [Column|Columns], Label, Problems) :-
    format(string(Where), "~s, column ~s", [Label, Column]),
    (   Cell == ""
    ->  format(string(P), "~s: the cell is empty.", [Where]),
        These = [P]
    ;   ps4_blank(Cell)
    ->  format(string(P), "~s: the cell holds only whitespace.", [Where]),
        These = [P]
    ;   ps4_trim(Cell, Trimmed),
        (   ps4_padded(Cell)
        ->  format(string(P1), "~s: the cell has leading or trailing whitespace. The comparison is exact, so \"~s\" is not the same answer as \"~s\".",
                   [Where, Cell, Trimmed]),
            Padded = [P1]
        ;   Padded = []
        ),
        (   sub_string(Trimmed, _, 1, _, " ")
        ->  format(string(P2), "~s: the cell holds a space. No field in this table has one, so \"X = a\" fails where \"X=a\" passes.",
                   [Where]),
            Spaced = [P2]
        ;   Spaced = []
        ),
        append(Padded, Spaced, These)
    ),
    ps4_cell_problems(Cells, Columns, Label, More),
    append(These, More, Problems).

% The count column has a fixed vocabulary. The other two are free text,
% because an answer can be any term, and only the comparison can judge it.
ps4_vocabulary_problems([_First, _Second, Count], Label, Problems) :-
    (   ( ps4_whole_number(Count) ; Count == "unbounded" ; Count == "error" )
    ->  Problems = []
    ;   format(string(P), "~s, column count: \"~s\" is neither a whole number, unbounded, nor error. A search that ends has 0 or more answers, one that never ends reads unbounded, and one that throws reads error.",
               [Label, Count]),
        Problems = [P]
    ).
