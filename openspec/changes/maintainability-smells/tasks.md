## 1. Evaluate and Configure Rules

- [ ] 1.1 Sample 20 cpp:S5028 hits — determine if they are PostgreSQL macro patterns
- [ ] 1.2 If >80% are PG macros, disable cpp:S5028 in SonarCloud quality profile via API
- [ ] 1.3 Sample 10 c:S859 hits — confirm they are truly redundant casts safe to remove

## 2. Quick Wins

- [ ] 2.1 Fix c:S999 multi-statement lines (15 occurrences) — split onto separate lines
- [ ] 2.2 Fix cpp:S4962 declaration placement (52 occurrences) — move declarations to first use
- [ ] 2.3 Remove confirmed redundant casts c:S859 (143 occurrences) in `src/`
- [ ] 2.4 Remove confirmed redundant casts cpp:S859 (30 occurrences) in `src/`

## 3. Complexity Reduction — Batch 1 (highest complexity functions)

- [ ] 3.1 Identify the 10 functions with highest cognitive complexity (c:S3776) via SonarCloud API
- [ ] 3.2 Refactor top 5 most complex functions — extract helper functions to reduce complexity to <=30
- [ ] 3.3 Refactor next 5 most complex functions
- [ ] 3.4 Run regression tests after complexity refactoring

## 4. Deep Nesting Reduction — Batch 1

- [ ] 4.1 Identify files with most c:S134 hits via SonarCloud API
- [ ] 4.2 Refactor top 20 deepest-nested blocks — use early returns, extracted helpers, or guard clauses
- [ ] 4.3 Run regression tests after nesting reduction

## 5. Complexity and Nesting — Remaining

- [ ] 5.1 Continue c:S3776 fixes for functions with complexity 20-30 (remaining ~85 after batch 1)
- [ ] 5.2 Continue c:S134 fixes for remaining deep nesting (~160 after batch 1)

## 6. Verification

- [ ] 6.1 Run SonarCloud analysis and verify BLOCKER/CRITICAL smell count reduction
- [ ] 6.2 Target: reduce from 878 to <200 BLOCKER/CRITICAL smells in `src/`
- [ ] 6.3 Run `cd test && make installcheck` to verify no regressions
