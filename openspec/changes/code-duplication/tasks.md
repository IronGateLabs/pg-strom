## 1. Analysis and Inventory

- [ ] 1.1 Use SonarCloud API to export the top 20 largest duplicated blocks in `src/` with file locations and line ranges
- [ ] 1.2 Use SonarCloud API to export the top 20 largest duplicated blocks in `arrow-tools/`
- [ ] 1.3 Categorize duplications: cross-file (extractable), within-file (consolidatable), intentional (src/ ↔ src/dpu/)

## 2. Arrow-tools Deduplication

- [ ] 2.1 Identify common Arrow file I/O patterns shared across pg2arrow, tsv2arrow, vcf2arrow, arrow2csv
- [ ] 2.2 Create `arrow-tools/arrow_common.cpp` with shared utility functions
- [ ] 2.3 Create `arrow-tools/arrow_common.h` with shared declarations
- [ ] 2.4 Refactor `pg2arrow.cpp` to use shared utilities
- [ ] 2.5 Refactor `tsv2arrow.cpp` to use shared utilities
- [ ] 2.6 Refactor `vcf2arrow.cpp` to use shared utilities
- [ ] 2.7 Refactor `arrow2csv.cpp` to use shared utilities
- [ ] 2.8 Update `arrow-tools/Makefile` to build shared source
- [ ] 2.9 Verify all arrow-tools build and function correctly

## 3. src/ Deduplication — Batch 1

- [ ] 3.1 Identify duplicated type-dispatch patterns across xpu_*.cu files
- [ ] 3.2 Create macros or templates for common type-dispatch patterns
- [ ] 3.3 Apply to top 5 most-duplicated xpu files
- [ ] 3.4 Identify duplicated scan node patterns across gpu_scan.c, gpu_join.c, gpu_preagg.c
- [ ] 3.5 Extract common scan node lifecycle helpers into shared functions

## 4. src/ Deduplication — Batch 2

- [ ] 4.1 Address remaining large duplicated blocks from the inventory (task 1.1)
- [ ] 4.2 Consolidate within-file duplications using helper functions

## 5. Verification

- [ ] 5.1 Run `cd src && make` to verify clean build
- [ ] 5.2 Run `cd arrow-tools && make` to verify clean build
- [ ] 5.3 Run `cd test && make installcheck` to verify no regressions
- [ ] 5.4 Run SonarCloud analysis and verify duplication reduction (target: src/ <22%, arrow-tools/ <25%)
