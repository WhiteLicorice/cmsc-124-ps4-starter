# CMSC 124 Problem Set 4

Our submission for Problem Set 4: Prolog predictions, rules, and an analysis of
the search.

## Partners

| Name | GitHub username |
|---|---|
| Yuan Birondo | [@YuMBir](https://github.com/YuMBir) |
| Jemarco Briz | [@JemarcoBriz](https://github.com/JemarcoBriz) |

## Contents

```text
predictions.tsv         our first, second, and count predictions for P01-P16
REASONING.md            why we expected each result, written before running
src/rules.pl            our R1, R2, and R3 predicates
ANALYSIS.md             Part 3: the search and the stack, with a pasted trace
cases/                  the given knowledge base and the 16 queries
tests/                  the expected results and the public checker
scripts/                the given runner, tracer, and form checks
run  trace  lint  check.sh   the course run contract
```

## Running

Needs SWI-Prolog 9.0 or 10.0.

```bash
./lint          # checks the form of predictions.tsv
./run P01       # runs one case
./trace P07     # prints the Call, Exit, Redo, and Fail ports for one case
./check.sh      # runs every automated check; exits 0 when all pass
```
