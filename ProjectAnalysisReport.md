# Project Analysis Report: Ollama

Author: Luka Stanković, mi241055

## 1. Analyzed project
- Project: Ollama, https://github.com/ollama/ollama
- Version: v0.34.4, commit b2da9e468af2479058ae18c6d908ed29de410684 (the `ollama/` submodule)
- Languages: Go, with a C/C++ native layer (llama.cpp and Ollama's `llama/compat`)
- Analyzed configuration: linux/amd64, Go go1.26.4

## 2. Tools
| # | Tool | Type | Target |
|---|---|---|---|
| 1 | govulncheck | Static (software composition analysis) | whole Go module |
| 2 | errcheck | Static (bug pattern) | whole Go module |
| 3 | Unit tests + coverage | Dynamic | `manifest` package |
| 4 | Go fuzzing | Dynamic | GGUF parsing, model conversion |
| 5 | Valgrind callgrind | Dynamic (profiling) | `fs/gguf` benchmark |
| 6 | clang-tidy | Static (linter) | `llama/compat` C++ |

Each tool has its own directory with `script.bash`, `results/` and `notes.md`. The notes contain the full commands and versions.

## 3. govulncheck
Results: 11 reachable, 23 imported but not called, 16 required but not imported.

Findings #2–#7 (and part of #9) are in the Go standard library and are fixed in go1.26.5/1.26.6, so they come from the toolchain I used, not from Ollama's code.

The most relevant findings are #1 and #8 in golang.org/x/image: client-sent images reach webp.Decode through llm.llamaServerMediaBytes, so a crafted image could cause excessive memory use or a panic (denial of service).

#10 is reached only when auth.Sign parses Ollama's own local key file, so the risk is low.

## 4. errcheck
Results: 199 findings in production code, 1313 including tests.

Most findings (118 of 199 are Close) are harmless idioms, which is why upstream disables errcheck in .golangci.yaml: the noise outweighs the few real issues.

errcheck detects the pattern reliably but cannot tell a deliberate ignore from an oversight; every finding needs manual triage.

## 5. Unit tests + coverage
TestValidateDigest (9 cases) added to `manifest` via `custom.patch`.

| Measurement | manifest coverage |
|---|---|
| Per package, before | 17.7% |
| Per package, with my test | 19.1% |
| Cross-package, all Ollama tests | 67.3% |

Per-package coverage (17.7%) shows how well manifest is tested on its own, while cross-package coverage (67.3%) shows how much of it runs anywhere in the test suite. The gap means manifest is mostly tested indirectly, mainly through the server tests (65.9%).

## 6. Go fuzzing
5 minutes per target: FuzzOpen 3.2M executions, FuzzGGUFMetadata 4.4M, FuzzConvertModelFromFiles 2.1M.

None of the three targets crashed in 5 minutes, which means no failing input was found in about 2–4 million executions per target, not that the parsers are bug-free.

The corpus was still growing steadily at the end (FuzzGGUFMetadata: 144 → 190 → 223 new inputs), so a longer run would likely explore more code.

## 7. Valgrind callgrind
BenchmarkRead of the GGUF parser, 200 iterations.

Ollama's own GGUF parsing code is cheap (readTensor is about 0.2% of instructions); most instructions are spent in the Go runtime's locks, garbage collector and scheduler.

Between two runs the program total changed from 1.28 billion to 510 million instructions, but readTensor executed exactly 1,142,400 in both: Ollama's code is deterministic while the runtime is not, so the target's own functions should be measured, not the total.

## 8. clang-tidy
Results: 60 warnings: cert-err33-c 44, bugprone-easily-swappable-parameters 15, bugprone-narrowing-conversions 1, clang-analyzer 0.

llama-ollama-compat.cpp:3177 (cert-err33-c): snprintf into a 64-byte buffer with the return value ignored. Harmless here: if the name did not fit in 64 bytes, snprintf would silently truncate it, but these names are always much shorter.

## 9. Limitations
The analysis covers only linux/amd64 with cgo; 132 Go files that never compile on Linux (app/, integration/ and platform variants) were not analyzed.

## 10. Conclusions
The most concrete risk found is the outdated golang.org/x/image WebP decoder, reachable from client-sent images, which could allow a denial-of-service attack; updating the dependency fixes it.
