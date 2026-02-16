# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PG-Strom is a PostgreSQL extension (v6.1) that accelerates batch/analytics workloads using NVIDIA GPUs, NVMe-SSD (GPUDirect Storage), and Apache Arrow columnar format. Licensed under the PostgreSQL License. Requires PostgreSQL 15.0+.

Documentation: http://heterodb.github.io/pg-strom/

## Build Commands

### Extension (src/)
```bash
cd src && make                    # Build extension
cd src && make install            # Install to PostgreSQL
cd src && make PG_CONFIG=/path/to/pg_config install  # Custom PG install
cd src && make PGSTROM_DEBUG=1    # Debug build (symbols, -O0)
cd src && make fatbin             # Build only GPU device code
```

### Arrow Tools (arrow-tools/)
```bash
cd arrow-tools && make            # Builds pg2arrow, tsv2arrow, vcf2arrow, arrow2csv
cd arrow-tools && make install    # Install to /usr/local/bin (or PREFIX=)
```

### Regression Tests (test/)
```bash
cd test && make installcheck              # Run all regression tests
cd test && make installcheck-parallel     # Run tests in parallel
```
Test database: `contrib_regression_pg_strom`. Tests are version-specific (input/output in `test/<PG_MAJORVERSION>/`). Schedule defined in `test/parallel_schedule`. PostGIS tests auto-enabled if available.

### Packaging
```bash
make tarball         # Source tarball
make rpm-pg_strom    # RPM packages
make deb             # Debian packages (experimental)
```

## Build Dependencies

- NVIDIA CUDA Toolkit (nvcc, libcuda, cufile) — auto-detected from `/usr/local/cuda`
- PostgreSQL dev headers (pg_config)
- Apache Arrow C++ (`libarrow`, detected via `pkgconf`)
- Apache Parquet C++ (`libparquet`, optional, detected via `pkgconf`)
- C++17 required for all C++ code

## Architecture

### XPU Execution Model

The core abstraction is "XPU" — a unified programming model where the same operation code runs on GPU (CUDA), CPU (fallback), or DPU. Each data type and function has an `xpu_*` implementation with device-agnostic interfaces.

- **Type system**: `xpu_TYPE_t` structs (e.g., `xpu_int4_t`) with `TypeOpCode` enums
- **Function system**: `FuncOpCode` enums mapping PostgreSQL functions to device implementations
- **Code generation** (`codegen.c`): Translates SQL expressions into sequences of XPU opcodes at plan time

### Query Execution Pipeline

1. **Planner hook** (`executor.c:pgstrom_planner_hook`) — intercepts planning, decides GPU vs CPU
2. **Code generation** (`codegen.c`) — builds XPU opcode sequences for WHERE/SELECT/aggregates
3. **GPU service** (`gpu_service.c`) — separate daemon process manages GPU resources, receives commands
4. **CUDA kernels** (`cuda_gpu*.cu`) — execute scans/joins/aggregation on GPU
5. **Fallback** (`fallback.c`) — CPU re-execution if GPU fails; controlled by `pg_strom.cpu_fallback`

### Custom Scan Nodes

Three main GPU-accelerated scan types injected into PostgreSQL query plans:
- **GpuScan** (`gpu_scan.c` / `cuda_gpuscan.cu`) — sequential table scan
- **GpuJoin** (`gpu_join.c` / `cuda_gpujoin.cu`) — hash/nested-loop joins
- **GpuPreAgg** (`gpu_preagg.c` / `cuda_gpupreagg.cu`) — pre-aggregation

### Key Data Structures

- **`kern_data_store` (KDS)** — unified row/columnar data format for GPU/CPU transfer
- **`GpuContext` / `gpuClient`** — client connection to GPU service daemon
- **`devtype_info` / `devfunc_info`** — registry of GPU-capable types and functions

### Arrow Foreign Data Wrapper

`arrow_fdw.c` implements a PostgreSQL FDW that maps Arrow/Parquet files as foreign tables. Supports BRIN index hints, virtual columns (file path, record batch index), and min/max statistics for predicate pushdown.

### GPU Cache

`gpu_cache.c` keeps hot table data pinned in GPU device memory, synchronized with heap updates. Used for repeated scans of the same data.

## Source Layout

| Directory | Purpose |
|-----------|---------|
| `src/` | Main extension: host C code, CUDA kernels (.cu), headers |
| `src/sql/` | Extension SQL DDL and upgrade scripts |
| `src/dpu/` | DPU (Data Processing Unit) service |
| `arrow-tools/` | CLI utilities: pg2arrow, tsv2arrow, vcf2arrow, arrow2csv |
| `test/` | Regression tests, benchmark data generators (SSBM, TPC-H) |
| `man/` | Documentation source (MkDocs markdown) |
| `docs/` | Pre-built HTML documentation |
| `files/` | RPM spec templates, systemd configs |
| `deadcode/` | Deprecated code from v2.x/v3.x |

### Naming Conventions

- `xpu_*.cu/h` — Device-side type/function implementations (basetype, numeric, textlib, timelib, jsonlib, misclib, postgis)
- `cuda_gpu*.cu` — CUDA kernel entry points for scan operations
- `gpu_*.c` — Host-side GPU operation code
- `arrow_*.c/cpp` — Arrow format handling
- `kern_*` prefix — kernel-side data structures
- `pgstrom_*` prefix — public API functions

### CUDA Compilation

GPU code compiles to a FatBin containing PTX + SASS for architectures sm_60 through sm_90. The FatBin filename includes nvcc version and source MD5: `pgstrom-gpucode-V{version}-{md5}.fatbin`. Register limit is 128 per thread (512 threads/SM).
