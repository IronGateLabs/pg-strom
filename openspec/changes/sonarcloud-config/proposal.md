## Why

SonarCloud analysis of PG-Strom currently reports 921 bugs, 12,263 code smells, 3 vulnerabilities, 860 security hotspots, and 25.3% duplication — but the vast majority is noise from deprecated code (`deadcode/`), generated HTML docs (`docs/`), vendored libraries (`src/flatbuffers/`), and test SQL. The project has zero code coverage reporting. Without proper configuration, the SonarCloud dashboard is unusable for tracking real quality issues in active code (`src/`, `arrow-tools/`). Setting this up now establishes the baseline for all subsequent quality improvement work.

## What Changes

- Add `sonar-project.properties` to configure project key, org, source paths, and exclusions
- Exclude `deadcode/`, `docs/`, `src/flatbuffers/`, `test/`, `fluentd/`, `man/`, and generated files from analysis
- Add GitHub Actions workflow for SonarCloud analysis on push and PR events
- Configure coverage report path so future test coverage work is automatically picked up
- Set appropriate language-specific file suffixes (C, C++, CUDA)

## Non-goals

- Fixing any of the reported bugs, vulnerabilities, or code smells (separate changes)
- Setting up actual test coverage instrumentation (separate change)
- Modifying upstream code or the build system
- Configuring CodeQL separately (it currently only surfaces the same 3 deadcode issues as SonarCloud)

## Capabilities

### New Capabilities
- `sonarcloud-analysis`: SonarCloud project configuration, source/exclusion paths, and GitHub Actions CI workflow for automated analysis with coverage reporting

### Modified Capabilities
<!-- None — no existing specs yet -->

## Impact

- New files: `sonar-project.properties`, `.github/workflows/sonarcloud.yml`
- SonarCloud dashboard will show dramatically fewer issues (focused on `src/` and `arrow-tools/` only)
- Expected reduction: ~741 false bugs, ~5,000+ irrelevant code smells, all 3 vulnerabilities (deadcode only)
- Remaining actionable issues after exclusions: ~41 bugs in src/, ~3,200 code smells in src/+arrow-tools/
- No impact on build, runtime, or existing functionality
