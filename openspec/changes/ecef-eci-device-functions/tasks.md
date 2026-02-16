# Tasks: ECEF/ECI Device Functions

## Phase 1: ECI Frame Conversion

- [ ] Add ECI SRID constants (`ECI_SRID_ICRF`, `ECI_SRID_J2000`, `ECI_SRID_TEME`, `ECEF_SRID`) to `src/xpu_postgis.h`
- [ ] Add `eci_earth_rotation_angle()` static helper to `src/xpu_postgis.cu` — converts `timestamptz` (int64 usec since PG epoch) to ERA using IERS 2003 formula
- [ ] Add `eci_frame_to_srid()` static helper to `src/xpu_postgis.cu` — resolves frame text ('ICRF'/'J2000'/'TEME') to SRID with case-insensitive ASCII comparison
- [ ] Add `pgfn_st_ecef_to_eci()` device function to `src/xpu_postgis.cu` — 3-arg (geometry, timestamptz, text), applies Rz(+ERA), sets output SRID
- [ ] Add `pgfn_st_eci_to_ecef()` device function to `src/xpu_postgis.cu` — 3-arg, applies Rz(-ERA), cross-validates input SRID against frame, sets output SRID 4978
- [ ] Register `st_ecef_to_eci` and `st_eci_to_ecef` in `src/xpu_opcodes.h` with extension `"postgis_ecef_eci"`

## Phase 2: ECEF Coordinate Accessors

- [ ] Add `pgfn_st_ecef_x()` device function to `src/xpu_postgis.cu` — extracts X from POINT rawdata, returns float8
- [ ] Add `pgfn_st_ecef_y()` device function to `src/xpu_postgis.cu` — extracts Y from POINT rawdata, returns float8
- [ ] Add `pgfn_st_ecef_z()` device function to `src/xpu_postgis.cu` — extracts Z from POINT rawdata (checks Z flag), returns float8 or NULL
- [ ] Register `st_ecef_x`, `st_ecef_y`, `st_ecef_z` in `src/xpu_opcodes.h` with extension `"postgis_ecef_eci"`

## Phase 3: 3D Spatial Operations

- [ ] Add `pgfn_st_3ddistance()` device function to `src/xpu_postgis.cu` — point-to-point 3D Euclidean distance, falls back to CPU for non-POINT
- [ ] Add `pgfn_st_3ddwithin()` device function to `src/xpu_postgis.cu` — squared-distance comparison against threshold, returns bool
- [ ] Register `st_3ddistance` and `st_3ddwithin` in `src/xpu_opcodes.h` with extension `"postgis"`

## Phase 4: Tests

- [ ] Add ECI round-trip regression test to `test/sql/postgis.sql` — ECEF→ECI→ECEF on GPU, verify distance < 1e-10 vs CPU
- [ ] Add coordinate accessor test to `test/sql/postgis.sql` — GPU ST_ECEF_X/Y/Z vs CPU ST_X/ST_Y/ST_Z
- [ ] Add 3D distance test to `test/sql/postgis.sql` — GPU ST_3DDistance vs CPU for known ECEF point pairs
- [ ] Add 3D proximity test to `test/sql/postgis.sql` — GPU ST_3DDWithin filter vs CPU, verify identical result sets
- [ ] Generate expected output files for PG 16/17/18 in `test/{16,17,18}/expected/postgis.out`
