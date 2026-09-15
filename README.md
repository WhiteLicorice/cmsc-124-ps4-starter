<!--no-pdf-->
# CMSC 124 Problem Set 4 Starter

This repository holds the Prolog prediction corpus and the rule stubs for
Problem Set 4. The assignment manual defines the work and the submission rules.

## Layout

```text
cases/kb.pl             the facts and given rules every query runs against
cases/cases.pl          the 16 queries, as you would type them at the prompt
predictions.tsv         your first, second, and count predictions
src/rules.pl            the seven predicates you implement
tests/expected.tsv      every published expected result
tests/check_all.pl      the complete public automated checker
scripts/                given runner, tracer, notation, and form-check code
run  trace  lint  check.sh   the course run contract
```

## First Run

Fill `predictions.tsv`, check its form with `./lint`, and commit it before you
run a case. Then run one case, trace one case, or run all automated checks:

```bash
./lint
./run P01
./trace P07
./check.sh
```

`./lint` reads the table's form only. It never opens `tests/expected.tsv` and
never runs a case, so it reveals no answers and is safe to run before the
prediction commit. It catches a padded cell, a space inside an answer, a tab an
editor replaced with spaces, and a missing or reordered row, all of which
survive the parse and then fail their comparisons, so without it they read like
wrong predictions. One trailing space per line fails all 16 `count` checks
that way. `./check.sh` lists the same faults before it scores.

A fresh starter reports `1/66 checks passed` and exits 1. A complete submission
reports `66/66 checks passed` and exits 0. `check.sh` is the complete public
automated check. The expected table and the checker are both in this
repository. The assignment rubric separately assesses the written analysis,
commit history, and workflow runs.

## Reading a First Run

Read `1/66` as the starting state. The single pass is `rules_load`, which asks
only whether `src/rules.pl` consults without a syntax error. The stubs satisfy
that on the first commit. A stub that throws when called is still valid
Prolog. Every prediction, every rule check, and the analysis check fail.
Nothing has been done.

That check earns its place anyway. A consult reads one clause at a time, so a
file that stops mid-clause leaves every clause above the fault defined and
working. Without a check on the load itself, a file cut off in the middle
scores every check its surviving clauses can pass and never says why the rest
went missing.

The Actions badge on this repository is red for the same reason the score is
low. It stays red until a pair completes the assignment, which is the correct
state for a starter. Yours goes green when you finish.

## The Three Check Groups

`src/rules.pl` is scored in three groups that stand on their own.

| Group | What works | Predicates |
|---|---|---|
| R1 | the family rules, including the goal order that `\=` needs | `sibling/2`, `cousin/2`, `descendant/2` |
| R2 | recursion over lists | `count_of/3`, `rev/2`, `last_of/2` |
| R3 | a walk over the graph that ends, with a visited list | `route/3` |

A group you never reach costs you that group only. Deleting `route/3` leaves
R1 and R2 at full marks and zeroes R3. Every R3 check runs under a budget of
inferences, so a `route/3` that goes round the cycle forever fails with a
message instead of hanging the run.

## What `./trace` Prints

`./trace P07` prints every port of the search for `grandparent(tom, X)`:

```text
== trace P07 ==
Call: grandparent(tom,X)
  Call: parent(tom,_)
  Exit: parent(tom,liz)
  Call: parent(liz,X)
  Fail: parent(liz,X)
  Redo: parent(tom,liz)
  Exit: parent(tom,bob)
  ...
```

`Call` is a goal being tried for the first time. `Exit` is the goal succeeding
with the bindings shown. `Redo` is the search coming back to try the goal's
next clause after something later failed. `Fail` is the goal running out of
clauses. Indentation is depth. These are the same four words `swipl`'s own
debugger prints. Part 3 asks you to paste one trace into `ANALYSIS.md`, and
the grader does not count its lines toward the word range.

A search that has not ended after 400 lines stops with a message. Two of the
16 cases do that, on purpose.

## When the Grader Stops Early

`predictions.tsv` has to keep its four columns and all 16 ids in order. When it
doesn't, the grader stops before the first check and prints why. A run that
ends without a `== result ==` line never scored anything, so read the message
and repair the table's columns and ids before you look at your answers.

Fields are compared exactly. `X=liz` passes and `X = liz` doesn't, so write
answers the way the notation section of the manual says, with no spaces.

## Exit Codes

The course contract.

| Code | Command | Meaning |
|---|---|---|
| 0 | `./check.sh` | all 66 checks passed |
| 1 | `./check.sh` | at least one check failed, or the grader stopped early |
| 0 | `./lint` | `predictions.tsv` is well formed and complete |
| 1 | `./lint` | the table is malformed or still holds a TODO |
| 0 | `./run <case>` | the case was found and printed |
| 64 | `./run <case>` | called with the wrong number of arguments |
| 65 | `./run <case>` | the case id is unknown |
| 0 | `./trace <case>` | the case was found and traced |
| 64 | `./trace <case>` | called with the wrong number of arguments |
| 65 | `./trace <case>` | the case id is unknown |

## Tested Toolchains

Every row below is a run that happened.

| Environment | Version reported by `swipl --version` | Result |
|---|---|---|
| Windows 11 24H2, Git Bash, `winget install --id SWI-Prolog.SWI-Prolog` | `SWI-Prolog version 10.0.2 for x64-win64` | `1/66` on the starter, `66/66` with the instructor solution |
| WSL Ubuntu 24.04, `apt-get install swi-prolog` | `SWI-Prolog version 9.0.4 for x86_64-linux` | `1/66` on the starter, `66/66` with the instructor solution |
| GitHub Actions, `ubuntu-latest`, `apt-get install swi-prolog-nox` | `SWI-Prolog version 9.0.4 for x86_64-linux` | `1/66` on the starter |
| GitHub Actions, `macos-latest`, `brew install swi-prolog` | `SWI-Prolog version 10.0.2 for arm64-darwin` | `1/66` on the starter |
| GitHub Actions, `windows-latest`, the official `swipl-10.0.2-1.x64.exe` installer with `/S` | `SWI-Prolog version 10.0.2 for x64-win64` | `1/66` on the starter |

Two SWI-Prolog series grade this assignment, 9.0 and 10.0, and they agree.
The grader re-derives all 48 published expectations before it scores anything,
so a build that printed one answer differently would stop the run and say so.
No runner has. `./run P01` and `./trace P07` also print the same lines on all
three.
