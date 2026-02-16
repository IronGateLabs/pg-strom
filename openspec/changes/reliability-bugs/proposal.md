## Why

SonarCloud reports 25 bugs in `src/` and 16 bugs in `src/dpu/` after excluding noise directories. The reliability rating is E (worst). The bugs include serious issues: out-of-bounds array access (c:S3519, 8 in src/), use of uninitialized values (c:S836/cpp:S836, 15 combined), null pointer dereferences (c:S2259/cpp:S2259, 5 combined), struct comparison with padding (c:S5000, 2), lock ordering issues (c:S5489/S5486, 2), and identical sub-expressions (cpp:S1764, 1). Many are in critical paths like `codegen.c`, `gpu_service.c`, `arrow_fdw.c`, and `xpu_postgis.cc`.

## What Changes

- Fix 8 out-of-bounds/buffer overflow bugs (rule S3519) in `src/codegen.c`, `src/gpu_service.c`, `src/arrow_fdw.c`, `src/arrow_write.c`, `src/dpu_device.c`, `src/dpu/xpu_postgis.cc`
- Fix 15 uninitialized variable bugs (rule S836) across `src/` and `src/dpu/xpu_postgis.cc`
- Fix 5 null pointer dereference bugs (rule S2259) in `src/` and `src/dpu/`
- Fix 2 struct padding comparison bugs (rule S5000) in `src/arrow_fdw.c`
- Review 2 lock ordering issues (rules S5489/S5486) in `src/pg_utils.h`
- Fix 1 identical sub-expression bug (rule S1764) in `src/dpu/`
- Fix remaining misc bugs (S3584, S2637, S1862, cpp:S6655)

## Non-goals

- Fixing bugs in `deadcode/`, `test/`, `docs/` — excluded directories
- Fixing the 621 HTML tag bugs in `deadcode/doc` (Web:UnsupportedTagsInHtml5Check)
- Refactoring code beyond what's needed to fix the specific bug
- Adding new test coverage for fixed bugs (separate change)

## Capabilities

### New Capabilities
- `reliability-bug-fixes`: Remediation of all SonarCloud reliability bugs in active source code (`src/`, `src/dpu/`, `arrow-tools/`), organized by rule and severity

### Modified Capabilities
<!-- None -->

## Impact

- 41 bug fixes across `src/`, `src/dpu/`, `arrow-tools/`
- Reliability rating improvement from E toward A
- Critical files: `codegen.c`, `gpu_service.c`, `arrow_fdw.c`, `arrow_write.c`, `pg_utils.h`, `dpu_device.c`, `dpu/xpu_postgis.cc`
- Risk: some "bugs" may be false positives due to analyzer limitations with PostgreSQL macros or CUDA patterns — each must be individually assessed
