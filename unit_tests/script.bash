#!/bin/bash
export GOMODCACHE="$(go env GOMODCACHE)" GOCACHE="$(go env GOCACHE)" GOPATH="$(go env GOPATH)"
cd "$(dirname "$0")/../ollama" || exit 1
mkdir -p ../unit_tests/results
HOME=$(mktemp -d)
go test -coverprofile=../unit_tests/results/coverage.out ./manifest/
go tool cover -func=../unit_tests/results/coverage.out > ../unit_tests/results/coverage.txt
go tool cover -html=../unit_tests/results/coverage.out -o ../unit_tests/results/coverage.html

go test -coverpkg=./manifest -coverprofile=../unit_tests/results/manifest.coverage.out ./...
go tool cover -func=../unit_tests/results/manifest.coverage.out > ../unit_tests/results/manifest_coverage.txt
go tool cover -html=../unit_tests/results/manifest.coverage.out -o ../unit_tests/results/manifest_coverage.html

git apply ../custom.patch
go test -coverprofile=../unit_tests/results/my_coverage.out ./manifest/
go tool cover -func=../unit_tests/results/my_coverage.out > ../unit_tests/results/my_coverage.txt
go tool cover -html=../unit_tests/results/my_coverage.out -o ../unit_tests/results/my_coverage.html
git apply -R ../custom.patch