## ADDED Requirements

### Requirement: ST_ECEF_To_ECI GPU execution
PG-Strom SHALL execute `ST_ECEF_To_ECI(geometry, timestamptz, text)` on GPU
when the function appears in a query expression (WHERE clause, SELECT list,
or JOIN condition) and the query plan selects a GpuScan, GpuJoin, or
GpuPreAgg node.  The function is owned by the `postgis_ecef_eci` extension.

The device function SHALL:
1. Extract the point coordinates (X, Y, Z) from the input geometry.
2. Convert the `timestamptz` epoch to a Julian Date via
   `JD = 2451545.0 + (epoch_seconds / 86400.0 - 10957.5)` where
   `epoch_seconds` is seconds since the PostgreSQL epoch (2000-01-01).
3. Compute the Earth Rotation Angle (ERA) using IERS 2003:
   `ERA = 2*pi*(0.7790572732640 + 1.00273781191135448 * (JD - 2451545.0))`,
   normalized to [0, 2*pi).
4. Apply the Z-axis rotation: `x' = x*cos(ERA) + y*sin(ERA)`,
   `y' = -x*sin(ERA) + y*cos(ERA)`, `z' = z`.
5. Set the output SRID to the ECI frame (900001 for ICRF, 900002 for J2000,
   900003 for TEME).
6. Return the rotated geometry.

The `frame` text parameter SHALL be resolved to the target SRID.  If the frame
text is not one of 'ICRF', 'J2000', or 'TEME' (case-insensitive), the device
function SHALL return an error via `STROM_ELOG`.

#### Scenario: ECEF to ICRF conversion in WHERE clause
- **WHEN** a query evaluates `ST_ECEF_To_ECI(geom, epoch, 'ICRF')` across
  a table scan and PG-Strom selects a GpuScan node
- **THEN** the ECI rotation is computed on GPU for each row, and the result
  geometry has SRID 900001

#### Scenario: ECEF to TEME conversion in SELECT
- **WHEN** a query projects `ST_ECEF_To_ECI(geom, epoch, 'TEME')` in the
  SELECT list of a GpuScan
- **THEN** the returned geometries have SRID 900003 and coordinates match
  the CPU result within 1e-10 metres

#### Scenario: Invalid frame parameter
- **WHEN** the frame text is not 'ICRF', 'J2000', or 'TEME'
- **THEN** the device function reports an error and the query falls back
  to CPU execution

### Requirement: ST_ECI_To_ECEF GPU execution
PG-Strom SHALL execute `ST_ECI_To_ECEF(geometry, timestamptz, text)` on GPU.
The function is owned by the `postgis_ecef_eci` extension.

The device function SHALL apply the inverse Z-axis rotation:
`x' = x*cos(ERA) - y*sin(ERA)`, `y' = x*sin(ERA) + y*cos(ERA)`, `z' = z`,
using the negated ERA angle.  The output geometry SHALL have SRID 4978 (ECEF).

The input geometry SRID SHALL be cross-validated against the frame parameter.
If the geometry SRID does not match the expected ECI SRID for the given frame,
the device function SHALL return an error.

#### Scenario: ECI to ECEF conversion
- **WHEN** a query evaluates `ST_ECI_To_ECEF(geom, epoch, 'ICRF')` on a
  geometry with SRID 900001
- **THEN** the result geometry has SRID 4978 and coordinates match the CPU
  result within 1e-10 metres

#### Scenario: SRID-frame mismatch
- **WHEN** a geometry with SRID 900003 (TEME) is passed with frame 'ICRF'
- **THEN** the device function reports an error and the query falls back
  to CPU

### Requirement: Round-trip numerical equivalence
The GPU implementation of ECEF→ECI→ECEF round-trip SHALL produce results
that match the CPU implementation to within 1e-10 metres (sub-nanometre
at Earth radius scale).

#### Scenario: GPU vs CPU round-trip accuracy
- **WHEN** a point is converted ECEF→ECI→ECEF on GPU and the same conversion
  is performed on CPU
- **THEN** the maximum coordinate difference between GPU and CPU results is
  less than 1e-10 metres

### Requirement: Extension registration for postgis_ecef_eci
PG-Strom's device function catalog SHALL recognise `postgis_ecef_eci` as a
valid extension name for function lookup.  Functions owned by this extension
SHALL be matched against catalog entries tagged with `"postgis_ecef_eci"`.

#### Scenario: Function owned by postgis_ecef_eci is recognised
- **WHEN** the PostgreSQL catalog reports that `ST_ECEF_To_ECI` is owned by
  the `postgis_ecef_eci` extension
- **THEN** PG-Strom's `pgstrom_devfunc_lookup()` finds the matching device
  function and includes it in the GPU execution plan
