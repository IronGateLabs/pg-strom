---
--- Test for GPU PostGIS Support
---
SET client_min_messages = error;
DROP SCHEMA IF EXISTS regtest_postgis_temp CASCADE;
CREATE SCHEMA regtest_postgis_temp;
SET search_path = regtest_postgis_temp,public;
\set test_giskanto_src_path `echo -n $ARROW_TEST_DATA_DIR/giskanto.sql`
\i :test_giskanto_src_path
RESET client_min_messages;

CREATE TABLE dpoints (
  did    int,
  x      float8,
  y      float8
);
SELECT pgstrom.random_setseed(20240527);
INSERT INTO dpoints (SELECT i, pgstrom.random_float(0.0, 138.787661, 140.434258),
                               pgstrom.random_float(0.0,  35.250012,  36.179917)
                       FROM generate_series(1,300000) i);
---
--- Run GPU Join with GiST index
---
RESET pg_strom.enabled;
EXPLAIN (verbose, costs off)
SELECT pref, city, count(*)
  FROM giskanto, dpoints
 WHERE (pref = '東京都' or city like '横浜市 %')
   AND st_contains(geom, st_makepoint(x, y))
 GROUP BY pref, city
 ORDER BY pref, city;

SELECT pref, city, count(*)
  FROM giskanto, dpoints
 WHERE (pref = '東京都' or city like '横浜市 %')
   AND st_contains(geom, st_makepoint(x, y))
 GROUP BY pref, city
 ORDER BY pref, city;

RESET pg_strom.enabled;
EXPLAIN (verbose, costs off)
SELECT pref, city, count(*)
  FROM giskanto, dpoints
 WHERE ((pref = '東京都' and city like '%区') OR
        (pref = '埼玉県' and city like '%市%'))
   AND st_dwithin(geom, st_makepoint(x, y), 0.002)
 GROUP BY pref, city
 ORDER BY pref, city;

SELECT pref, city, count(*)
  FROM giskanto, dpoints
 WHERE ((pref = '東京都' and city like '%区') OR
        (pref = '埼玉県' and city like '%市%'))
   AND st_dwithin(geom, st_makepoint(x, y), 0.002)
 GROUP BY pref, city
 ORDER BY pref, city;

---
--- PostGIS Functions
---
RESET pg_strom.enabled;

/*
--
-- st_distance POLY-POLY is wrong
--
EXPLAIN
SELECT a.pref, a.city, b.pref, b.city, st_distance(a.geom, b.geom)
  FROM giskanto a, giskanto b
 WHERE a.gid <> b.gid
   AND a.city in ('目黒区','所沢市', '杉並区','府中市')
   AND b.city in ('鴻巣市','蕨市','葛飾区','海老名市');

SELECT a.pref, a.city, b.pref, b.city, st_distance(a.geom, b.geom)
  FROM giskanto a, giskanto b
 WHERE a.gid <> b.gid
   AND a.city in ('目黒区','所沢市', '杉並区','府中市')
   AND b.city in ('鴻巣市','蕨市','葛飾区','海老名市');
*/

-- distance from POINT(皇居)
SET enable_seqscan = off;
RESET pg_strom.enabled;
EXPLAIN (verbose, costs off)
SELECT gid, pref, city,
       st_distance(geom, st_makepoint(139.7234394, 35.6851783)) dist
  INTO test01g
  FROM giskanto
 WHERE gid > 0;

SELECT gid, pref, city,
       st_distance(geom, st_makepoint(139.7234394, 35.6851783)) dist
  INTO test01g
  FROM giskanto
 WHERE gid > 0;

SET pg_strom.enabled = off;
SELECT gid, pref, city,
       st_distance(geom, st_makepoint(139.7234394, 35.6851783)) dist
  INTO test01c
  FROM giskanto
 WHERE gid > 0;

/*
SELECT *
  FROM test01g g, test01c c
 WHERE g.gid = c.gid
   AND abs(g.dist - c.dist) >= 0.00001;
*/

-- distance from POINT(筑波大学)
RESET pg_strom.enabled;
EXPLAIN (verbose, costs off)
SELECT gid, pref, city,
       st_distance(geom, st_makepoint(140.1070404, 36.094009)) dist
  INTO test02g
  FROM giskanto
 WHERE gid > 0;

SELECT gid, pref, city,
       st_distance(geom, st_makepoint(140.1070404, 36.094009)) dist
  INTO test02g
  FROM giskanto
 WHERE gid > 0;

SET pg_strom.enabled = off;
SELECT gid, pref, city,
       st_distance(geom, st_makepoint(140.1070404, 36.094009)) dist
  INTO test02c
  FROM giskanto
 WHERE gid > 0;

/*
SELECT *
  FROM test02g g, test02c c
 WHERE g.gid = c.gid
   AND abs(g.dist - c.dist) >= 0.00001;
*/

---
--- ECEF/ECI Device Functions Tests
---

-- Create test data: ECEF points (SRID 4978) with timestamps
-- These represent realistic satellite/ground positions in ECEF coordinates (meters)
CREATE TABLE ecef_points (
  pid    int,
  geom   geometry(PointZ, 4978),
  epoch  timestamptz
);
INSERT INTO ecef_points VALUES
  (1, ST_SetSRID(ST_MakePoint( 4510731.0,  4510731.0, 0.0), 4978),
      '2024-06-15 12:00:00 UTC'),
  (2, ST_SetSRID(ST_MakePoint( 6378137.0,        0.0, 0.0), 4978),
      '2024-06-15 12:00:00 UTC'),
  (3, ST_SetSRID(ST_MakePoint(       0.0,  6378137.0, 0.0), 4978),
      '2024-06-15 12:00:00 UTC'),
  (4, ST_SetSRID(ST_MakePoint( 4510731.0,  4510731.0, 4510731.0), 4978),
      '2024-01-01 00:00:00 UTC'),
  (5, ST_SetSRID(ST_MakePoint(-2699538.0,  5765387.0, 2079137.0), 4978),
      '2024-03-20 06:30:00 UTC'),
  (6, ST_SetSRID(ST_MakePoint( 1234567.0, -2345678.0, 5678901.0), 4978),
      '2024-09-22 18:45:00 UTC'),
  (7, ST_SetSRID(ST_MakePoint(  422604.0,   422604.0, 6356752.0), 4978),
      '2024-12-21 23:59:59 UTC'),
  (8, ST_SetSRID(ST_MakePoint( 6378137.0,        0.0, 0.0), 4978),
      '2000-01-01 12:00:00 UTC');

-- Create a second set of ECEF points for distance tests
CREATE TABLE ecef_points_b (
  pid    int,
  geom   geometry(PointZ, 4978)
);
INSERT INTO ecef_points_b VALUES
  (1, ST_SetSRID(ST_MakePoint( 4510732.0,  4510732.0,    1.0), 4978)),
  (2, ST_SetSRID(ST_MakePoint( 6378237.0,      100.0,    0.0), 4978)),
  (3, ST_SetSRID(ST_MakePoint(     100.0,  6378237.0,    0.0), 4978)),
  (4, ST_SetSRID(ST_MakePoint( 4510831.0,  4510831.0, 4510831.0), 4978)),
  (5, ST_SetSRID(ST_MakePoint(-2699438.0,  5765487.0, 2079237.0), 4978)),
  (6, ST_SetSRID(ST_MakePoint( 1234667.0, -2345578.0, 5679001.0), 4978)),
  (7, ST_SetSRID(ST_MakePoint(  422704.0,   422704.0, 6356852.0), 4978)),
  (8, ST_SetSRID(ST_MakePoint( 6379137.0,     1000.0, 1000.0), 4978));

---
--- Test 1: ECI Round-Trip (ECEF -> ECI -> ECEF), GPU vs CPU
---         Verify that round-trip distance is < 1e-10
---
SET enable_seqscan = off;
RESET pg_strom.enabled;
SELECT pid,
       ST_3DDistance(
         geom,
         ST_ECI_To_ECEF(
           ST_ECEF_To_ECI(geom, epoch, 'ICRF'),
           epoch, 'ICRF'
         )
       ) AS roundtrip_dist
  INTO test_eci_roundtrip_g
  FROM ecef_points;

SET pg_strom.enabled = off;
SELECT pid,
       ST_3DDistance(
         geom,
         ST_ECI_To_ECEF(
           ST_ECEF_To_ECI(geom, epoch, 'ICRF'),
           epoch, 'ICRF'
         )
       ) AS roundtrip_dist
  INTO test_eci_roundtrip_c
  FROM ecef_points;

-- GPU and CPU round-trip distances should both be near zero.
-- Any row here means GPU diverged from CPU beyond tolerance.
SELECT g.pid, g.roundtrip_dist AS gpu_dist, c.roundtrip_dist AS cpu_dist
  FROM test_eci_roundtrip_g g, test_eci_roundtrip_c c
 WHERE g.pid = c.pid
   AND abs(g.roundtrip_dist - c.roundtrip_dist) >= 1e-10
 ORDER BY g.pid;

---
--- Test 2: Coordinate Accessors (GPU ST_ECEF_X/Y/Z vs CPU ST_X/ST_Y/ST_Z)
---
RESET pg_strom.enabled;
SELECT pid,
       ST_ECEF_X(geom) AS ex,
       ST_ECEF_Y(geom) AS ey,
       ST_ECEF_Z(geom) AS ez
  INTO test_accessor_g
  FROM ecef_points;

SET pg_strom.enabled = off;
SELECT pid,
       ST_X(geom) AS ex,
       ST_Y(geom) AS ey,
       ST_Z(geom) AS ez
  INTO test_accessor_c
  FROM ecef_points;

-- GPU ST_ECEF_X/Y/Z should match CPU ST_X/ST_Y/ST_Z exactly
SELECT g.pid,
       g.ex AS gpu_x, c.ex AS cpu_x,
       g.ey AS gpu_y, c.ey AS cpu_y,
       g.ez AS gpu_z, c.ez AS cpu_z
  FROM test_accessor_g g, test_accessor_c c
 WHERE g.pid = c.pid
   AND (g.ex <> c.ex OR g.ey <> c.ey OR g.ez <> c.ez)
 ORDER BY g.pid;

---
--- Test 3: 3D Distance (GPU ST_3DDistance vs CPU for known ECEF point pairs)
---
RESET pg_strom.enabled;
SELECT a.pid,
       ST_3DDistance(a.geom, b.geom) AS dist3d
  INTO test_3ddist_g
  FROM ecef_points a, ecef_points_b b
 WHERE a.pid = b.pid;

SET pg_strom.enabled = off;
SELECT a.pid,
       ST_3DDistance(a.geom, b.geom) AS dist3d
  INTO test_3ddist_c
  FROM ecef_points a, ecef_points_b b
 WHERE a.pid = b.pid;

-- GPU and CPU 3D distances should match within floating-point tolerance
SELECT g.pid, g.dist3d AS gpu_dist, c.dist3d AS cpu_dist,
       abs(g.dist3d - c.dist3d) AS diff
  FROM test_3ddist_g g, test_3ddist_c c
 WHERE g.pid = c.pid
   AND abs(g.dist3d - c.dist3d) >= 1e-6
 ORDER BY g.pid;

---
--- Test 4: 3D Proximity (GPU ST_3DDWithin vs CPU, verify identical result sets)
---
RESET pg_strom.enabled;
SELECT a.pid AS pid_a, b.pid AS pid_b
  INTO test_3ddwithin_g
  FROM ecef_points a, ecef_points_b b
 WHERE ST_3DDWithin(a.geom, b.geom, 250.0);

SET pg_strom.enabled = off;
SELECT a.pid AS pid_a, b.pid AS pid_b
  INTO test_3ddwithin_c
  FROM ecef_points a, ecef_points_b b
 WHERE ST_3DDWithin(a.geom, b.geom, 250.0);

-- GPU results that are missing from CPU results (should be empty)
SELECT g.pid_a, g.pid_b
  FROM test_3ddwithin_g g
 WHERE NOT EXISTS (
   SELECT 1 FROM test_3ddwithin_c c
    WHERE c.pid_a = g.pid_a AND c.pid_b = g.pid_b
 )
 ORDER BY g.pid_a, g.pid_b;

-- CPU results that are missing from GPU results (should be empty)
SELECT c.pid_a, c.pid_b
  FROM test_3ddwithin_c c
 WHERE NOT EXISTS (
   SELECT 1 FROM test_3ddwithin_g g
    WHERE g.pid_a = c.pid_a AND g.pid_b = c.pid_b
 )
 ORDER BY c.pid_a, c.pid_b;
