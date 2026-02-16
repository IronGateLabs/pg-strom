## Context

878 BLOCKER/CRITICAL code smells in `src/`. The top rules by count: cpp:S5028 (macro type conversion, 294), c:S134 (deep nesting, 180), c:S859 (redundant casts, 143), c:S3776 (cognitive complexity, 95), cpp:S4962 (declaration placement, 52), cpp:S859 (redundant casts, 30), c:S999 (multi-statement lines, 15), cpp:S134 (deep nesting, 10), cpp:S5008 (use of `auto`, 8), c:S959 (declarations not at block start, 8). The maintainability rating is already A, but BLOCKER/CRITICAL items indicate real readability and maintenance risks.

## Goals / Non-Goals

**Goals:**
- Address the top 6 rules covering ~800 of the 878 BLOCKER/CRITICAL smells
- Determine which rules represent real issues vs. PostgreSQL/CUDA coding conventions
- For convention-related rules, configure SonarCloud quality profile to suppress
- For genuine smells, fix the code

**Non-Goals:**
- Fixing MAJOR/MINOR/INFO smells (~1,558 remaining in src/)
- Modifying PostgreSQL-mandated patterns (e.g., macro usage from PG headers)
- Refactoring CUDA kernels for readability at the cost of performance

## Decisions

### 1. Evaluate cpp:S5028 (294 items) as potential bulk suppression
**Rationale:** This rule flags macro-based type conversions. In PostgreSQL extensions, macros like `DatumGetInt32`, `PG_GETARG_*`, `MemSet` are ubiquitous and intentional. If most S5028 hits are PG macros, configure the quality profile to disable this rule rather than adding 294 casts. Alternative: add explicit casts everywhere (clutters code, doesn't improve safety).

### 2. Fix c:S134 (deep nesting) and c:S3776 (complexity) together
**Rationale:** Deep nesting and high complexity are often the same functions. Extracting helpers addresses both rules. Focus on functions with complexity >30 first. Alternative: just add `// NOSONAR` comments (hides real complexity).

### 3. Batch c:S859 (redundant casts) as mechanical fixes
**Rationale:** Removing redundant casts is safe and mechanical — good candidate for bulk automated fix. Alternative: leave them (they add visual noise but no runtime impact).

### 4. Fix c:S999 and cpp:S4962 as quick wins
**Rationale:** Multi-statement lines (15) and declaration placement (52) are small, safe fixes that improve readability. Do these first for quick wins.

## Risks / Trade-offs

- **[Risk] Disabling cpp:S5028 may hide legitimate type conversion bugs** → Review a sample of 20 hits first to confirm they're all PG macros
- **[Risk] Extracting functions from complex code may change behavior** → Run regression tests after each extraction
- **[Trade-off] Some deep nesting is inherent to SQL expression processing** → Accept ≤5 levels, flag ≥6 levels
