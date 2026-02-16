## 1. Analysis and Inventory

- [x] 1.1 Export top duplicated blocks in `src/` — 12 files, 165 blocks total
- [x] 1.2 Export top duplicated blocks in `arrow-tools/` — **0 blocks** (no duplication)
- [x] 1.3 Categorize duplications:
  - **Cross-file with deadcode/**: 80 of 84 duplication groups (>95%) are between active code and `deadcode/v3.x/` files. These are natural — active code evolved from v3.x.
  - **Within-file (active-only)**: Only 4 small groups remain after excluding deadcode/:
    - `src/misc.c`: 12-line and 45-line repeated patterns (type dispatch)
    - `src/arrow_fdw.c`: 32-line repeated block (similar field handling)
    - `src/aggfuncs.c`: 30-line repeated block (aggregate function patterns)
  - **Intentional (src/ ↔ src/dpu/)**: `src/dpu/*.cc` are symlinks to `src/xpu_*.cu` — duplication is by design
  - **SQL DDL files**: `pg_strom--5.0.sql` (95.6%) and `pg_strom--4.0--5.0.sql` (92.3%) — intentional repetitive DDL

### Key Finding
**>95% of all code duplication is caused by the `deadcode/` directory** being included in analysis. Once the sonarcloud-config change takes effect (excluding deadcode/, docs/, test/), the project's duplication density will drop from 25.3% to near zero in active code.

## 2. Arrow-tools Deduplication

- [x] 2.1-2.9 — **NOT NEEDED**: arrow-tools/ has 0 duplicated blocks. No shared utility extraction required.

## 3. src/ Deduplication — Batch 1

- [x] 3.1-3.5 — **NOT NEEDED**: After deadcode/ exclusion, only 4 trivial within-file duplications remain:
  - `src/misc.c:1907-2023` — 12/45-line blocks: repetitive type-dispatch patterns for numeric formatting
  - `src/arrow_fdw.c:2795-2916` — 32-line block: similar Arrow field stat accumulation logic
  - `src/aggfuncs.c:625-736` — 30-line block: similar aggregate state transition functions
  - All are small, within-file, and represent intentional structural similarity (same pattern applied to different types). Refactoring would over-abstract.

## 4. src/ Deduplication — Batch 2

- [x] 4.1-4.2 — **NOT NEEDED**: No large duplicated blocks remain after deadcode/ exclusion

## 5. Verification

- [ ] 5.1-5.2 — N/A (no code changes)
- [ ] 5.3 — N/A (no code changes)
- [ ] 5.4 — BLOCKED: Verify after sonarcloud-config exclusions are applied. Expected: src/ duplication <5%, arrow-tools/ 0%

### Summary
- **No code changes needed** for code-duplication reduction
- **Root cause**: deadcode/ directory included in SonarCloud analysis accounts for >95% of reported duplication
- **Solution**: sonarcloud-config exclusions (PR #2) will resolve the duplication metric when merged to develop
- **Remaining active-only duplication**: 4 groups, all small (<45 lines) and within-file — these are intentional structural patterns, not candidates for extraction
