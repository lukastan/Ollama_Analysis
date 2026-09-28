# Go fuzzing

## What it is
> "Fuzzing is a type of automated testing which continuously manipulates inputs to a program to find bugs. Go fuzzing uses coverage guidance to intelligently walk through the code being fuzzed to find and report failures to the user."
>
> Source: https://go.dev/doc/security/fuzz/

**Type:** Dynamic analysis: coverage-guided mutation fuzzing. Go fuzzing not covered in the course exercises (libFuzzer/AFL++ are).

## How I ran it
    go test -run '^$' -fuzz '^FuzzOpen$' -fuzztime 5m ./fs/gguf/
    go test -run '^$' -fuzz '^FuzzGGUFMetadata$' -fuzztime 5m ./server
    go test -run '^$' -fuzz '^FuzzConvertModelFromFiles$' -fuzztime 5m ./server

Go go1.26.4, 6 workers. Crashers would be moved out of the submodule by the script.

The seed corpus sizes include inputs cached in GOCACHE from an earlier 30-second trial run, so the 5-minute runs did not start from the test's seeds alone.

## Results
| Target | Executions | New interesting | Crashes |
|---|---|---|---|
| FuzzOpen (fs/gguf) | 3,248,649 | 186 | 0 |
| FuzzGGUFMetadata (server) | 4,357,101 | 223 | 0 |
| FuzzConvertModelFromFiles (server) | 2,085,978 | 114 | 0 |

## Interpretation
None of the three targets crashed in 5 minutes, which means no failing input was found in about 2–4 million executions per target, not that the parsers are bug-free.

The corpus was still growing steadily at the end (FuzzGGUFMetadata: 144 → 190 → 223 new inputs), so a longer run would likely explore more code.

## Limits
Compared with libFuzzer from the exercises, Go fuzzing is built into go test, and since Go is memory-safe it finds panics and logic errors rather than buffer overflows.
