# Valgrind callgrind

## What it is
> "Callgrind is a profiling tool that records the call history among functions in a program's run as a call-graph. By default, the collected data consists of the number of instructions executed, their relationship to source lines, the caller/callee relationship between functions, and the numbers of such calls."
>
> Source: https://valgrind.org/docs/manual/cl-manual.html

**Type:** Dynamic analysis: profiling by dynamic binary instrumentation (Valgrind). Covered in the course exercises; the project's single Valgrind tool.

## How I ran it
    go test -c -o /tmp/callgrind-binary ./fs/gguf/
    GODEBUG=asyncpreemptoff=1 valgrind --tool=callgrind --callgrind-out-file=results/callgrind.out \
        /tmp/callgrind-binary -test.run '^$' -test.bench BenchmarkRead -test.benchtime 200x
    callgrind_annotate results/callgrind.out                     # results/callgrind.txt
    callgrind_annotate --inclusive=yes results/callgrind.out     # results/callgrind_inclusive.txt

Valgrind 3.22.0, Go go1.26.4.

## Results
Top exclusive costs are all Go runtime: runtime.unlock2 32.2%, runtime.lock2 17.8%, garbage collector ~18%. Ollama's readTensor: 0.22%.

| | Run 1 | Run 2 (committed) |
|---|---|---|
| Program total (Ir) | 1,281,759,220 | 510,012,813 |
| readTensor, both entries (Ir) | 1,142,400 | 1,142,400 |

## Interpretation
Ollama's own GGUF parsing code is cheap (readTensor is about 0.2% of instructions); most instructions are spent in the Go runtime's locks, garbage collector and scheduler.

Between two runs the program total changed from 1.28 billion to 510 million instructions, but readTensor executed exactly 1,142,400 in both: Ollama's code is deterministic while the runtime is not, so the target's own functions should be measured, not the total.

Inclusive costs above 100% (systemstack at 4681.9%) are an artifact: callgrind counts recursive calls and Go's iterator coroutines more than once.

## Limits
Memcheck was not used because Go manages memory with its own allocator and garbage collector instead of malloc, which leads to false positives.
