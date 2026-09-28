#!/bin/bash
export GOMODCACHE="$(go env GOMODCACHE)" GOCACHE="$(go env GOCACHE)" GOPATH="$(go env GOPATH)"
cd "$(dirname "$0")/../ollama" || exit 1
mkdir -p ../clang-tidy/results
cmake -S llama/server --preset cpu -B /tmp/clang-tidy-build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON > ../clang-tidy/results/cmake.txt 2>../clang-tidy/results/cmake.err
clang-tidy -p /tmp/clang-tidy-build -quiet --checks='-*,bugprone-*,cert-*,clang-analyzer-*,performance-*' llama/compat/llama-ollama-compat.cpp llama/compat/llama-ollama-compat-util.cpp > ../clang-tidy/results/clang-tidy.txt 2>../clang-tidy/results/clang-tidy.err
clang-tidy --version > ../clang-tidy/results/version.txt