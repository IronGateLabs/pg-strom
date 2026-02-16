## 1. BLOCKER Bugs (highest priority)

- [x] 1.1 Fix S3519 out-of-bounds access in `src/codegen.c:2982` (field 'offset' at negative index) — FALSE POSITIVE: flexible array member, dynamically allocated
- [x] 1.2 Fix S3519 out-of-bounds access in `src/gpu_service.c:3151` (field 'xcmd' at negative offset) — FALSE POSITIVE: container_of pattern
- [x] 1.3 Fix S3519 out-of-bounds access in `src/dpu_device.c:86` (tainted index on 'namebuf') — FIXED: readlink size limit MAXPGPATH-1
- [x] 1.4 Fix S3519 buffer overflow in `src/arrow_fdw.c:429` (memset overflows destination) — FALSE POSITIVE: memset bounded by offsetof
- [x] 1.5 Fix S3519 buffer overflow in `src/arrow_write.c:277` (memcpy overflows destination) — FALSE POSITIVE: memmove within buffer, guarded by assert
- [x] 1.6 Fix S3519 out-of-bounds in `src/arrow_write.c:281` (vtable access at index 1) — FALSE POSITIVE: vtable access within allocated buffer
- [x] 1.7 Review S5489 lock ordering issue in `src/pg_utils.h:382` — FALSE POSITIVE: simple pthread_mutex_unlock wrapper
- [x] 1.8 Review S5486 double-unlock issue in `src/pg_utils.h:382` — FALSE POSITIVE: analyzer confused by wrapper indirection
- [x] 1.9 Fix S5000 struct padding comparison in `src/arrow_fdw.c:3194` and `:3212` — FIXED: replaced memcmp with function pointer comparison
- [ ] 1.10 Fix S3519 out-of-bounds in `src/dpu/xpu_postgis.cc:2916`
- [ ] 1.11 Fix S6655 out-of-scope variable access in `src/dpu/xpu_postgis.cc:4856` and `:5464`
- [x] 1.12 Fix S3519 buffer overflow in `src/gpu_cache.c:1173` — FIXED: sizeof(GpuCacheOptions) → sizeof(GpuCacheIdent)

## 2. CRITICAL Bugs

- [ ] 2.1 Fix remaining S3519 bugs in `src/` (arrow_write.c:1190 strcpy, xpu_common.h:3178 memory leak)
- [ ] 2.2 Fix S2259 null dereference bugs in `src/` (3 locations)
- [ ] 2.3 Fix S2259 null dereference bugs in `src/dpu/` (2 locations)

## 3. MAJOR Bugs

- [x] 3.1 Fix S836 uninitialized variable in `src/gpu_scan.c:49` — FIXED: self-assignment cscan=(CustomScan*)cscan → plan
- [ ] 3.2 Triage S836 uninitialized variable bugs in `src/dpu/xpu_postgis.cc` (10 locations — likely PostGIS patterns, verify each)
- [ ] 3.3 Fix S836 uninitialized variable bugs in `src/dpu/xpu_timelib.cc` (3 locations)
- [x] 3.4 Fix S836 uninitialized variable in `src/misc.c:2405` — FIXED: fdesc initialized to -1
- [x] 3.5 Fix S1862 identical condition bug in `src/xpu_numeric.h:300` — FIXED: POS_INF→NEG_INF
- [x] 3.6 Fix S1764 identical sub-expression bug in `src/xpu_misclib.cu:1334,1337` — FIXED: datum_a→datum_b in inet comparison
- [x] 3.7 Fix S836 uninitialized vars in `src/select_into.c:301` — FIXED: avg_weight/avg_value initialized for special numerics
- [ ] 3.8 Fix S836 uninitialized variable in `src/brin.c:586` — needs triage

## 4. Arrow-tools Bugs

- [ ] 4.1 Fix 6 bugs in `arrow-tools/` (identify and fix by rule)

## 5. Verification

- [ ] 5.1 Run `cd test && make installcheck` to verify no regressions
- [ ] 5.2 Run SonarCloud analysis and verify bug count reduction to <5
- [ ] 5.3 Verify reliability rating improvement (target: E → B or better)
