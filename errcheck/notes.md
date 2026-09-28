# errcheck

## What it is
> "errcheck finds silently ignored errors in Go code."
>
> Source: https://github.com/kisielk/errcheck

**Type:** Static analysis: bug-pattern checker (unchecked errors). Not covered in the course exercises.

## How I ran it
    errcheck -ignoretests ./...    # results/no_tests.txt
    errcheck ./...                 # results/with_tests.txt

Version (results/version.txt): errcheck v1.20.0, built with go1.26.4.

The -ignoretests run shows only production code; the full run shows how many of the findings come from test code.

## Results
199 findings without test files, 1313 with them.

Non-test findings by ignored call: Close 118, fmt.Fprint* 26, os.Remove/RemoveAll 13, io.Copy 10, Write 5, Flush 4, json.Unmarshal 3, other 20.

## Interpretation
| Location | Call | Verdict |
|---|---|---|
| anthropic/anthropic.go:1285 | defer resp.Body.Close() | Harmless: the body has already been read, and nothing useful can be done if closing fails. |
| x/transfer/upload.go:278 | io.Copy(io.Discard, resp.Body) | Harmless by design: it drains the body so the HTTP connection can be reused, and the data is not needed. |

Most findings (118 of 199 are Close) are harmless idioms, which is why upstream disables errcheck in .golangci.yaml: the noise outweighs the few real issues.

## Limits
errcheck detects the pattern reliably but cannot tell a deliberate ignore from an oversight; every finding needs manual triage.
