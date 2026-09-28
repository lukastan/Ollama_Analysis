# Ollama_Analysis
This is an analysis of Ollama using software-verification tools, done for the Software Verification course at the University of Belgrade, Faculty of Mathematics. Done in 2025/26.

## Author
Luka Stanković, mi241055, mi241055@alas.matf.bg.ac.rs

## Analyzed project
Per Wikipedia: "Ollama is an open-source software platform for running and managing large language models on local GPU infrastructure and through hosted cloud models." It is written in Go and C/C++.

- Repository: https://github.com/ollama/ollama
- Version: v0.34.4
- Commit: b2da9e468af2479058ae18c6d908ed29de410684 (included as the `ollama/` submodule)
- Scope: linux/amd64

## Prerequisites
- Go 1.26.4
- Valgrind 3.22.0
- clang-tidy (LLVM 18.1.3), CMake 3.28.3
- clang-tidy's configure step needs network access (about 543 MB)

    GOBIN=$HOME/.cache/ollama-analysis/bin go install golang.org/x/vuln/cmd/govulncheck@v1.8.0
    GOBIN=$HOME/.cache/ollama-analysis/bin go install github.com/kisielk/errcheck@v1.20.0

## Setup
    git clone --recurse-submodules https://github.com/lukastan/Ollama_Analysis
    cd Ollama_Analysis

## Tools and how to reproduce
Each tool has its own directory with script.bash, results/ and notes.md.

| Tool | Directory | Run |
|---|---|---|
| govulncheck | govulncheck/ | bash govulncheck/script.bash|
| errcheck | errcheck/ | bash errcheck/script.bash |
| Unit tests + coverage | unit_tests/ | bash unit_tests/script.bash |
| Go fuzzing | fuzzing/ | bash fuzzing/script.bash |
| Valgrind callgrind | callgrind/ | bash callgrind/script.bash |
| clang-tidy | clang-tidy/ | bash clang-tidy/script.bash |

custom.patch added custom tests in manifest/extra_test.go to the submodule. Running unit_tests/script.bash applies it, measures coverage, and reverts it.

## Conclusions
The most concrete risk found is the outdated golang.org/x/image WebP decoder, reachable from client-sent images, which could allow a denial-of-service attack; updating the dependency fixes it.

## License
MIT, see LICENSE.
