## 1. Inventory and Setup

- [ ] 1.1 Export full list of security hotspots in `src/` via SonarCloud API with file, line, category, and rule details
- [ ] 1.2 Export full list of security hotspots in `arrow-tools/` via SonarCloud API
- [ ] 1.3 Categorize hotspots into: genuine risk, false positive (PG managed), false positive (Arrow managed)

## 2. Buffer Overflow Hotspots — src/

- [ ] 2.1 Triage buffer overflow hotspots in `src/arrow_fdw.c` (11 hotspots) — fix or mark Safe
- [ ] 2.2 Triage buffer overflow hotspots in `src/gpu_service.c` (4 hotspots) — fix or mark Safe
- [ ] 2.3 Triage remaining buffer overflow hotspots in other `src/` files
- [ ] 2.4 Run regression tests after all `src/` buffer overflow fixes

## 3. Buffer Overflow Hotspots — arrow-tools/

- [ ] 3.1 Triage buffer overflow hotspots in `arrow-tools/arrow_meta.cpp` (7 hotspots)
- [ ] 3.2 Triage buffer overflow hotspots in `arrow-tools/pg2arrow.cpp` (5 hotspots)
- [ ] 3.3 Triage remaining hotspots in other `arrow-tools/` files

## 4. Other Security Categories

- [ ] 4.1 Review and resolve all weak cryptography hotspots (14 total, identify which are in active code)
- [ ] 4.2 Review and resolve all permission hotspots (10 total, identify which are in active code)
- [ ] 4.3 Review and resolve "others" category hotspots in `src/` and `arrow-tools/`

## 5. Verification

- [ ] 5.1 Run SonarCloud analysis and verify hotspot count reduction
- [ ] 5.2 Verify security rating improvement (target: D → B or better)
- [ ] 5.3 Confirm CodeQL alerts are resolved (3 TOCTOU in deadcode — should be gone after exclusions)
