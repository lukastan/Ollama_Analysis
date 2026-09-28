# Unit tests + coverage

## What it is
**Type:** Dynamic analysis: unit testing with statement coverage. Covered in the course exercises (unit tests + coverage).

## How I ran it
    go test -coverprofile=... ./manifest/                     # per package
    go test -coverpkg=./manifest -coverprofile=... ./...      # cross-package
    git apply ../custom.patch; go test -coverprofile=... ./manifest/; git apply -R ../custom.patch

Go go1.26.4. My test: manifest/extra_test.go (in custom.patch), TestValidateDigest.

Tests go into custom.patch because custom tests were added, and the submodule needs to stay clean.

## Results
| Measurement | manifest coverage | ValidateDigest | BlobsPath | TensorLayers |
|---|---|---|---|---|
| Per package, before (coverage.txt) | 17.7% | 0.0% | 0.0% | 0.0% |
| Per package, with my test (my_coverage.txt) | 19.1% | 100.0% | 0.0% | 0.0% |

Test cases (9): valid with ':', with '-', uppercase hex; invalid with 63 and 65 hex chars, sha512 prefix, '_' separator, non-hex char, empty string.

## Interpretation
Per-package coverage (17.7%) shows how well manifest is tested on its own, while cross-package coverage (67.3%) shows how much of it runs anywhere in the test suite. The gap means manifest is mostly tested indirectly, mainly through the server tests (65.9%).

## Limits
BlobsPath and TensorLayers remain at 0% per package, since my test only covers ValidateDigest.
