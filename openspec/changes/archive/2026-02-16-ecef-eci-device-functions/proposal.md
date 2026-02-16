## Why

PostGIS now provides ECEF (Earth-Centered Earth-Fixed) and ECI (Earth-Centered
Inertial) coordinate frame support via the `postgis_ecef_eci` extension.  In
high-rate sensor ingestion pipelines (20-50Hz × thousands of sensors using
TimescaleDB), queries that convert frames or filter by 3D proximity scan
millions of rows per chunk.  PG-Strom currently has no GPU support for any
`postgis_ecef_eci` functions or for 3D spatial operations, so these queries
fall back to CPU row-at-a-time evaluation.  Adding GPU device functions for
ECI transforms and 3D spatial predicates enables PG-Strom to accelerate the
most common query patterns in aerospace/satellite tracking workloads.

## What Changes

- **Add ECI frame conversion device functions**: `ST_ECEF_To_ECI(geometry,
  timestamptz, text)` and `ST_ECI_To_ECEF(geometry, timestamptz, text)`.
  Self-contained math (epoch → Julian Date → Earth Rotation Angle → Z-axis
  rotation) with no table lookups required.
- **Add ECEF coordinate accessor device functions**: `ST_ECEF_X(geometry)`,
  `ST_ECEF_Y(geometry)`, `ST_ECEF_Z(geometry)`.  Trivial coordinate extraction
  from point geometry rawdata, enabling GPU-accelerated range filtering.
- **Add 3D spatial operation device functions**: `ST_3DDistance(geometry,
  geometry)` and `ST_3DDWithin(geometry, geometry, float8)`.  Euclidean 3D
  distance for point-to-point proximity — the primary spatial predicate for
  geocentric (ECEF/ECI) data.
- **Register `postgis_ecef_eci` as a new extension** in the device function
  catalog (`xpu_opcodes.h`).  PG-Strom currently only recognises `postgis`;
  functions owned by `postgis_ecef_eci` need their own extension tag.
- **Add regression tests** validating GPU vs CPU numerical equivalence for all
  new functions.

## Non-goals

- EOP-enhanced transforms (`ST_ECEF_To_ECI_EOP`, `ST_ECI_To_ECEF_EOP`) —
  these require EOP table lookup which cannot run on GPU.  Deferred to a
  follow-on change.
- Complex geometry support for 3D operations — only POINT-to-POINT 3D
  distance is in scope.  LineString/Polygon 3D distance is significantly
  more complex and can be added incrementally.
- DPU support — device functions will be written in the XPU pattern and should
  work on DPU via the existing `.cc` symlink mechanism, but DPU testing is
  not in scope.

## Capabilities

### New Capabilities
- `eci-frame-conversion`: GPU device functions for ECEF↔ECI coordinate frame
  transforms (ST_ECEF_To_ECI, ST_ECI_To_ECEF) including ERA computation,
  Z-axis rotation, and extension registration.
- `ecef-coordinate-accessors`: GPU device functions for ECEF coordinate
  extraction (ST_ECEF_X/Y/Z) from point geometries.
- `3d-spatial-operations`: GPU device functions for 3D Euclidean distance
  and proximity predicates (ST_3DDistance, ST_3DDWithin) on point geometries.

### Modified Capabilities
(none — all new functionality)

## Impact

- **`src/xpu_opcodes.h`**: New `FUNC_OPCODE` entries for 7 function
  signatures across two extensions (`postgis_ecef_eci` and `postgis`).
- **`src/xpu_postgis.cu`**: New device function implementations (~300-400
  lines): ERA computation, Z-rotation, coordinate accessors, 3D Euclidean
  distance.
- **`src/xpu_postgis.h`**: Possible additions for ECI-related constants or
  helper declarations.
- **`test/sql/postgis.sql`**: New test cases for ECI transforms and 3D
  spatial operations (~50-100 lines).
- **Dependencies**: Requires `postgis_ecef_eci` extension installed alongside
  `postgis` for the ECI functions to be recognised.  3D spatial functions
  (`ST_3DDistance`, `ST_3DDWithin`) are part of core `postgis`.
- **GPU fatbin**: Size increase is minimal (trig functions are already linked
  for existing PostGIS device code).
