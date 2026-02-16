## Why

SonarCloud reports 25.3% duplication across the project, with `src/` at 26.8% and `arrow-tools/` at 38.3%. This represents 94,204 duplicated lines across 3,174 blocks in 243 files. High duplication increases maintenance burden — bug fixes and improvements must be applied in multiple places, and divergent copies create subtle inconsistencies. The `arrow-tools/` directory is particularly affected at 38.3%, likely due to similar Arrow file handling patterns across `pg2arrow`, `tsv2arrow`, `vcf2arrow`, and `arrow2csv`.

## What Changes

- Analyze duplication hotspots in `src/` (26.8%) — identify the largest duplicated blocks and their locations
- Analyze duplication in `arrow-tools/` (38.3%) — identify shared Arrow handling patterns
- Extract common code into shared utilities where duplication is across files
- Consolidate duplicated blocks within files using helper functions or macros
- Prioritize the largest duplicated blocks for maximum impact

## Non-goals

- Eliminating all duplication — some duplication is acceptable (target: reduce to <15% in active code)
- Refactoring `deadcode/` or `docs/` duplication (excluded)
- Changing CUDA kernel code patterns where duplication is intentional for performance (e.g., unrolled loops, specialized kernel variants)
- Breaking the build or changing public APIs

## Capabilities

### New Capabilities
- `duplication-reduction`: Identification and consolidation of duplicated code blocks in `src/` and `arrow-tools/`, with shared utility extraction where applicable

### Modified Capabilities
<!-- None -->

## Impact

- Reduction target: `src/` from 26.8% to <20%, `arrow-tools/` from 38.3% to <20%
- Files most likely affected: arrow-tools utilities (shared Arrow patterns), xpu_*.cu files (type/function implementations), gpu_*.c files (scan node implementations)
- Risk: extracting shared code across CUDA device code and host code requires careful handling of `__device__` / `__host__` qualifiers
- Risk: some duplication in `src/dpu/` mirrors `src/` intentionally (DPU reimplements host-side logic) — must preserve this boundary
