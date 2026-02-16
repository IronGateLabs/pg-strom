## Why

SonarCloud reports 878 BLOCKER/CRITICAL code smells in `src/` alone (2,436 total in src/). The maintainability rating is A (technical debt is manageable relative to codebase size), but the high-severity smells indicate real maintainability risks. The top offenders are: macro-based type conversions without casts (cpp:S5028, 294), deeply nested control flow (c:S134, 180+), overly complex functions (c:S3776, 95), redundant casts (c:S859, 143), non-standard declaration placement (cpp:S4962, 52), and violations of one-statement-per-line (c:S999, 15). Addressing BLOCKER/CRITICAL items first gives the highest impact per fix.

## What Changes

- Address cpp:S5028 (macro type conversion, 294 occurrences) — evaluate if these are safe patterns and bulk-mark as won't-fix, or add explicit casts where appropriate
- Reduce c:S134 (deep nesting, 180) — extract helper functions for deeply nested blocks in critical files
- Reduce c:S3776 (cognitive complexity, 95) — break up the most complex functions
- Review c:S859/cpp:S859 (redundant casts, 173) — remove unnecessary casts
- Address cpp:S4962 (variable declaration placement, 52) — move declarations to point of first use
- Fix c:S999 (multiple statements per line, 15) — split onto separate lines

## Non-goals

- Fixing MINOR/INFO severity code smells (4,405 items — diminishing returns)
- Fixing code smells in `deadcode/`, `src/flatbuffers/`, `docs/` — excluded
- Refactoring for aesthetics — only fix flagged items
- Changing established PostgreSQL extension coding patterns that trigger false positives
- Achieving zero code smells — focus on BLOCKER/CRITICAL only

## Capabilities

### New Capabilities
- `maintainability-improvements`: Systematic remediation of BLOCKER and CRITICAL code smells in `src/`, prioritized by rule frequency and severity

### Modified Capabilities
<!-- None -->

## Impact

- ~878 BLOCKER/CRITICAL code smell fixes in `src/`
- Most affected files will be the large implementation files: GPU scan/join/preagg, codegen, arrow_fdw, gpu_service
- Risk: cpp:S5028 (294 items) may be PostgreSQL macro patterns that should be bulk-accepted rather than individually fixed
- No functional changes — pure maintainability improvements
