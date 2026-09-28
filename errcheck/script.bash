#!/bin/bash
export PATH="$HOME/.cache/ollama-analysis/bin:$PATH"
cd "$(dirname "$0")/../ollama" || exit 1
mkdir -p ../errcheck/results
errcheck -ignoretests ./... > ../errcheck/results/no_tests.txt
errcheck  ./... > ../errcheck/results/with_tests.txt
go version -m "$(command -v errcheck)" > ../errcheck/results/version.txt