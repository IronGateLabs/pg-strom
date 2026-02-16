## Technical Design: ECEF/ECI Device Functions for PG-Strom

### Architecture Overview

PG-Strom's XPU execution model intercepts SQL expressions at plan time,
translates them to opcode sequences, and dispatches them to GPU threads
(one thread per row).  Each device function receives arguments via
`KEXP_PROCESS_ARGS*` macros and operates on `xpu_*_t` typed values.

The ECI device functions fit cleanly into this model: each row contains a
geometry (ECEF point) and a timestamptz (epoch), and the function computes
a Z-axis rotation — pure math, no table lookups, no geometry traversal.

### File Changes

#### `src/xpu_opcodes.h` — Function Registration

Add entries for the 7 new function signatures.  Note that ECI functions
belong to the `postgis_ecef_eci` extension, while 3D spatial functions
belong to core `postgis`:

```c
/* ECEF/ECI frame conversion (postgis_ecef_eci extension) */
FUNC_OPCODE(st_ecef_to_eci, geometry/timestamptz/text, DEVKIND__ANY, st_ecef_to_eci, 20, "postgis_ecef_eci")
FUNC_OPCODE(st_eci_to_ecef, geometry/timestamptz/text, DEVKIND__ANY, st_eci_to_ecef, 20, "postgis_ecef_eci")

/* ECEF coordinate accessors (postgis_ecef_eci extension) */
FUNC_OPCODE(st_ecef_x, geometry, DEVKIND__ANY, st_ecef_x, 5, "postgis_ecef_eci")
FUNC_OPCODE(st_ecef_y, geometry, DEVKIND__ANY, st_ecef_y, 5, "postgis_ecef_eci")
FUNC_OPCODE(st_ecef_z, geometry, DEVKIND__ANY, st_ecef_z, 5, "postgis_ecef_eci")

/* 3D spatial operations (postgis extension) */
__FUNC_OPCODE(st_3ddistance, geometry/geometry, 20, "postgis")
__FUNC_OPCODE(st_3ddwithin,  geometry/geometry/float8, 20, "postgis")
```

Cost estimates: ECI transforms at 20 (trig is more expensive than simple
geometry ops at 5, but less than recursive operations at 99).  Coordinate
accessors at 5 (trivial extraction).

#### `src/xpu_postgis.cu` — Device Function Implementations

Add ~300 lines at the end of the file, after the existing PostGIS functions.

##### ECI Helper Functions (static, device-side)

```c
/* ECI SRID constants */
#define ECI_SRID_ICRF    900001
#define ECI_SRID_J2000   900002
#define ECI_SRID_TEME    900003
#define ECEF_SRID        4978

/*
 * Earth Rotation Angle (ERA) from timestamptz.
 *
 * PostgreSQL timestamptz is int64 microseconds since 2000-01-01 00:00:00 UTC.
 * Julian Date of PG epoch = POSTGRES_EPOCH_JDATE = 2451545 (= J2000.0 noon).
 * Du = JD_UT1 - 2451545.0 = tstz_usec / USECS_PER_DAY
 * (since POSTGRES_EPOCH_JDATE IS 2451545.0, Du simplifies directly)
 *
 * ERA = 2*pi * (0.7790572732640 + 1.00273781191135448 * Du)
 * per IERS Conventions (2003).
 */
STATIC_FUNCTION(double)
eci_earth_rotation_angle(int64_t tstz_usec)
{
    double Du = (double)tstz_usec / (86400.0 * 1000000.0);
    double theta = 2.0 * M_PI * (0.7790572732640 + 1.00273781191135448 * Du);
    /* Normalize to [0, 2*pi) */
    theta = fmod(theta, 2.0 * M_PI);
    if (theta < 0.0)
        theta += 2.0 * M_PI;
    return theta;
}

/*
 * Resolve frame text to ECI SRID.
 * Returns 0 on invalid frame.
 */
STATIC_FUNCTION(int32_t)
eci_frame_to_srid(const xpu_text_t *frame)
{
    /* Compare against known frame names (case-insensitive) */
    /* PG-Strom text values have rawdata + length */
    ...
}
```

##### ECI Transform Functions

The `pgfn_st_ecef_to_eci` function follows PG-Strom's 3-arg pattern:

```c
PUBLIC_FUNCTION(bool)
pgfn_st_ecef_to_eci(XPU_PGFUNCTION_ARGS)
{
    KEXP_PROCESS_ARGS3(geometry, geometry, geom,
                       timestamptz, epoch, text, frame);
    if (XPU_DATUM_ISNULL(&geom) || XPU_DATUM_ISNULL(&epoch) ||
        XPU_DATUM_ISNULL(&frame))
    {
        result->expr_ops = NULL;
        return true;
    }
    /* Validate input: must be POINT with SRID 4978 */
    if (geom.type != GEOM_POINTTYPE || geom.srid != ECEF_SRID)
    {
        STROM_ELOG(kcxt, "ST_ECEF_To_ECI: input must be POINT with SRID 4978");
        return false;
    }
    /* Resolve frame to target SRID */
    int32_t target_srid = eci_frame_to_srid(&frame);
    if (target_srid == 0)
    {
        STROM_ELOG(kcxt, "ST_ECEF_To_ECI: frame must be ICRF, J2000, or TEME");
        return false;
    }
    /* Compute ERA and apply rotation */
    double theta = eci_earth_rotation_angle(epoch.value);
    double cos_t = cos(theta);
    double sin_t = sin(theta);

    /* Read point coordinates (handle unaligned rawdata) */
    double x, y, z;
    memcpy(&x, geom.rawdata + 0 * sizeof(double), sizeof(double));
    memcpy(&y, geom.rawdata + 1 * sizeof(double), sizeof(double));
    memcpy(&z, geom.rawdata + 2 * sizeof(double), sizeof(double));

    /* Rz(+theta): ECEF to ECI */
    double *out = (double *)kcxt_alloc(kcxt, 3 * sizeof(double));
    if (!out) { STROM_ELOG(kcxt, "out of memory"); return false; }
    out[0] =  x * cos_t + y * sin_t;
    out[1] = -x * sin_t + y * cos_t;
    out[2] =  z;

    /* Build result geometry */
    result->expr_ops = &xpu_geometry_ops;
    result->type = GEOM_POINTTYPE;
    result->flags = GEOM_FLAG__Z;
    result->srid = target_srid;
    result->nitems = 1;
    result->rawsize = 3 * sizeof(double);
    result->rawdata = (char *)out;
    result->bbox = NULL;
    return true;
}
```

The `pgfn_st_eci_to_ecef` function is identical except:
- Input SRID validation checks for 900001/900002/900003
- Cross-validates SRID against frame text
- Applies `Rz(-theta)` (negated angle)
- Sets output SRID to 4978

##### Coordinate Accessors

Trivial extraction from geometry rawdata:

```c
PUBLIC_FUNCTION(bool)
pgfn_st_ecef_x(XPU_PGFUNCTION_ARGS)
{
    KEXP_PROCESS_ARGS1(float8, geometry, geom);
    if (XPU_DATUM_ISNULL(&geom) || geom.type != GEOM_POINTTYPE ||
        geom.nitems == 0)
        result->expr_ops = NULL;
    else
    {
        memcpy(&result->value, geom.rawdata, sizeof(double));
        result->expr_ops = &xpu_float8_ops;
    }
    return true;
}
```

`ST_ECEF_Y` reads at offset `sizeof(double)`, `ST_ECEF_Z` reads at
`2 * sizeof(double)` and checks `GEOM_FLAG__Z`.

##### 3D Spatial Functions

```c
PUBLIC_FUNCTION(bool)
pgfn_st_3ddistance(XPU_PGFUNCTION_ARGS)
{
    KEXP_PROCESS_ARGS2(float8, geometry, geom_a, geometry, geom_b);
    /* Validate both are POINT with Z */
    if (geom_a.type != GEOM_POINTTYPE || geom_b.type != GEOM_POINTTYPE ||
        !(geom_a.flags & GEOM_FLAG__Z) || !(geom_b.flags & GEOM_FLAG__Z))
    {
        STROM_ELOG(kcxt, "ST_3DDistance: only POINT Z geometries supported on GPU");
        return false;
    }
    double ax, ay, az, bx, by, bz;
    memcpy(&ax, geom_a.rawdata + 0, sizeof(double));
    memcpy(&ay, geom_a.rawdata + 8, sizeof(double));
    memcpy(&az, geom_a.rawdata + 16, sizeof(double));
    memcpy(&bx, geom_b.rawdata + 0, sizeof(double));
    memcpy(&by, geom_b.rawdata + 8, sizeof(double));
    memcpy(&bz, geom_b.rawdata + 16, sizeof(double));

    double dx = ax - bx, dy = ay - by, dz = az - bz;
    result->value = sqrt(dx*dx + dy*dy + dz*dz);
    result->expr_ops = &xpu_float8_ops;
    return true;
}
```

`ST_3DDWithin` uses squared-distance comparison to avoid `sqrt`:
```c
double dist_sq = dx*dx + dy*dy + dz*dz;
result->value = (dist_sq <= threshold.value * threshold.value);
result->expr_ops = &xpu_bool_ops;
```

#### `src/xpu_postgis.h` — Constants

Add ECI SRID definitions and any helper macros (small change, ~10 lines).

#### `test/sql/postgis.sql` — Regression Tests

Add test section after existing PostGIS tests:

1. **ECI round-trip test**: Create ECEF points, convert to ECI on GPU,
   convert back, verify distance < 1e-10.
2. **Coordinate accessor test**: Extract X/Y/Z on GPU, compare against
   CPU ST_X/ST_Y/ST_Z.
3. **3D distance test**: Compute ST_3DDistance on GPU vs CPU for known
   point pairs.
4. **3D proximity test**: Filter with ST_3DDWithin on GPU, verify same
   result set as CPU.

Tests use `SET pg_strom.enabled = on/off` to force GPU vs CPU execution
and compare results.

### Key Design Decisions

**1. TimestampTz to ERA conversion on GPU**

PostgreSQL `timestamptz` is `int64_t` microseconds since 2000-01-01.
`POSTGRES_EPOCH_JDATE = 2451545` is exactly J2000.0 noon (JD 2451545.0).
Therefore `Du = JD - 2451545.0 = tstz_usec / USECS_PER_DAY`, which avoids
needing calendar decomposition entirely.  This is more efficient than
converting to year/month/day and back to Julian Date.

**2. Text parameter comparison on GPU**

The `frame` text parameter ('ICRF', 'J2000', 'TEME') needs case-insensitive
comparison on the GPU.  PG-Strom's `xpu_text_t` provides `rawdata` and
`rawsize`.  Implement a simple 4/5-byte comparison with manual case folding
(no locale dependency for ASCII frame names).

**3. Point-only 3D operations**

Restricting ST_3DDistance/ST_3DDWithin to POINT-to-POINT avoids the
complexity of line segment and polygon distance algorithms on GPU.  Non-point
inputs trigger `STROM_ELOG` which causes PG-Strom to fall back to CPU
(`pg_strom.cpu_fallback`).  This covers the primary ECEF/ECI use case
(sensor point positions) while keeping the implementation simple.

**4. Unaligned memory access**

Geometry rawdata may not be aligned to `sizeof(double)`.  All coordinate
reads use `memcpy` rather than pointer casts to avoid undefined behaviour
on strict-alignment architectures.  This matches PG-Strom's existing pattern.

**5. No bbox recomputation**

The rotated geometry does not recompute a bounding box (`bbox = NULL`).
The bbox would need to be recomputed by PostGIS on the CPU side if needed.
This matches how PG-Strom handles other geometry-returning functions
(e.g., `st_setsrid` sets `bbox = NULL` implicitly by not changing it, but
new geometries from `st_makepoint` have `bbox = NULL`).

### Dependencies

- `postgis_ecef_eci` extension must be installed for ECI functions to be
  recognised.  PG-Strom's `pgstrom_devfunc_lookup()` uses
  `get_extension_name_by_object()` to match function ownership.
- CUDA `cos()`, `sin()`, `sqrt()`, `fmod()` are available in device code
  (already used by existing PostGIS device functions in `xpu_postgis.cu`).
- `POSTGRES_EPOCH_JDATE`, `USECS_PER_DAY` from `xpu_timelib.h`.

### Risk Assessment

- **Low risk**: Coordinate accessors are trivial (5 lines each).
- **Low risk**: 3D distance is pure arithmetic.
- **Medium risk**: ECI transforms involve trig and text comparison on GPU.
  Mitigated by validation tests comparing GPU vs CPU results.
- **No risk to existing functions**: All changes are additive — no
  modification of existing device functions or registration entries.
