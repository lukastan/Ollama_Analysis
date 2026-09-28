#!/bin/bash
export GOMODCACHE="$(go env GOMODCACHE)" GOCACHE="$(go env GOCACHE)" GOPATH="$(go env GOPATH)"
cd "$(dirname "$0")/../ollama" || exit 1
mkdir -p ../callgrind/results
HOME=$(mktemp -d)
go test -c -o /tmp/callgrind-binary ./fs/gguf/
GODEBUG=asyncpreemptoff=1 valgrind --tool=callgrind --callgrind-out-file=../callgrind/results/callgrind.out /tmp/callgrind-binary -test.run '^$' -test.bench BenchmarkRead -test.benchtime 200x
callgrind_annotate ../callgrind/results/callgrind.out > ../callgrind/results/callgrind.txt
callgrind_annotate --inclusive=yes ../callgrind/results/callgrind.out > ../callgrind/results/callgrind_inclusive.txt