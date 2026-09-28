#!/bin/bash
export PATH="$HOME/.cache/ollama-analysis/bin:$PATH"
cd "$(dirname "$0")/../ollama" || exit 1
mkdir -p ../govulncheck/results
govulncheck -show verbose ./... > ../govulncheck/results/govulncheck.txt
govulncheck -show verbose -version > ../govulncheck/results/version.txt