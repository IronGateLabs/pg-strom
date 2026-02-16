## Context

PG-Strom is analyzed by SonarCloud under the `irongatelabs` organization (project key: `IronGateLabs_pg-strom`). The initial scan ingested the entire repository including deprecated code, generated docs, vendored libraries, and test fixtures — producing ~920 bugs and ~12,000 code smells, most of which are noise. There is no `sonar-project.properties` and no CI workflow for automated analysis. The SONAR_TOKEN is configured as a GitHub secret.

## Goals / Non-Goals

**Goals:**
- Configure SonarCloud to analyze only active source code (`src/`, `arrow-tools/`, `src/dpu/`)
- Exclude noise directories: `deadcode/`, `docs/`, `src/flatbuffers/`, `test/`, `fluentd/`, `man/`
- Set up GitHub Actions workflow for analysis on push to master and on PRs
- Pre-configure coverage report path for future test coverage integration
- Map CUDA `.cu` files to C++ analysis

**Non-Goals:**
- Setting up test coverage instrumentation or gcov/llvm-cov tooling
- Fixing any reported issues
- Configuring quality gates or quality profiles (use SonarCloud defaults initially)
- Setting up CodeQL workflows (only surfaces deadcode issues already covered by exclusions)

## Decisions

### 1. Use `sonar-project.properties` over CI-inline configuration
**Rationale:** Properties file is version-controlled, self-documenting, and works with both CI and local `sonar-scanner` runs. Alternatives: inline `-D` flags in CI (harder to maintain), SonarCloud UI settings (not version-controlled).

### 2. Use SonarCloud GitHub Action (`SonarSource/sonarcloud-github-action`)
**Rationale:** Official action, handles scanner installation and caching. Alternative: manual `sonar-scanner` CLI installation in workflow (more maintenance burden).

### 3. Map `.cu` files as C++ for analysis
**Rationale:** CUDA `.cu` files are C++ superset. SonarCloud doesn't have a native CUDA analyzer, but the C++ analyzer catches most relevant issues. Alternative: exclude `.cu` files (loses coverage of significant codebase portion).

### 4. Exclude `src/flatbuffers/` as vendored code
**Rationale:** This is third-party generated/vendored code that we don't maintain. Analyzing it produces 1,606 code smells that are not actionable. SonarCloud's `sonar.exclusions` handles this cleanly.

### 5. Exclude `test/` directory from main analysis
**Rationale:** Test SQL files and benchmark generators (SSBM, TPC-H) produce 69 bugs (mostly SQL-specific rules) and 300+ code smells that are test fixtures, not production code. Test code coverage will be handled separately via `sonar.test.inclusions`.

## Risks / Trade-offs

- **[Risk] CUDA-specific constructs may cause C++ analyzer false positives** → Accept initially; can add per-file exclusions later if noisy
- **[Risk] Excluding `test/` means no analysis of test helper C code** → Test helpers in `test/` are minimal; `src/` test integration is covered
- **[Trade-off] Using defaults for quality gate** → Gets us started quickly; can tighten later based on baseline metrics
