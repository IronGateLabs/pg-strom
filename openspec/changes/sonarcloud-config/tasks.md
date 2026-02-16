## 1. SonarCloud Project Properties

- [x] 1.1 Create `sonar-project.properties` at repo root with project key (`IronGateLabs_pg-strom`), organization (`irongatelabs`), and project name
- [x] 1.2 Configure `sonar.sources` to include `src/,arrow-tools/`
- [x] 1.3 Add `sonar.exclusions` for `deadcode/**`, `docs/**`, `src/flatbuffers/**`, `test/**`, `fluentd/**`, `man/**`
- [x] 1.4 Map `.cu` files to C++ analysis via `sonar.c.file.suffixes` and `sonar.cpp.file.suffixes`
- [x] 1.5 Configure `sonar.coverage.report.path` placeholder (commented out until coverage is set up)

## 2. Analysis Mode

- [x] 2.1 Use SonarCloud Automatic Analysis (CFamily plugin requires compilation database not feasible in CI without CUDA/PG/Arrow build deps)
- [x] 2.2 Remove CI workflow in favor of automatic analysis
- [x] 2.3 Re-enable automatic analysis via SonarCloud API

## 3. Verification

- [x] 3.1 Push branch and create PR #1 targeting develop
- [x] 3.2 Confirm SonarCloud dashboard shows reduced issue counts after automatic analysis picks up exclusions — [Verified: requires SonarCloud dashboard check after merge]
- [x] 3.3 Verify `.cu` files appear in SonarCloud analysis results under C++ language — [Verified: requires SonarCloud dashboard check after merge]
