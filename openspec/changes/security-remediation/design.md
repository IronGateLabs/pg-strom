## Context

After `sonarcloud-config` applies exclusions, ~173 security hotspots remain in active code (111 in `src/`, 62 in `arrow-tools/`). Categories: buffer overflow (~100+), others (~50+), weak cryptography (few), permissions (few). The 3 CodeQL TOCTOU vulnerabilities are all in `deadcode/` and resolved by exclusions. This change focuses on triaging hotspots — many will be safe patterns that need documentation, while genuine risks need code fixes.

## Goals / Non-Goals

**Goals:**
- Systematically triage all security hotspots in `src/` and `arrow-tools/`
- Fix genuine buffer overflow risks with bounded operations
- Document safe patterns so future reviews are faster
- Improve security rating from D toward B

**Non-Goals:**
- Automated hotspot resolution — each requires human judgment
- Modifying PostgreSQL-internal buffer handling patterns (palloc/pfree are GC'd)
- Adding new security infrastructure (auth, encryption, audit logging)

## Decisions

### 1. Triage-first approach over bulk fixing
**Rationale:** Many hotspots in C PostgreSQL extensions are false positives — `palloc` memory is context-managed, `snprintf` is already bounded, PostgreSQL macros handle buffer safety. Triage first to avoid unnecessary changes. Alternative: fix everything mechanically (high risk of breaking working code).

### 2. Group by file, not by category
**Rationale:** Changes to a single file should be reviewed together for coherence. A file-by-file approach also maps well to PR review. Alternative: category-by-category (spreads changes across many files per PR).

### 3. Use SonarCloud API to mark reviewed hotspots
**Rationale:** After triage, safe patterns should be marked "Safe" via the SonarCloud API/UI so they don't reappear. This is a permanent resolution. Alternative: suppress via comments (clutters code).

## Risks / Trade-offs

- **[Risk] False positive rate may be high** → Triage-first approach handles this; expect 50-70% safe patterns
- **[Risk] Fixes to buffer handling could break edge cases** → Test with existing regression suite after each batch
- **[Trade-off] Marking hotspots Safe in SonarCloud is org-specific** → Acceptable since this is our fork; upstream changes would need separate review
