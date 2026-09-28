#!/bin/bash
export GOMODCACHE="$(go env GOMODCACHE)" GOCACHE="$(go env GOCACHE)" GOPATH="$(go env GOPATH)"
cd "$(dirname "$0")/../ollama" || exit 1
mkdir -p ../fuzzing/results
HOME=$(mktemp -d)
go test -run '^$' -fuzz '^FuzzOpen$' -fuzztime 5m ./fs/gguf/ > ../fuzzing/results/fuzz_open.txt 2>../fuzzing/results/fuzz_open.err
go test -run '^$' -fuzz '^FuzzGGUFMetadata$' -fuzztime 5m ./server > ../fuzzing/results/fuzz_metadata.txt 2>../fuzzing/results/fuzz_metadata.err
go test -run '^$' -fuzz '^FuzzConvertModelFromFiles$' -fuzztime 5m ./server > ../fuzzing/results/fuzz_convert.txt 2>../fuzzing/results/fuzz_convert.err

if [ -d fs/gguf/testdata/fuzz/FuzzOpen ]; then mv fs/gguf/testdata/fuzz/FuzzOpen ../fuzzing/results; fi
if [ -d server/testdata/fuzz/FuzzGGUFMetadata ]; then mv server/testdata/fuzz/FuzzGGUFMetadata ../fuzzing/results; fi
if [ -d server/testdata/fuzz/FuzzConvertModelFromFiles ]; then mv server/testdata/fuzz/FuzzConvertModelFromFiles ../fuzzing/results/; fi