# clang-tidy

## What it is
> "clang-tidy is a clang-based C++ “linter” tool. Its purpose is to provide an extensible framework for diagnosing and fixing typical programming errors, like style violations, interface misuse, or bugs that can be deduced via static analysis."
>
> Source: https://clang.llvm.org/extra/clang-tidy/

**Type:** Static analysis: AST-based linter plus path-sensitive checks (clang-analyzer). Not covered in the course exercises; the project's single style tool.

## How I ran it
    cmake -S llama/server --preset cpu -B /tmp/clang-tidy-build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    clang-tidy -p /tmp/clang-tidy-build -quiet \
        --checks='-*,bugprone-*,cert-*,clang-analyzer-*,performance-*' \
        llama/compat/llama-ollama-compat.cpp llama/compat/llama-ollama-compat-util.cpp

clang-tidy LLVM 18.1.3, CMake 3.28.3. The configure step fetches llama.cpp (~543 MB).

clang-tidy needs the exact compiler flags for each file, which CMake writes to compile_commands.json during configuration, so no build is needed; -B puts the build directory in /tmp because the cpu preset would otherwise create it inside the submodule.

I disabled all checks and enabled only bug-finding groups (bugprone, cert, clang-analyzer, performance), leaving out pure style checks to keep the output reviewable.

## Results
60 warnings: cert-err33-c 44 (snprintf 39, fprintf 3, fclose 2), bugprone-easily-swappable-parameters 15, bugprone-narrowing-conversions 1, clang-analyzer 0. The other ~126,000 generated warnings are in llama.cpp headers and suppressed by default.

## Interpretation
llama-ollama-compat.cpp:3177 (cert-err33-c): snprintf into a 64-byte buffer with the return value ignored. Harmless here: if the name did not fit in 64 bytes, snprintf would silently truncate it, but these names are always much shorter.

## Limits
Only Ollama's two compat files were analyzed; warnings in llama.cpp itself were suppressed and are out of scope.
