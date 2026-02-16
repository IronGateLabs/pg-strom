## Context

41 reliability bugs in active code: 25 in `src/`, 16 in `src/dpu/`. The bugs cluster around a few rules: out-of-bounds access (S3519, 9 total), uninitialized variables (S836, 15 total), null dereference (S2259, 5 total), struct padding comparison (S5000, 2), lock issues (S5489/S5486, 2), out-of-scope access (S6655, 2), and misc (S3584, S2637, S1862, S1764). The reliability rating is E (worst possible).

## Goals / Non-Goals

**Goals:**
- Fix or triage all 41 bugs in active source code
- Achieve reliability rating improvement (E → C or better)
- Verify fixes don't break existing regression tests

**Non-Goals:**
- Adding new test coverage for the fixed code paths
- Fixing bugs in `deadcode/`, `test/`, `docs/`
- Restructuring code beyond the minimal fix needed

## Decisions

### 1. Fix by severity: BLOCKER first, then CRITICAL, then MAJOR
**Rationale:** BLOCKER bugs (out-of-bounds access, lock issues, out-of-scope access) represent actual crash/corruption risk. MAJOR bugs (uninitialized values) may be analyzer limitations with PostgreSQL patterns. Alternative: fix by file (less risk-prioritized).

### 2. Individually assess each S836 (uninitialized variable) bug
**Rationale:** The 15 uninitialized variable bugs in `src/dpu/xpu_postgis.cc` may be false positives — PostGIS geometry handling often uses union types and conditional initialization that analyzers mistrack. Each needs manual verification. Alternative: suppress all (hides real bugs).

### 3. Use `memcmp`→member comparison for S5000 fixes
**Rationale:** Two bugs flag `memcmp` on `FdwRoutine` struct which contains padding. Fix by comparing relevant members individually. Alternative: zero-initialize with `memset` before comparison (masks the real issue).

## Risks / Trade-offs

- **[Risk] S3519 fixes may change behavior in edge cases** → Run full regression suite after each fix
- **[Risk] Lock ordering fix in pg_utils.h may affect concurrent GPU operations** → Review carefully, test under load
- **[Trade-off] Some S836 bugs may be false positives** → Document reasoning when marking as false positive
