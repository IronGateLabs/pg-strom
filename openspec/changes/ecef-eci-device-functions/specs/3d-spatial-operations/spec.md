## ADDED Requirements

### Requirement: ST_3DDistance GPU execution
PG-Strom SHALL execute `ST_3DDistance(geometry, geometry)` on GPU.  The
function is part of the core `postgis` extension and returns `float8`.

The device function SHALL compute the 3D Euclidean distance between two
POINT geometries: `sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)`.

The initial implementation SHALL support POINT-to-POINT distance only.  For
non-POINT geometry types, the device function SHALL return an error, causing
PG-Strom to fall back to CPU execution.

#### Scenario: 3D distance between two ECEF points
- **WHEN** a query evaluates `ST_3DDistance(a.geom, b.geom)` in a GpuJoin
  between two tables of ECEF PointZ geometries
- **THEN** the returned float8 values match the CPU-computed 3D Euclidean
  distance within floating-point precision (relative error < 1e-15)

#### Scenario: Non-point geometry falls back to CPU
- **WHEN** `ST_3DDistance` is called with a LINESTRING or POLYGON geometry
  on GPU
- **THEN** the device function reports an error and the row falls back to
  CPU evaluation

### Requirement: ST_3DDWithin GPU execution
PG-Strom SHALL execute `ST_3DDWithin(geometry, geometry, float8)` on GPU.
The function is part of the core `postgis` extension and returns `boolean`.

The device function SHALL return `true` when the 3D Euclidean distance
between two POINT geometries is less than or equal to the threshold distance
parameter.  The implementation SHOULD use the squared-distance comparison
(`dx*dx + dy*dy + dz*dz <= threshold*threshold`) to avoid the `sqrt` call.

The initial implementation SHALL support POINT-to-POINT only.  Non-POINT
inputs SHALL cause fallback to CPU.

#### Scenario: 3D proximity filter in WHERE clause
- **WHEN** a query evaluates `WHERE ST_3DDWithin(a.geom, target, 100000)`
  across a GpuScan of ECEF points
- **THEN** PG-Strom evaluates the predicate on GPU, returning only rows
  within 100km of the target point

#### Scenario: GPU vs CPU result equivalence
- **WHEN** `ST_3DDWithin` is evaluated on GPU for a set of point pairs
- **THEN** the boolean results match the CPU evaluation for all pairs
  (no false positives or false negatives)

#### Scenario: Boundary condition at exact threshold distance
- **WHEN** two points are separated by exactly the threshold distance
- **THEN** `ST_3DDWithin` returns `true` (less-than-or-equal semantics)

### Requirement: 3D spatial operations work with ECEF and ECI SRIDs
The 3D spatial device functions SHALL work correctly with geometries carrying
SRID 4978 (ECEF), 900001 (ICRF), 900002 (J2000), or 900003 (TEME).  The
functions SHALL NOT perform any SRID-based coordinate transformation — they
compute raw Euclidean distance on the stored coordinates regardless of SRID.

#### Scenario: ST_3DDistance with ECEF SRID 4978
- **WHEN** both geometries have SRID 4978
- **THEN** the 3D distance is computed in metres (ECEF coordinate units)

#### Scenario: ST_3DDWithin with ECI SRID 900001
- **WHEN** both geometries have SRID 900001 (ICRF)
- **THEN** the proximity threshold is applied in metres against the raw
  ECI coordinates
