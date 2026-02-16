## 1. SonarCloud Project Properties

- [x] 1.1 Create `sonar-project.properties` at repo root with project key (`IronGateLabs_pg-strom`), organization (`irongatelabs`), and project name
- [x] 1.2 Configure `sonar.sources` to include `src/,arrow-tools/`
- [x] 1.3 Add `sonar.exclusions` for `deadcode/**`, `docs/**`, `src/flatbuffers/**`, `test/**`, `fluentd/**`, `man/**`
- [x] 1.4 Map `.cu` files to C++ analysis via `sonar.c.file.suffixes` and `sonar.cpp.file.suffixes`
- [x] 1.5 Configure `sonar.coverage.report.path` placeholder for future coverage integration (e.g., `coverage.xml`)

## 2. GitHub Actions Workflow

- [x] 2.1 Create `.github/workflows/sonarcloud.yml` with trigger on push to `master` and pull requests
- [x] 2.2 Add checkout step with `fetch-depth: 0` (required for SonarCloud blame data)
- [x] 2.3 Add `SonarSource/sonarcloud-github-action` step using `SONAR_TOKEN` secret
- [x] 2.4 Set `GITHUB_TOKEN` for PR decoration

## 3. Verification

- [ ] 3.1 Push branch and verify GitHub Actions workflow triggers successfully
- [ ] 3.2 Confirm SonarCloud dashboard shows reduced issue counts (deadcode/docs/flatbuffers excluded)
- [ ] 3.3 Verify `.cu` files appear in SonarCloud analysis results under C++ language
