## ADDED Requirements

### Requirement: Identify and catalog duplication hotspots
All duplicated blocks in `src/` and `arrow-tools/` SHALL be cataloged using the SonarCloud duplications API before any code changes.

#### Scenario: Duplication inventory created
- **WHEN** analysis begins
- **THEN** a list of the top 20 largest duplicated blocks SHALL be produced with file locations, line ranges, and block sizes

### Requirement: Extract shared arrow-tools utilities
Common code patterns duplicated across `pg2arrow`, `tsv2arrow`, `vcf2arrow`, and `arrow2csv` SHALL be extracted into shared source files.

#### Scenario: Arrow file reading pattern consolidated
- **WHEN** multiple tools contain identical Arrow file open/read/close sequences
- **THEN** the pattern SHALL be extracted into a shared utility (e.g., `arrow_common.cpp`)

#### Scenario: Schema handling consolidated
- **WHEN** multiple tools contain identical Arrow schema construction code
- **THEN** the shared code SHALL be extracted into a common module

### Requirement: Consolidate duplicated blocks in src/
Duplicated code blocks within `src/` SHALL be consolidated using helper functions, macros, or shared utilities where the duplication is not intentional.

#### Scenario: Duplicated type-dispatch patterns
- **WHEN** multiple xpu_*.cu files contain identical switch/case patterns dispatching by type
- **THEN** a macro or template SHALL capture the pattern with type as a parameter

#### Scenario: Duplicated scan node lifecycle code
- **WHEN** gpu_scan.c, gpu_join.c, and gpu_preagg.c contain identical initialization/cleanup patterns
- **THEN** the common patterns SHALL be extracted into shared helper functions

### Requirement: Preserve intentional duplication
Duplication between `src/` and `src/dpu/` SHALL NOT be consolidated, as the DPU implementation is intentionally separate.

#### Scenario: src/ to src/dpu/ duplication detected
- **WHEN** a duplicated block spans `src/` and `src/dpu/`
- **THEN** it SHALL be excluded from consolidation and documented as intentional

### Requirement: Duplication target metrics
After consolidation, duplication density SHALL be measurably reduced.

#### Scenario: arrow-tools duplication reduced
- **WHEN** shared utilities are extracted from arrow-tools/
- **THEN** duplication density in `arrow-tools/` SHALL be below 25% (from 38.3%)

#### Scenario: src duplication reduced
- **WHEN** duplicated blocks in src/ are consolidated
- **THEN** duplication density in `src/` SHALL be below 22% (from 26.8%)
