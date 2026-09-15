%%%% cases.pl -- the sixteen queries of the prediction table.
%%%%
%%%% Each query is stored as the text you would type at the ?- prompt, so
%%%% the variable names you see here are the names the grader prints.
%%%% Every case stands on its own. None depends on another having run first,
%%%% so ./run and ./trace work on any id in any order.

ps4_case("P01", "parent(tom, X)").
ps4_case("P02", "parent(tom, bob)").
ps4_case("P03", "parent(X, tom)").
ps4_case("P04", "X = f(Y, a), Y = b").
ps4_case("P05", "f(X, b) = f(a, Y)").
ps4_case("P06", "a = b").
ps4_case("P07", "grandparent(tom, X)").
ps4_case("P08", "ancestor(tom, X)").
ps4_case("P09", "ancestor_r(tom, X)").
ps4_case("P10", "ancestor(X, jim)").
ps4_case("P11", "reach(a, d)").
ps4_case("P12", "reach_r(a, d)").
ps4_case("P13", "len([a, b, c], N)").
ps4_case("P14", "join(X, Y, [1, 2])").
ps4_case("P15", "X > 2, elem(X, [1, 2, 3])").
ps4_case("P16", "elem(X, [1, 2, 3]), X > 2").
