## 1. BLOCKER Bugs (highest priority)

- [ ] 1.1 Fix S3519 out-of-bounds access in `src/codegen.c:2982` (field 'offset' at negative index)
- [ ] 1.2 Fix S3519 out-of-bounds access in `src/gpu_service.c:3151` (field 'xcmd' at negative offset)
- [ ] 1.3 Fix S3519 out-of-bounds access in `src/dpu_device.c:86` (tainted index on 'namebuf')
- [ ] 1.4 Fix S3519 buffer overflow in `src/arrow_fdw.c:429` (memset overflows destination)
- [ ] 1.5 Fix S3519 buffer overflow in `src/arrow_write.c:277` (memcpy overflows destination)
- [ ] 1.6 Fix S3519 out-of-bounds in `src/arrow_write.c:281` (vtable access at index 1)
- [ ] 1.7 Review S5489 lock ordering issue in `src/pg_utils.h:382`
- [ ] 1.8 Review S5486 double-unlock issue in `src/pg_utils.h:382`
- [ ] 1.9 Fix S5000 struct padding comparison in `src/arrow_fdw.c:3194` and `:3212`
- [ ] 1.10 Fix S3519 out-of-bounds in `src/dpu/xpu_postgis.cc:2916`
- [ ] 1.11 Fix S6655 out-of-scope variable access in `src/dpu/xpu_postgis.cc:4856` and `:5464`

## 2. CRITICAL Bugs

- [ ] 2.1 Fix remaining S3519 bugs in `src/` (2 additional locations)
- [ ] 2.2 Fix S2259 null dereference bugs in `src/` (3 locations)
- [ ] 2.3 Fix S2259 null dereference bugs in `src/dpu/` (2 locations)

## 3. MAJOR Bugs

- [ ] 3.1 Fix S836 uninitialized variable bugs in `src/` (5 locations)
- [ ] 3.2 Triage S836 uninitialized variable bugs in `src/dpu/xpu_postgis.cc` (10 locations — likely PostGIS patterns, verify each)
- [ ] 3.3 Fix S3584 bug in `src/` (1 location)
- [ ] 3.4 Fix S2637 bug in `src/` (1 location)
- [ ] 3.5 Fix S1862 identical condition bug in `src/` (1 location)
- [ ] 3.6 Fix S1764 identical sub-expression bug in `src/dpu/` (1 location)

## 4. Arrow-tools Bugs

- [ ] 4.1 Fix 6 bugs in `arrow-tools/` (identify and fix by rule)

## 5. Verification

- [ ] 5.1 Run `cd test && make installcheck` to verify no regressions
- [ ] 5.2 Run SonarCloud analysis and verify bug count reduction to <5
- [ ] 5.3 Verify reliability rating improvement (target: E → B or better)
