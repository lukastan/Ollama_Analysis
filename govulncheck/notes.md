# govulncheck

## What it is
> "Govulncheck reports known vulnerabilities that affect Go code. It uses static analysis of source code or a binary's symbol table to narrow down reports to only those that could affect the application."
>
> Source: https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck

**Type:** Static analysis: software composition analysis (SCA) with call-graph reachability. Not covered in the course exercises.

## How I ran it
    govulncheck -show verbose ./...

Versions (results/version.txt): Go go1.26.4, govulncheck v1.8.0, vulnerability DB updated 2026-09-24.

## Results
11 reachable, 23 imported but not called, 16 required but not imported.

Reachable means Ollama's code calls the vulnerable function; imported means it imports the vulnerable package but never calls the vulnerable function; required means the module is a dependency but the vulnerable package is not imported at all.

| Source | Reachable findings | Fixed in |
|---|---|---|
| Go standard library (net/url, net/http, crypto/tls, encoding/xml, encoding/asn1) | #2–#7, #9 | go1.26.5 / go1.26.6 |
| golang.org/x/image v0.22.0 (WebP) | #1, #8, #11 | v0.42.0–v0.45.0 |
| golang.org/x/crypto v0.43.0 (ssh) | #10 | v0.52.0 |
| golang.org/x/net v0.46.0 (idna) | #9 | v0.55.0 |

Full list with IDs: results/govulncheck.txt.

## Interpretation
Findings #2–#7 (and part of #9) are in the Go standard library and are fixed in go1.26.5/1.26.6, so they come from the toolchain I used, not from Ollama's code.

The most relevant findings are #1 and #8 in golang.org/x/image: client-sent images reach webp.Decode through llm.llamaServerMediaBytes, so a crafted image could cause excessive memory use or a panic (denial of service).

#10 is reached only when auth.Sign parses Ollama's own local key file, so the risk is low.

## Limits
Results depend on the database date and the Go version, which is why both are recorded in version.txt.
