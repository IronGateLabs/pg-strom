## ADDED Requirements

### Requirement: ST_ECEF_X GPU execution
PG-Strom SHALL execute `ST_ECEF_X(geometry)` on GPU.  The function is owned
by the `postgis_ecef_eci` extension and returns `float8`.

The device function SHALL extract the X coordinate (first double in the point
rawdata) from the input geometry.  The input geometry MUST be a POINT type.
For non-POINT or empty geometries, the function SHALL return NULL.

#### Scenario: Extract X coordinate on GPU
- **WHEN** a query evaluates `ST_ECEF_X(geom)` in a GpuScan WHERE clause
  over a table of ECEF points
- **THEN** the returned float8 values match `ST_X(geom)` computed on CPU

#### Scenario: Range filter using ST_ECEF_X
- **WHEN** a query filters `WHERE ST_ECEF_X(geom) BETWEEN 6000000 AND 7000000`
  across a large chunk scan
- **THEN** PG-Strom evaluates the range predicate on GPU, reducing the number
  of rows returned to the CPU

### Requirement: ST_ECEF_Y GPU execution
PG-Strom SHALL execute `ST_ECEF_Y(geometry)` on GPU.  The function is owned
by the `postgis_ecef_eci` extension and returns `float8`.

The device function SHALL extract the Y coordinate (second double in the point
rawdata) from the input geometry.

#### Scenario: Extract Y coordinate on GPU
- **WHEN** a query evaluates `ST_ECEF_Y(geom)` in a GpuScan
- **THEN** the returned float8 values match `ST_Y(geom)` computed on CPU

### Requirement: ST_ECEF_Z GPU execution
PG-Strom SHALL execute `ST_ECEF_Z(geometry)` on GPU.  The function is owned
by the `postgis_ecef_eci` extension and returns `float8`.

The device function SHALL extract the Z coordinate (third double in the point
rawdata) from a geometry that has a Z dimension.  If the geometry does not
have a Z dimension or is empty, the function SHALL return NULL.

#### Scenario: Extract Z coordinate on GPU
- **WHEN** a query evaluates `ST_ECEF_Z(geom)` on a PointZ geometry
- **THEN** the returned float8 value matches `ST_Z(geom)` computed on CPU

#### Scenario: Geometry without Z dimension
- **WHEN** `ST_ECEF_Z(geom)` is called on a 2D geometry (no Z flag)
- **THEN** the function returns NULL
