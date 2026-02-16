## Context

Duplication density after exclusions will focus on `src/` (26.8%) and `arrow-tools/` (38.3%). The 3,174 duplicated blocks across 243 files include: Arrow tool utilities sharing file reading/writing patterns, xpu_*.cu files with repetitive type-specific implementations, and gpu_*.c files with similar scan node lifecycle code. The `src/dpu/` directory intentionally mirrors parts of `src/` for DPU execution.

## Goals / Non-Goals

**Goals:**
- Identify the largest duplicated blocks in `src/` and `arrow-tools/`
- Extract shared utilities in `arrow-tools/` (highest duplication at 38.3%)
- Consolidate duplicated patterns in `src/` where safe
- Reduce overall duplication to <20% in active code

**Non-Goals:**
- Eliminating duplication between `src/` and `src/dpu/` (intentional architectural boundary)
- De-duplicating CUDA kernel specializations (performance-critical)
- Achieving <10% duplication (unrealistic for this codebase type)
- Modifying generated code (flatbuffers — already excluded)

## Decisions

### 1. Start with `arrow-tools/` (highest ROI)
**Rationale:** 38.3% duplication with only 4 main tools means significant shared patterns. Common Arrow file reading, schema handling, and metadata extraction can be factored into shared headers/libraries. Alternative: start with `src/` (larger codebase but lower percentage, more risk).

### 2. Use SonarCloud duplicated blocks API to identify specific blocks
**Rationale:** Rather than manually searching, use the API to get exact file locations and line ranges of the largest duplicated blocks. Alternative: manual code review (slower, less systematic).

### 3. Create shared arrow-tools library for common patterns
**Rationale:** `arrow-tools/` already builds multiple binaries from the same directory. Adding shared source files (e.g., `arrow_common.cpp`) is natural. Alternative: header-only utilities (limits what can be shared).

### 4. Use macros/templates for type-specific xpu code duplication
**Rationale:** xpu_*.cu files have type-specific implementations that follow identical patterns. C preprocessor macros or C++ templates can capture the pattern while preserving type specialization. Alternative: manual de-duplication (error-prone for 20+ types).

## Risks / Trade-offs

- **[Risk] Extracting shared code may break build dependencies** → Verify Makefile handles new source files
- **[Risk] Template/macro de-duplication may reduce debuggability** → Keep macro bodies small, use descriptive names
- **[Trade-off] src/dpu/ duplication remains** → Intentional; DPU must be self-contained
- **[Trade-off] Some CUDA duplication is performance-intentional** → Document which duplications are kept and why
